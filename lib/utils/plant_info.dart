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

// Mapa de información de plantas según la etiqueta detectada por YOLO
// ACTUALIZA ESTO con las clases reales de tu modelo
class PlantDatabase {
  static final Map<String, PlantInfo> plantInfo = {
    'garambullo': PlantInfo(
      commonName: 'Garambullo',
      scientificName: 'Myrtillocactus geometrizans',
      description:
          'El garambullo es un cactus columnar originario del altiplano mexicano. Produce pequeños frutos de color morado comestibles y ricos en antioxidantes. Es una planta muy resistente a la sequía y al calor.',
      care:
          'Requiere un suelo arenoso con buen drenaje. Evita el exceso de riego y las heladas prolongadas. Puede podarse para controlar su crecimiento.',
      lightNeeds: 'Pleno sol durante todo el día',
      waterNeeds: 'Riego escaso; solo cuando el sustrato esté completamente seco',
    ),

    'mezquite': PlantInfo(
      commonName: 'Mezquite',
      scientificName: 'Prosopis laevigata',
      description:
          'El mezquite es un árbol nativo de zonas áridas y semiáridas de México. Se caracteriza por su madera dura, su resistencia a la sequía y su capacidad para fijar nitrógeno al suelo. Produce vainas dulces aprovechables como alimento y forraje.',
      care:
          'Crece mejor en suelos secos o ligeramente alcalinos. No requiere fertilización. Podar ramas secas o dañadas ocasionalmente.',
      lightNeeds: 'Pleno sol',
      waterNeeds:
          'Riego muy bajo; sobrevive solo con lluvias estacionales una vez establecido',
    ),
  };


  static PlantInfo getInfo(String label) {
    // Si la etiqueta existe en el mapa, devuélvela
    if (plantInfo.containsKey(label.toLowerCase())) {
      return plantInfo[label.toLowerCase()]!;
    }
    
    // Si no existe, devolver información genérica
    return PlantInfo(
      commonName: label,
      scientificName: 'Desconocido',
      description: 'Planta detectada. Información no disponible en la base de datos.',
      care: 'Consulta con un experto para cuidados específicos.',
      lightNeeds: 'Varía según especie',
      waterNeeds: 'Varía según especie',
    );
  }
}