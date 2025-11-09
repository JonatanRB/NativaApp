import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/yolo_service.dart';
import '../models/detection.dart';
import 'resultado_screen.dart';
import 'collection_screen.dart';

const Color kDarkGreen = Color(0xFF0A5C48);
const Color kLightGreen = Color(0xFFC4E4C6);

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  final ImagePicker _picker = ImagePicker();
  bool _loading = false;

  Future<void> _pickImage(ImageSource source) async {
    final XFile? picked = await _picker.pickImage(source: source, imageQuality: 85);
    if (picked == null) return;

    setState(() => _loading = true);

    final file = File(picked.path);
    try {
      // Cargar modelo (si no está cargado)
      await YoloService().loadModel();

      // Predecir
      final List<Detection> detections = await YoloService().predict(file, threshold: 0.35);

      // Navegar a pantalla de resultados
      if (!mounted) return;
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ResultadoScreen(
            imageFile: file,
            detections: detections,
          ),
        ),
      );
    } catch (e) {
      debugPrint('Error procesando imagen: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error procesando la imagen: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Widget _actionButton(IconData icon, String label, VoidCallback onTap, {Color? color}) {
    return SizedBox(
      width: 200,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 24),
        label: Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color ?? kDarkGreen,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 3,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kLightGreen.withOpacity(0.2),
      appBar: AppBar(
        title: const Text(
          'Detector de Plantas',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: kDarkGreen,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.collections_bookmark),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const CollectionScreen()),
              );
            },
            tooltip: 'Ver mi colección',
          ),
        ],
      ),
      body: Center(
        child: _loading
            ? const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: kDarkGreen),
                  SizedBox(height: 16),
                  Text(
                    'Procesando imagen...',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Esto puede tomar unos segundos',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              )
            : SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo o icono principal
                      Container(
                        padding: const EdgeInsets.all(30),
                        decoration: BoxDecoration(
                          color: kDarkGreen.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.local_florist,
                          size: 80,
                          color: kDarkGreen,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Título
                      const Text(
                        'Identifica tus plantas',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: kDarkGreen,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),

                      // Subtítulo
                      Text(
                        'Toma una foto o selecciona una imagen\npara identificar la planta',
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.grey[700],
                          height: 1.4,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 40),

                      // Botones de acción
                      _actionButton(
                        Icons.camera_alt,
                        'Tomar Foto',
                        () => _pickImage(ImageSource.camera),
                      ),
                      const SizedBox(height: 16),
                      _actionButton(
                        Icons.photo_library,
                        'Desde Galería',
                        () => _pickImage(ImageSource.gallery),
                      ),
                      const SizedBox(height: 32),

                      // Divider
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          children: [
                            Expanded(child: Divider(color: Colors.grey[400])),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              child: Text(
                                'o',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ),
                            Expanded(child: Divider(color: Colors.grey[400])),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Botón de colección
                      OutlinedButton.icon(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const CollectionScreen()),
                          );
                        },
                        icon: const Icon(Icons.collections_bookmark, color: kDarkGreen),
                        label: const Text(
                          'Ver Mi Colección',
                          style: TextStyle(
                            color: kDarkGreen,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                          side: const BorderSide(color: kDarkGreen, width: 2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
