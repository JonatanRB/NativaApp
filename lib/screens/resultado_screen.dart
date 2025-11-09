import 'dart:io';
import 'package:flutter/material.dart';
import '../models/detection.dart';
import '../db/database_helper.dart';
import '../models/plant.dart';
import '../utils/plant_info.dart';

const Color kDarkGreen = Color(0xFF0A5C48);
const Color kLightGreen = Color(0xFFC4E4C6);
const Color kBackgroundGreen = Color(0xFFF0F7F1);

class ResultadoScreen extends StatefulWidget {
  final File imageFile;
  final List<Detection> detections;

  const ResultadoScreen({super.key, required this.imageFile, required this.detections});

  @override
  State<ResultadoScreen> createState() => _ResultadoScreenState();
}

class _ResultadoScreenState extends State<ResultadoScreen> {
  final db = DatabaseHelper();
  bool _saving = false;

  Detection? get topDetection {
    if (widget.detections.isEmpty) return null;
    widget.detections.sort((a, b) => b.score.compareTo(a.score));
    return widget.detections.first;
  }

  Future<void> _savePlant() async {
    final det = topDetection;
    if (det == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hay detecciones para guardar.'))
      );
      return;
    }

    setState(() => _saving = true);

    // Obtener información de la planta desde el mapa
    final info = PlantDatabase.getInfo(det.label);

    final plant = Plant(
      name: info.commonName,
      scientificName: info.scientificName,
      description: info.description,
      imagePath: widget.imageFile.path,
      detectedLabel: det.label,
      confidence: det.score,
    );

    try {
      await db.insertPlant(plant);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✓ Planta guardada en tu colección'),
          backgroundColor: kDarkGreen,
        )
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error guardando: $e'))
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Widget _buildInfoCard(String title, String content, IconData icon) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: kDarkGreen, size: 24),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: kDarkGreen,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              content,
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detectionTile(Detection d) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: kLightGreen.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        dense: true,
        leading: const Icon(Icons.local_florist, color: kDarkGreen),
        title: Text(
          '${d.label} (${(d.score * 100).toStringAsFixed(1)}%)',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          'Posición: (${d.x.toStringAsFixed(0)}, ${d.y.toStringAsFixed(0)})',
          style: const TextStyle(fontSize: 12),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final det = topDetection;
    final info = det != null ? PlantDatabase.getInfo(det.label) : null;

    return Scaffold(
      backgroundColor: kBackgroundGreen,
      appBar: AppBar(
        backgroundColor: kDarkGreen,
        title: const Text('Resultados de Identificación'),
        elevation: 0,
      ),
      body: widget.detections.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  const Text(
                    'No se detectó ninguna planta',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Intenta con otra imagen',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Regresar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kDarkGreen,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              child: Column(
                children: [
                  // Imagen con borde superior redondeado
                  Container(
                    width: double.infinity,
                    height: 280,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                    ),
                    child: ClipRRect(
                      child: Image.file(
                        widget.imageFile,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),

                  // Contenido principal
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Tarjeta principal con nombre y confianza
                        Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              gradient: LinearGradient(
                                colors: [kDarkGreen, kDarkGreen.withOpacity(0.8)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            child: Column(
                              children: [
                                const Icon(Icons.check_circle, color: Colors.white, size: 48),
                                const SizedBox(height: 12),
                                Text(
                                  info?.commonName ?? 'Desconocido',
                                  style: const TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  info?.scientificName ?? '',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontStyle: FontStyle.italic,
                                    color: Colors.white.withOpacity(0.9),
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 12),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    'Confianza: ${(det!.score * 100).toStringAsFixed(1)}%',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton.icon(
                                    onPressed: _saving ? null : _savePlant,
                                    icon: _saving
                                        ? const SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: kDarkGreen,
                                            ),
                                          )
                                        : const Icon(Icons.save, color: kDarkGreen),
                                    label: Text(
                                      _saving ? 'Guardando...' : 'Guardar en mi colección',
                                      style: const TextStyle(
                                        color: kDarkGreen,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(vertical: 14),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Información detallada de la planta
                        if (info != null) ...[
                          _buildInfoCard(
                            'Descripción',
                            info.description,
                            Icons.info_outline,
                          ),
                          const SizedBox(height: 12),
                          _buildInfoCard(
                            'Cuidados',
                            info.care,
                            Icons.eco,
                          ),
                          const SizedBox(height: 12),
                          _buildInfoCard(
                            'Necesidades de Luz',
                            info.lightNeeds,
                            Icons.wb_sunny,
                          ),
                          const SizedBox(height: 12),
                          _buildInfoCard(
                            'Riego',
                            info.waterNeeds,
                            Icons.water_drop,
                          ),
                        ],

                        const SizedBox(height: 20),

                        // Lista de todas las detecciones
                        if (widget.detections.length > 1) ...[
                          Card(
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.list, color: kDarkGreen),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Todas las detecciones (${widget.detections.length})',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: kDarkGreen,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  ...widget.detections.map((d) => _detectionTile(d)),
                                ],
                              ),
                            ),
                          ),
                        ],

                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
