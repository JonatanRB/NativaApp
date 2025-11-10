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
  static const int numClasses = 2; // ⚠️ CAMBIADO: 2 clases (mezquite y garambullo)
  static const int numDetections = 8400;

  // ⚠️ IMPORTANTE: Las etiquetas deben estar en el MISMO ORDEN que entrenaste
  // Si entrenaste primero garambullo y luego mezquite, déjalas así:
  static const List<String> labels = ['garambullo', 'mesquite'];
  
  // Si entrenaste en otro orden, cámbialas según tu data.yaml:
  // static const List<String> labels = ['mezquite', 'garambullo'];

  Future<void> loadModel() async {
    if (_modelLoaded) return;
    try {
      print('🧩 Cargando modelo desde assets/models/best_32.tflite...');
      _interpreter = await Interpreter.fromAsset(
        'assets/models/best_32.tflite',
        options: InterpreterOptions()
          ..threads = 4
          ..useNnApiForAndroid = true,
      );
      _modelLoaded = true;
      
      final inputShape = _interpreter!.getInputTensor(0).shape;
      final outputShape = _interpreter!.getOutputTensor(0).shape;
      
      print('✅ Modelo cargado correctamente:');
      print('   Input shape: $inputShape');
      print('   Output shape: $outputShape');
      print('   Clases: ${labels.join(", ")}');
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

      final bytes = await imageFile.readAsBytes();
      img.Image? image = img.decodeImage(bytes);
      if (image == null) {
        throw Exception('No se pudo decodificar la imagen');
      }

      print('📏 Imagen original: ${image.width}x${image.height}');
      
      final resized = img.copyResize(
        image,
        width: inputSize,
        height: inputSize,
        interpolation: img.Interpolation.linear,
      );
      
      print('📐 Imagen redimensionada: ${resized.width}x${resized.height}');

      // Preparar input
      final input = _imageToFloat32List(resized);

      // Preparar output [1, 6, 8400] para 2 clases (4 bbox + 2 scores)
      final outputShape = _interpreter!.getOutputTensor(0).shape;
      final output = List.generate(
        outputShape[0],
        (_) => List.generate(
          outputShape[1],
          (_) => List.filled(outputShape[2], 0.0),
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

  List<List<List<List<double>>>> _imageToFloat32List(img.Image image) {
    print('🧮 Convirtiendo imagen a tensor Float32...');
    
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

  List<Detection> _parseYoloOutput(
    List<List<double>> output,
    double threshold,
    int originalWidth,
    int originalHeight,
  ) {
    final detections = <Detection>[];
    final numBoxes = output[0].length;

    print('📦 Analizando $numBoxes cajas...');
    int validBoxes = 0;

    for (int i = 0; i < numBoxes; i++) {
      // Extraer coordenadas normalizadas
      final centerX = output[0][i];
      final centerY = output[1][i];
      final width = output[2][i];
      final height = output[3][i];

      // Encontrar clase con mayor confianza
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

      // Convertir a píxeles de imagen original
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
    
    final filtered = _nonMaximumSuppression(detections, 0.45);
    print('✨ Después de NMS: ${filtered.length} detecciones');
    
    return filtered;
  }

  List<Detection> _nonMaximumSuppression(
    List<Detection> detections,
    double iouThreshold,
  ) {
    if (detections.isEmpty) return [];

    detections.sort((a, b) => b.score.compareTo(a.score));

    final selected = <Detection>[];
    final suppressed = List.filled(detections.length, false);

    for (int i = 0; i < detections.length; i++) {
      if (suppressed[i]) continue;

      selected.add(detections[i]);

      for (int j = i + 1; j < detections.length; j++) {
        if (suppressed[j]) continue;

        final iou = _calculateIoU(detections[i], detections[j]);

        if (iou > iouThreshold && 
            detections[i].label == detections[j].label) {
          suppressed[j] = true;
        }
      }
    }

    return selected;
  }

  double _calculateIoU(Detection a, Detection b) {
    final x1_a = a.x - a.w / 2;
    final y1_a = a.y - a.h / 2;
    final x2_a = a.x + a.w / 2;
    final y2_a = a.y + a.h / 2;

    final x1_b = b.x - b.w / 2;
    final y1_b = b.y - b.h / 2;
    final x2_b = b.x + b.w / 2;
    final y2_b = b.y + b.h / 2;

    final x1_inter = x1_a > x1_b ? x1_a : x1_b;
    final y1_inter = y1_a > y1_b ? y1_a : y1_b;
    final x2_inter = x2_a < x2_b ? x2_a : x2_b;
    final y2_inter = y2_a < y2_b ? y2_a : y2_b;

    final intersectionWidth = (x2_inter - x1_inter).clamp(0.0, double.infinity);
    final intersectionHeight = (y2_inter - y1_inter).clamp(0.0, double.infinity);
    final intersectionArea = intersectionWidth * intersectionHeight;

    final areaA = a.w * a.h;
    final areaB = b.w * b.h;
    final unionArea = areaA + areaB - intersectionArea;

    return unionArea > 0 ? intersectionArea / unionArea : 0.0;
  }

  void dispose() {
    _interpreter?.close();
    _modelLoaded = false;
    print('🧹 YoloService limpiado');
  }
}
