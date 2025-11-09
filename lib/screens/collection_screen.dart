import 'dart:io';
import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import '../models/plant.dart';

const Color kDarkGreen = Color(0xFF0A5C48);
const Color kLightGreen = Color(0xFFC4E4C6);
const Color kBackgroundGreen = Color(0xFFF0F7F1);

class CollectionScreen extends StatefulWidget {
  const CollectionScreen({super.key});

  @override
  State<CollectionScreen> createState() => _CollectionScreenState();
}

class _CollectionScreenState extends State<CollectionScreen> {
  final db = DatabaseHelper();
  List<Plant> _plants = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadPlants();
  }

  Future<void> _loadPlants() async {
    setState(() => _loading = true);
    try {
      final plants = await db.getAllPlants();
      setState(() {
        _plants = plants;
        _loading = false;
      });
    } catch (e) {
      debugPrint('Error cargando plantas: $e');
      setState(() => _loading = false);
    }
  }

  Future<void> _deletePlant(Plant plant) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar planta'),
        content: Text('¿Estás seguro de eliminar "${plant.name}" de tu colección?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true && plant.id != null) {
      try {
        await db.deletePlant(plant.id!);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Planta eliminada'))
        );
        _loadPlants();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error eliminando: $e'))
        );
      }
    }
  }

  void _showPlantDetails(Plant plant) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Barra superior
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Imagen
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      File(plant.imagePath),
                      width: double.infinity,
                      height: 200,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        height: 200,
                        color: Colors.grey[300],
                        child: const Icon(Icons.image_not_supported, size: 64),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Nombre
                  Text(
                    plant.name,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: kDarkGreen,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Nombre científico
                  Text(
                    plant.scientificName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontStyle: FontStyle.italic,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Confianza
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: kLightGreen.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Confianza: ${(plant.confidence * 100).toStringAsFixed(1)}%',
                      style: const TextStyle(
                        color: kDarkGreen,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Descripción
                  const Text(
                    'Descripción',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: kDarkGreen,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    plant.description,
                    style: const TextStyle(fontSize: 15, height: 1.5),
                  ),
                  const SizedBox(height: 16),

                  // Fecha de registro
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                      const SizedBox(width: 6),
                      Text(
                        'Registrada: ${plant.createdAt != null ? _formatDate(plant.createdAt!) : "Desconocida"}',
                        style: const TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Widget _buildPlantCard(Plant plant) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _showPlantDetails(plant),
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: Image.file(
                File(plant.imagePath),
                width: double.infinity,
                height: 140,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 140,
                  color: Colors.grey[300],
                  child: const Icon(Icons.image_not_supported, size: 48),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    plant.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: kDarkGreen,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    plant.scientificName,
                    style: const TextStyle(
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                      color: Colors.grey,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${(plant.confidence * 100).toStringAsFixed(0)}%',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: () => _deletePlant(plant),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundGreen,
      appBar: AppBar(
        title: const Text('Mi Colección'),
        backgroundColor: kDarkGreen,
        actions: [
          if (_plants.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _loadPlants,
              tooltip: 'Actualizar',
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _plants.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.yard, size: 80, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      const Text(
                        'Tu colección está vacía',
                        style: TextStyle(fontSize: 20, color: Colors.grey),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Empieza a identificar plantas',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Text(
                          '${_plants.length} planta${_plants.length != 1 ? "s" : ""} guardada${_plants.length != 1 ? "s" : ""}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: kDarkGreen,
                          ),
                        ),
                      ),
                      Expanded(
                        child: GridView.builder(
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.75,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                          ),
                          itemCount: _plants.length,
                          itemBuilder: (context, index) => _buildPlantCard(_plants[index]),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}