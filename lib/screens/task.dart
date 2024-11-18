class Task {
  String title;
  String description;
  String type;
  DateTime dateTime;
  bool isComplete; // Adicionando o campo isComplete

  Task({
    required this.title,
    required this.description,
    required this.type,
    required this.dateTime,
    this.isComplete = false, // Valor padrão como falso
  });
}
