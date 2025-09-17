class Mascota {
  final int? id;
  final String nombre;
  final String especie;
  final int edad;
  final String dueno;
  final String? imagen; // ruta de la imagen

  Mascota({
    this.id,
    required this.nombre,
    required this.especie,
    required this.edad,
    required this.dueno,
    this.imagen,
  });

  factory Mascota.fromMap(Map<String, dynamic> map) {
    return Mascota(
      id: map['id'] as int?,
      nombre: map['nombre'] as String? ?? '',
      especie: map['especie'] as String? ?? '',
      edad: map['edad'] is int
          ? map['edad'] as int
          : int.tryParse(map['edad']?.toString() ?? '0') ?? 0,
      dueno: map['dueno'] as String? ?? '',
      imagen: map['imagen'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'especie': especie,
      'edad': edad,
      'dueno': dueno,
      'imagen': imagen,
    };
  }
}
