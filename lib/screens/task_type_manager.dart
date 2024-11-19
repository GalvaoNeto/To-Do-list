import 'package:flutter/material.dart';
import 'task.dart';

class TaskTypeManager extends StatefulWidget {
  final List<String> taskTypes;
  final List<Task> tasks; 
  final Function(List<String>) onTaskTypesChanged;
  final Function(List<Task>) onTasksUpdated;

  const TaskTypeManager({
    Key? key,
    required this.taskTypes,
    required this.tasks,
    required this.onTaskTypesChanged,
    required this.onTasksUpdated,
  }) : super(key: key);

  @override
  _TaskTypeManagerState createState() => _TaskTypeManagerState();
}

class _TaskTypeManagerState extends State<TaskTypeManager> {
  late List<String> taskTypes;
  late List<Task> tasks;

  @override
  void initState() {
    super.initState();
    taskTypes = List.from(widget.taskTypes);
    tasks = List.from(widget.tasks);
  }

  void _addTaskType() {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Criar Novo Tipo de Tarefa'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(labelText: 'Nome do Tipo'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                final newType = controller.text.trim();
                if (newType.isNotEmpty && !taskTypes.contains(newType)) {
                  setState(() {
                    taskTypes.add(newType);
                  });
                  widget.onTaskTypesChanged(taskTypes);
                }
                Navigator.pop(context);
              },
              child: const Text('Adicionar'),
            ),
          ],
        );
      },
    );
  }

  void _editTaskType(int index) {
    final controller = TextEditingController(text: taskTypes[index]);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Editar Tipo de Tarefa'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(labelText: 'Novo Nome'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                final newType = controller.text.trim();
                if (newType.isNotEmpty &&
                    !taskTypes.contains(newType) &&
                    taskTypes[index] != 'Todos' &&
                    taskTypes[index] != 'Comum') {
                  final oldType = taskTypes[index];
                  setState(() {
                    taskTypes[index] = newType;
                    for (var task in tasks) {
                      if (task.type == oldType) {
                        task.type = newType;
                      }
                    }
                  });
                  widget.onTaskTypesChanged(taskTypes);
                  widget.onTasksUpdated(tasks);
                }
                Navigator.pop(context);
              },
              child: const Text('Salvar'),
            ),
          ],
        );
      },
    );
  }

  void _deleteTaskType(int index) {
    final typeToDelete = taskTypes[index];
    if (typeToDelete != 'Todos' && typeToDelete != 'Comum') {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Excluir Tipo de Tarefa'),
            content: Text(
                'Tem certeza que deseja excluir o tipo "$typeToDelete"? Todas as tarefas deste tipo serão atualizadas para "Comum".'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    taskTypes.removeAt(index);
                    for (var task in tasks) {
                      if (task.type == typeToDelete) {
                        task.type = 'Comum';
                      }
                    }
                  });
                  widget.onTaskTypesChanged(taskTypes);
                  widget.onTasksUpdated(tasks);
                  Navigator.pop(context);
                },
                child: const Text('Excluir'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); 
    final isDarkMode = theme.brightness == Brightness.dark; 

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gerenciar Tipos de Tarefa'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _addTaskType,
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: taskTypes.length,
        itemBuilder: (context, index) {
          final type = taskTypes[index];
          final isDefaultType = type == 'Todos' || type == 'Comum';

          return ListTile(
            title: Text(
              type,
              style: TextStyle(
                color: isDefaultType
                    ? (isDarkMode ? Colors.grey[400] : Colors.grey[600]) 
                    : (isDarkMode ? Colors.white : Colors.black), 
                fontStyle: isDefaultType ? FontStyle.italic : FontStyle.normal,
                fontWeight: isDefaultType ? FontWeight.normal : FontWeight.bold,
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!isDefaultType)
                  IconButton(
                    icon: Icon(Icons.edit, color: isDarkMode ? Colors.white : Colors.black),
                    onPressed: () => _editTaskType(index),
                  ),
                if (!isDefaultType)
                  IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteTaskType(index),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
