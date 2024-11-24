import 'package:flutter/material.dart';
import 'create_task_screen.dart';
import 'task.dart';
import 'search_bar.dart' as custom_search_bar;
import 'task_type_manager.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback toggleTheme;

  const HomeScreen({Key? key, required this.toggleTheme}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Task> tasks = [];
  List<String> taskTypes = ['Todos', 'Comum'];
  String selectedType = 'Todos'; 
  String pendingFilter = 'Todos'; 
  final TextEditingController searchController = TextEditingController();
  String searchQuery = '';

  void _addTask(Task task) {
    setState(() {
      tasks.add(task);
    });
  }

  void _onSearchChanged(String query) {
    setState(() {
      searchQuery = query.toLowerCase();
    });
  }

  void _showTypeManager() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TaskTypeManager(
          taskTypes: taskTypes,
          tasks: tasks,
          onTaskTypesChanged: (updatedTypes) {
            setState(() {
              taskTypes = updatedTypes;
            });
          },
          onTasksUpdated: (updatedTasks) {
            setState(() {
              tasks.clear();
              tasks.addAll(updatedTasks);
            });
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Task> filteredTasks = tasks.where((task) {
      bool matchesType =
          selectedType == 'Todos' || task.type == selectedType;
      bool matchesSearch = searchQuery.isEmpty ||
          task.title.toLowerCase().contains(searchQuery) ||
          task.description.toLowerCase().contains(searchQuery);
      bool matchesPendingFilter = pendingFilter == 'Todos' ||
          (pendingFilter == 'Pendentes' && !task.isComplete) ||
          (pendingFilter == 'Concluídos' && task.isComplete);

      return matchesType && matchesSearch && matchesPendingFilter;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tarefas'),
        actions: [
          IconButton(
            onPressed: widget.toggleTheme,
            icon: const Icon(Icons.brightness_6),
          ),
          IconButton(
            onPressed: _showTypeManager,
            icon: const Icon(Icons.category),
          ),
        ],
      ),
      body: Column(
        children: [
          
          custom_search_bar.SearchBar(
            searchController: searchController,
            onSearchChanged: _onSearchChanged,
          ),
          
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                
                DropdownButton<String>(
                  value: selectedType,
                  onChanged: (value) {
                    setState(() {
                      selectedType = value!;
                    });
                  },
                  items: taskTypes.map((type) {
                    return DropdownMenuItem<String>(
                      value: type,
                      child: Text(type),
                    );
                  }).toList(),
                ),

                DropdownButton<String>(
                  value: pendingFilter,
                  onChanged: (value) {
                    setState(() {
                      pendingFilter = value!;
                    });
                  },
                  items: ['Todos', 'Pendentes', 'Concluídos'].map((filter) {
                    return DropdownMenuItem<String>(
                      value: filter,
                      child: Text(filter),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          filteredTasks.isEmpty
              ? Expanded(
                  child: Center(
                    child: const Text(
                      'Nenhuma tarefa encontrada.',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                )
              : Expanded(
                  child: ListView.builder(
                    itemCount: filteredTasks.length,
                    itemBuilder: (context, index) {
                      final task = filteredTasks[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                            vertical: 5, horizontal: 10),
                        child: ListTile(
                          leading: Checkbox(
                            value: task.isComplete,
                            onChanged: (value) {
                              setState(() {
                                task.isComplete = value!;
                              });
                            },
                          ),
                          title: Text(task.title),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                task.description.length > 50
                                    ? '${task.description.substring(0, 50)}...'
                                    : task.description,
                              ),
                              Text(
                                '${task.dateTime}',
                                style: const TextStyle(fontSize: 12),
                              ),
                              Text(
                                'Tipo: ${task.type}',
                                style: const TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                          isThreeLine: true,
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () async {
                                  final updatedTask =
                                      await Navigator.push<Task>(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => CreateTaskScreen(
                                        task: task,
                                        taskTypes: taskTypes,
                                      ),
                                    ),
                                  );
                                  if (updatedTask != null) {
                                    setState(() {
                                      tasks[index] = updatedTask;
                                    });
                                  }
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () async {
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        title: const Text('Excluir Tarefa'),
                                        content: const Text('Tem certeza que deseja excluir esta tarefa?'),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.pop(context),
                                            child: const Text('Cancelar'),
                                          ),
                                          TextButton(
                                            onPressed: () async {
                                              try {
                                                await FirebaseFirestore.instance
                                                  .collection('tasks')
                                                  .doc(task.id)
                                                  .delete();

                                              setState(() {
                                                tasks.removeAt(index);
                                              });

                                              ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(
                                                  content: Text('Tarefa excluída com sucesso!'),
                                                  backgroundColor: Colors.green,
                                                ),
                                              );
                                            } catch (e) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  content: Text('Erro ao excluir tarefa: $e'),
                                                  backgroundColor: Colors.red,
                                                ),
                                              );
                                            }
                                            Navigator.pop(context); // Fechar o diálogo
                                          },
                                          child: const Text('Excluir'),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                            ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final newTask = await Navigator.push<Task>(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  CreateTaskScreen(taskTypes: taskTypes),
            ),
          );
          if (newTask != null) {
            _addTask(newTask);
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
