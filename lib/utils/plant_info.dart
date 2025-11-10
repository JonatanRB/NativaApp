class PlantInfo {
  final String commonName;
  final String scientificName;
  final String description;
  final String care;
  final String lightNeeds;
  final String waterNeeds;

  PlantInfo({
    required this.commonName,
    required this.scientificName,
    required this.description,
    required this.care,
    required this.lightNeeds,
    required this.waterNeeds,
  });
}

/// Base de datos de información de plantas
/// Las etiquetas deben coincidir EXACTAMENTE con las del YoloService
class PlantDatabase {
  static final Map<String, PlantInfo> plantInfo = {
    'garambullo': PlantInfo(
      commonName: 'Garambullo',
      scientificName: 'Myrtillocactus geometrizans',
      description:
          'El garambullo es un cactus columnar originario del altiplano mexicano. '
          'Produce pequeños frutos de color morado comestibles y ricos en antioxidantes. '
          'Es una planta muy resistente a la sequía y al calor.',
      care:
          'Requiere un suelo arenoso con buen drenaje. Evita el exceso de riego y '
          'las heladas prolongadas. Puede podarse para controlar su crecimiento.',
      lightNeeds: 'Pleno sol durante todo el día',
      waterNeeds: 'Riego escaso; solo cuando el sustrato esté completamente seco',
    ),

    'mesquite': PlantInfo(
      commonName: 'Mezquite',
      scientificName: 'Prosopis laevigata',
      description:
          'El mezquite es un árbol nativo de zonas áridas y semiáridas de México. '
          'Se caracteriza por su madera dura, su resistencia a la sequía y su capacidad '
          'para fijar nitrógeno al suelo. Produce vainas dulces aprovechables como '
          'alimento y forraje.',
      care:
          'Crece mejor en suelos secos o ligeramente alcalinos. No requiere fertilización. '
          'Podar ramas secas o dañadas ocasionalmente.',
      lightNeeds: 'Pleno sol',
      waterNeeds:
          'Riego muy bajo; sobrevive solo con lluvias estacionales una vez establecido',
    ),
  };

  /// Obtiene la información de una planta por su etiqueta
  /// Si no existe, devuelve información genérica
  static PlantInfo getInfo(String label) {
    // Convertir a minúsculas para evitar problemas de case-sensitivity
    final normalizedLabel = label.toLowerCase().trim();
    
    // Si la etiqueta existe en el mapa, devolverla
    if (plantInfo.containsKey(normalizedLabel)) {
      print('✅ Información encontrada para: $normalizedLabel');
      return plantInfo[normalizedLabel]!;
    }
    
    // Si no existe, devolver información genérica
    print('⚠️ No hay información para: $label, usando datos genéricos');
    return PlantInfo(
      commonName: _capitalize(label),
      scientificName: 'Desconocido',
      description: 'Planta detectada. Información no disponible en la base de datos.',
      care: 'Consulta con un experto para cuidados específicos.',
      lightNeeds: 'Varía según especie',
      waterNeeds: 'Varía según especie',
    );
  }

  /// Verifica si existe información para una etiqueta
  static bool hasInfo(String label) {
    return plantInfo.containsKey(label.toLowerCase().trim());
  }

  /// Obtiene todas las plantas disponibles en la base de datos
  static List<String> getAllPlantLabels() {
    return plantInfo.keys.toList();
  }

  /// Capitaliza la primera letra de un string
  static String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }
}