import 'dart:io';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;
import '../models/detection.dart';

class YoloService {
  static final YoloService _instance = YoloService._internal();
  factory YoloService() => _instance;
  YoloService._internal();

  Interpreter? _interpreter;
  bool _modelLoaded = false;

  // Configuración para YOLOv11
  static const int inputSize = 640;
  static const int numClasses = 1; // Cambia según tus clases
  static const int numDetections = 8400; // YOLOv11 genera 8400 detecciones

  // Tus etiquetas de clases
  static const List<String> labels = ['planta'];

  Future<void> loadModel() async {
    if (_modelLoaded) return;
    try {
      print('🧩 Cargando modelo desde assets/models/best_32.tflite...');
      _interpreter = await Interpreter.fromAsset(
        'assets/models/best_32.tflite',
        options: InterpreterOptions()
          ..threads = 4
          ..useNnApiForAndroid = true, // Aceleración hardware en Android
      );
      _modelLoaded = true;
      
      // Información del modelo
      final inputShape = _interpreter!.getInputTensor(0).shape;
      final outputShape = _interpreter!.getOutputTensor(0).shape;
      
      print('✅ Modelo cargado correctamente:');
      print('   Input shape: $inputShape');
      print('   Output shape: $outputShape');
      print('   Expected: [1, ${4 + numClasses}, $numDetections]');
    } catch (e) {
      print('❌ Error cargando modelo: $e');
      throw Exception('No se pudo cargar el modelo: $e');
    }
  }

  Future<List<Detection>> predict(File imageFile, {double threshold = 0.5}) async {
    if (!_modelLoaded) {
      await loadModel();
    }

    try {
      print('🖼️ Procesando imagen: ${imageFile.path}');
      if (!imageFile.existsSync()) {
        throw Exception('El archivo de imagen no existe');
      }

      // Leer y decodificar imagen
      final bytes = await imageFile.readAsBytes();
      img.Image? image = img.decodeImage(bytes);
      if (image == null) {
        throw Exception('No se pudo decodificar la imagen');
      }

      print('📏 Imagen original: ${image.width}x${image.height}');
      
      // Redimensionar manteniendo aspect ratio (opcional)
      final resized = img.copyResize(
        image,
        width: inputSize,
        height: inputSize,
        interpolation: img.Interpolation.linear,
      );
      
      print('📐 Imagen redimensionada: ${resized.width}x${resized.height}');

      // Preparar input (formato YOLOv11: [1, 640, 640, 3])
      final input = _imageToFloat32List(resized);

      // Preparar output (formato YOLOv11: [1, 5, 8400] para 1 clase)
      // [1, 4+numClasses, 8400]
      final outputShape = _interpreter!.getOutputTensor(0).shape;
      final output = List.generate(
        outputShape[0], // 1
        (_) => List.generate(
          outputShape[1], // 4 + numClasses (5 para 1 clase)
          (_) => List.filled(outputShape[2], 0.0), // 8400
        ),
      );

      print('🚀 Ejecutando inferencia...');
      final stopwatch = Stopwatch()..start();
      _interpreter!.run(input, output);
      stopwatch.stop();
      print('✅ Inferencia completada en ${stopwatch.elapsedMilliseconds} ms');

      // Parsear detecciones
      print('🔍 Procesando ${output[0][0].length} detecciones...');
      final detections = _parseYoloOutput(
        output[0],
        threshold,
        image.width,
        image.height,
      );

      print('🎯 Detecciones encontradas: ${detections.length}');
      for (final d in detections.take(5)) {
        print('→ ${d.label} (${(d.score * 100).toStringAsFixed(1)}%) '
              'bbox: [${d.x.toStringAsFixed(0)}, ${d.y.toStringAsFixed(0)}, '
              '${d.w.toStringAsFixed(0)}, ${d.h.toStringAsFixed(0)}]');
      }

      return detections;
    } catch (e, stackTrace) {
      print('❌ Error en predicción: $e');
      print(stackTrace);
      throw Exception('Error procesando imagen: $e');
    }
  }

  // Convertir imagen a Float32List normalizado [0, 1]
  List<List<List<List<double>>>> _imageToFloat32List(img.Image image) {
    print('🧮 Convirtiendo imagen a tensor Float32...');
    
    // Formato: [1, height, width, 3]
    return [
      List.generate(
        image.height,
        (y) => List.generate(
          image.width,
          (x) {
            final pixel = image.getPixel(x, y);
            return [
              pixel.r / 255.0,
              pixel.g / 255.0,
              pixel.b / 255.0,
            ];
          },
        ),
      ),
    ];
  }

  // Parsear salida de YOLOv11
  // Formato de salida: [4+numClasses, 8400]
  // Primeras 4 filas: [x_center, y_center, width, height] (normalized)
  // Siguientes numClasses filas: scores de cada clase
  List<Detection> _parseYoloOutput(
    List<List<double>> output,
    double threshold,
    int originalWidth,
    int originalHeight,
  ) {
    final detections = <Detection>[];
    final numBoxes = output[0].length; // 8400

    print('📦 Analizando $numBoxes cajas...');
    int validBoxes = 0;

    for (int i = 0; i < numBoxes; i++) {
      // Extraer coordenadas (normalizadas 0-1)
      final centerX = output[0][i];
      final centerY = output[1][i];
      final width = output[2][i];
      final height = output[3][i];

      // Encontrar la clase con mayor confianza
      double maxScore = 0.0;
      int maxClassIndex = 0;

      for (int c = 0; c < numClasses; c++) {
        final score = output[4 + c][i];
        if (score > maxScore) {
          maxScore = score;
          maxClassIndex = c;
        }
      }

      // Filtrar por threshold
      if (maxScore < threshold) continue;
      validBoxes++;

      // Convertir coordenadas normalizadas a píxeles de imagen original
      // YOLOv11 usa coordenadas relativas al tamaño de entrada (640x640)
      final x = centerX * originalWidth;
      final y = centerY * originalHeight;
      final w = width * originalWidth;
      final h = height * originalHeight;

      detections.add(Detection(
        label: labels[maxClassIndex],
        score: maxScore,
        x: x,
        y: y,
        w: w,
        h: h,
      ));
    }

    print('📊 Cajas válidas (score > $threshold): $validBoxes');
    print('🔄 Aplicando NMS...');
    
    // Aplicar Non-Maximum Suppression
    final filtered = _nonMaximumSuppression(detections, 0.45);
    print('✨ Después de NMS: ${filtered.length} detecciones');
    
    return filtered;
  }

  // Non-Maximum Suppression para eliminar detecciones duplicadas
  List<Detection> _nonMaximumSuppression(
    List<Detection> detections,
    double iouThreshold,
  ) {
    if (detections.isEmpty) return [];

    // Ordenar por confianza (mayor a menor)
    detections.sort((a, b) => b.score.compareTo(a.score));

    final selected = <Detection>[];
    final suppressed = List.filled(detections.length, false);

    for (int i = 0; i < detections.length; i++) {
      if (suppressed[i]) continue;

      selected.add(detections[i]);

      // Comparar con el resto de detecciones
      for (int j = i + 1; j < detections.length; j++) {
        if (suppressed[j]) continue;

        // Calcular IoU
        final iou = _calculateIoU(detections[i], detections[j]);

        // Si el IoU es alto y es la misma clase, suprimir
        if (iou > iouThreshold && 
            detections[i].label == detections[j].label) {
          suppressed[j] = true;
        }
      }
    }

    return selected;
  }

  // Calcular Intersection over Union (IoU)
  double _calculateIoU(Detection a, Detection b) {
    // Convertir de (center_x, center_y, w, h) a (x1, y1, x2, y2)
    final x1_a = a.x - a.w / 2;
    final y1_a = a.y - a.h / 2;
    final x2_a = a.x + a.w / 2;
    final y2_a = a.y + a.h / 2;

    final x1_b = b.x - b.w / 2;
    final y1_b = b.y - b.h / 2;
    final x2_b = b.x + b.w / 2;
    final y2_b = b.y + b.h / 2;

    // Calcular intersección
    final x1_inter = x1_a > x1_b ? x1_a : x1_b;
    final y1_inter = y1_a > y1_b ? y1_a : y1_b;
    final x2_inter = x2_a < x2_b ? x2_a : x2_b;
    final y2_inter = y2_a < y2_b ? y2_a : y2_b;

    final intersectionWidth = (x2_inter - x1_inter).clamp(0.0, double.infinity);
    final intersectionHeight = (y2_inter - y1_inter).clamp(0.0, double.infinity);
    final intersectionArea = intersectionWidth * intersectionHeight;

    // Calcular unión
    final areaA = a.w * a.h;
    final areaB = b.w * b.h;
    final unionArea = areaA + areaB - intersectionArea;

    // Retornar IoU
    return unionArea > 0 ? intersectionArea / unionArea : 0.0;
  }

  void dispose() {
    _interpreter?.close();
    _modelLoaded = false;
    print('🧹 YoloService limpiado');
  }
}
