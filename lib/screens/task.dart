class Task {
  String title;
  String description;
  String type;
  DateTime dateTime;
  bool isComplete;

  Task({
    required this.title,
    required this.description,
    required this.type,
    required this.dateTime,
    this.isComplete = false,
  });
}
