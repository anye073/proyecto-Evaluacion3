class PaqueteModel {
  final int id;
  final String titulo;
  final String descripcion;

  PaqueteModel({
    required this.id,
    required this.titulo,
    required this.descripcion,
  });

  factory PaqueteModel.fromJson(Map<String, dynamic> json) => PaqueteModel(
        id: json["id"],
        titulo: json["titulo"],
        descripcion: json["descripcion"],
      );
}