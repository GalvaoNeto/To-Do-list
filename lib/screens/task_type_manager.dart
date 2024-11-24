import 'package:cloud_firestore/cloud_firestore.dart';
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
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    taskTypes = List.from(widget.taskTypes);
    tasks = List.from(widget.tasks);
  }

  void _addTaskType() async {
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
            onPressed: () async {
              final newType = controller.text.trim();
              if (newType.isNotEmpty && !taskTypes.contains(newType)) {
                setState(() {
                  taskTypes.add(newType);
                });
                widget.onTaskTypesChanged(taskTypes);

                try {
                  await firestore.collection('taskTypes').doc(newType).set({
                    'name': newType,
                    'createdAt': FieldValue.serverTimestamp(),
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Tipo "$newType" adicionado com sucesso!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Erro ao adicionar tipo: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
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

  void _deleteTaskType(int index) async {
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
              onPressed: () async {
                try {
                  await firestore.collection('taskTypes').doc(typeToDelete).delete();
                  
                  final querySnapshot = await firestore
                      .collection('tasks')
                      .where('type', isEqualTo: typeToDelete)
                      .get();

                  for (var doc in querySnapshot.docs) {
                    await firestore.collection('tasks').doc(doc.id).update({
                      'type': 'Comum',
                    });

                    // Atualiza a lista local de tarefas
                    setState(() {
                      tasks = tasks.map((task) {
                        if (task.type == typeToDelete) {
                          return task.copyWith(type: 'Comum');
                        }
                        return task;
                      }).toList();
                    });
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Erro ao excluir tipo de tarefa ou atualizar tarefas: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  Navigator.pop(context);
                  return;
                }

                setState(() {
                  taskTypes.removeAt(index);
                });
                widget.onTaskTypesChanged(taskTypes);
                widget.onTasksUpdated(tasks);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Tipo excluído e tarefas atualizadas com sucesso!'),
                    backgroundColor: Colors.green,
                  ),
                );

                Navigator.pop(context);
              },
              child: const Text('Excluir'),
            ),
          ],
        );
      },
    );
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Não é possível excluir tipos padrão.'),
        backgroundColor: Colors.red,
      ),
    );
  }
}


void _editTaskType(int index) async {
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
            onPressed: () async {
              final newType = controller.text.trim();
              if (newType.isNotEmpty &&
                  !taskTypes.contains(newType) &&
                  taskTypes[index] != 'Todos' &&
                  taskTypes[index] != 'Comum') {
                final oldType = taskTypes[index];

                try {
                  await firestore
                      .collection('taskTypes')
                      .doc(oldType)
                      .delete();
                  await firestore
                      .collection('taskTypes')
                      .doc(newType)
                      .set({'name': newType, 'createdAt': FieldValue.serverTimestamp()});

                  final querySnapshot = await firestore
                      .collection('tasks')
                      .where('type', isEqualTo: oldType)
                      .get();
                  for (var doc in querySnapshot.docs) {
                    await firestore.collection('tasks').doc(doc.id).update({
                      'type': newType,
                    });


                    setState(() {
                      tasks = tasks.map((task) {
                        if (task.type == oldType) {
                          return task.copyWith(type: newType);
                        }
                        return task;
                      }).toList();
                    });
                  }

                  setState(() {
                    taskTypes[index] = newType;
                  });
                  widget.onTaskTypesChanged(taskTypes);
                  widget.onTasksUpdated(tasks);
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Erro ao editar tipo ou atualizar tarefas: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }

                Navigator.pop(context);
              }
            },
            child: const Text('Salvar'),
          ),
        ],
      );
    },
  );
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
