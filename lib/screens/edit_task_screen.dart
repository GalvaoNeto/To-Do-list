import 'package:flutter/material.dart';
import 'task.dart';

class EditTaskScreen extends StatefulWidget {
  final Task task;
  final List<String> taskTypes;

  const EditTaskScreen({Key? key, required this.task, required this.taskTypes})
      : super(key: key);

  @override
  State<EditTaskScreen> createState() => _EditTaskScreenState();
}

class _EditTaskScreenState extends State<EditTaskScreen> {
  late TextEditingController titleController;
  late TextEditingController descriptionController;
  late String selectedType;
  late DateTime selectedDate;
  late TimeOfDay selectedTime;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.task.title);
    descriptionController = TextEditingController(text: widget.task.description);
    selectedType = widget.task.type;
    selectedDate = widget.task.dateTime;
    selectedTime = TimeOfDay.fromDateTime(widget.task.dateTime);
  }

  Future<void> _selectDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
      setState(() {
        selectedDate = pickedDate;
      });
    }
  }

  Future<void> _selectTime() async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );
    if (pickedTime != null) {
      setState(() {
        selectedTime = pickedTime;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Tarefa'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Título'),
            ),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(labelText: 'Descrição'),
            ),
            DropdownButton<String>(
              value: selectedType,
              onChanged: (value) {
                setState(() {
                  selectedType = value!;
                });
              },
              items: widget.taskTypes.map((type) {
                return DropdownMenuItem<String>(
                  value: type,
                  child: Text(type),
                );
              }).toList(),
            ),
            Row(
              children: [
                Text('Data: ${selectedDate.toLocal()}'),
                IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: _selectDate,
                ),
              ],
            ),
            Row(
              children: [
                Text('Hora: ${selectedTime.format(context)}'),
                IconButton(
                  icon: const Icon(Icons.access_time),
                  onPressed: _selectTime,
                ),
              ],
            ),
            ElevatedButton(
              onPressed: () {
                final updatedTask = Task(
                  title: titleController.text,
                  description: descriptionController.text,
                  type: selectedType,
                  dateTime: DateTime(
                    selectedDate.year,
                    selectedDate.month,
                    selectedDate.day,
                    selectedTime.hour,
                    selectedTime.minute,
                  ),
                );
                Navigator.pop(context, updatedTask);
              },
              child: const Text('Salvar Alterações'),
            ),
          ],
        ),
      ),
    );
  }
}
