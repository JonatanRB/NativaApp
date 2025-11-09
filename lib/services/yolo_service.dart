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

  // Configura estas según tu modelo
  static const int inputSize = 640; // Tamaño de entrada típico de YOLO (puede ser 320, 416, 640)
  static const int numClasses = 1; // Número de clases que detecta tu modelo
  
  // Lista de nombres de clases - ACTUALIZA ESTO según las clases de tu modelo
  static const List<String> labels = [
    'planta', // Reemplaza con tus clases reales
    // 'rosa', 'girasol', 'cactus', etc.
  ];

  Future<void> loadModel() async {
    if (_modelLoaded) return;

    try {
      // Carga el modelo desde assets
      _interpreter = await Interpreter.fromAsset('model/yolov11.tflite');
      _modelLoaded = true;
      print('✓ Modelo YOLO cargado correctamente');
    } catch (e) {
      print('Error cargando modelo: $e');
      throw Exception('No se pudo cargar el modelo TFLite: $e');
    }
  }

  Future<List<Detection>> predict(File imageFile, {double threshold = 0.5}) async {
    if (!_modelLoaded) {
      await loadModel();
    }

    try {
      // Leer y preprocesar imagen
      final bytes = await imageFile.readAsBytes();
      img.Image? image = img.decodeImage(bytes);
      
      if (image == null) {
        throw Exception('No se pudo decodificar la imagen');
      }

      // Redimensionar imagen al tamaño de entrada del modelo
      final resizedImage = img.copyResize(image, width: inputSize, height: inputSize);
      
      // Normalizar imagen y convertir a tensor
      final input = _imageToByteListFloat32(resizedImage);
      
      // Preparar output - Ajusta según la salida de tu modelo YOLOv11
      // Formato típico: [1, num_detections, 5 + num_classes]
      // donde 5 = [x, y, w, h, confidence]
      final output = List.generate(
        1,
        (_) => List.generate(
          8400, // Número de detecciones posibles (depende de tu modelo)
          (_) => List.filled(5 + numClasses, 0.0),
        ),
      );

      // Ejecutar inferencia
      _interpreter!.run(input, output);

      // Parsear resultados
      return _parseOutput(output[0], threshold, image.width, image.height);
    } catch (e) {
      print('Error en predicción: $e');
      throw Exception('Error procesando imagen: $e');
    }
  }

  List<double> _imageToByteListFloat32(img.Image image) {
    final convertedBytes = <double>[];
    
    for (int y = 0; y < image.height; y++) {
      for (int x = 0; x < image.width; x++) {
        final pixel = image.getPixel(x, y);
        
        // Normalizar RGB a [0, 1]
        convertedBytes.add(pixel.r / 255.0);
        convertedBytes.add(pixel.g / 255.0);
        convertedBytes.add(pixel.b / 255.0);
      }
    }
    
    return convertedBytes;
  }

  List<Detection> _parseOutput(List<List<double>> output, double threshold, int imgWidth, int imgHeight) {
    final detections = <Detection>[];

    for (var detection in output) {
      // YOLO output format: [x_center, y_center, width, height, confidence, class_scores...]
      final confidence = detection[4];
      
      if (confidence < threshold) continue;

      // Encontrar clase con mayor score
      int maxClassIndex = 0;
      double maxClassScore = detection[5];
      
      for (int i = 1; i < numClasses; i++) {
        if (detection[5 + i] > maxClassScore) {
          maxClassScore = detection[5 + i];
          maxClassIndex = i;
        }
      }

      final combinedScore = confidence * maxClassScore;
      
      if (combinedScore < threshold) continue;

      // Convertir coordenadas normalizadas a píxeles
      final x = detection[0] * imgWidth;
      final y = detection[1] * imgHeight;
      final w = detection[2] * imgWidth;
      final h = detection[3] * imgHeight;

      detections.add(Detection(
        label: labels[maxClassIndex],
        score: combinedScore,
        x: x,
        y: y,
        w: w,
        h: h,
      ));
    }

    // Aplicar NMS (Non-Maximum Suppression) si es necesario
    return _nonMaximumSuppression(detections, 0.4);
  }

  List<Detection> _nonMaximumSuppression(List<Detection> detections, double iouThreshold) {
    if (detections.isEmpty) return [];

    // Ordenar por score descendente
    detections.sort((a, b) => b.score.compareTo(a.score));

    final selected = <Detection>[];
    final suppressed = <bool>[];

    for (int i = 0; i < detections.length; i++) {
      suppressed.add(false);
    }

    for (int i = 0; i < detections.length; i++) {
      if (suppressed[i]) continue;
      
      selected.add(detections[i]);

      for (int j = i + 1; j < detections.length; j++) {
        if (suppressed[j]) continue;

        final iou = _calculateIoU(detections[i], detections[j]);
        if (iou > iouThreshold) {
          suppressed[j] = true;
        }
      }
    }

    return selected;
  }

  double _calculateIoU(Detection a, Detection b) {
    final x1 = a.x - a.w / 2;
    final y1 = a.y - a.h / 2;
    final x2 = a.x + a.w / 2;
    final y2 = a.y + a.h / 2;

    final x1b = b.x - b.w / 2;
    final y1b = b.y - b.h / 2;
    final x2b = b.x + b.w / 2;
    final y2b = b.y + b.h / 2;

    final intersectX1 = x1 > x1b ? x1 : x1b;
    final intersectY1 = y1 > y1b ? y1 : y1b;
    final intersectX2 = x2 < x2b ? x2 : x2b;
    final intersectY2 = y2 < y2b ? y2 : y2b;

    final intersectArea = (intersectX2 - intersectX1).clamp(0, double.infinity) *
                          (intersectY2 - intersectY1).clamp(0, double.infinity);

    final areaA = a.w * a.h;
    final areaB = b.w * b.h;
    final unionArea = areaA + areaB - intersectArea;

    return intersectArea / unionArea;
  }

  void dispose() {
    _interpreter?.close();
    _modelLoaded = false;
  }
}