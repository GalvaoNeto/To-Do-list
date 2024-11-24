import 'package:flutter/material.dart';

class ManageTaskTypesScreen extends StatefulWidget {
  final List<String> taskTypes;

  const ManageTaskTypesScreen({Key? key, required this.taskTypes}) : super(key: key);

  @override
  State<ManageTaskTypesScreen> createState() => _ManageTaskTypesScreenState();
}

class _ManageTaskTypesScreenState extends State<ManageTaskTypesScreen> {
  late List<String> _taskTypes;

  @override
  void initState() {
    super.initState();
    _taskTypes = List<String>.from(widget.taskTypes); 
  }

  void _editTaskType(int index) async {
    final editedType = await showDialog<String>(
      context: context,
      builder: (context) {
        final TextEditingController _typeController =
            TextEditingController(text: _taskTypes[index]);

        return AlertDialog(
          title: const Text('Editar Tipo de Tarefa'),
          content: TextField(
            controller: _typeController,
            decoration: const InputDecoration(labelText: 'Nome do Tipo'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), 
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                final newName = _typeController.text.trim();
                if (newName.isNotEmpty) {
                  Navigator.pop(context, newName);
                }
              },
              child: const Text('Salvar'),
            ),
          ],
        );
      },
    );

    if (editedType != null && editedType.isNotEmpty) {
      setState(() {
        _taskTypes[index] = editedType;
      });
    }
  }

  void _addNewType() async {
    final newType = await showDialog<String>(
      context: context,
      builder: (context) {
        final TextEditingController _typeController = TextEditingController();

        return AlertDialog(
          title: const Text('Adicionar Novo Tipo'),
          content: TextField(
            controller: _typeController,
            decoration: const InputDecoration(labelText: 'Nome do Tipo'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                final name = _typeController.text.trim();
                if (name.isNotEmpty) {
                  Navigator.pop(context, name);
                }
              },
              child: const Text('Salvar'),
            ),
          ],
        );
      },
    );

    if (newType != null && newType.isNotEmpty) {
      setState(() {
        _taskTypes.add(newType);
      });
    }
  }

  void _deleteType(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir Tipo'),
        content: const Text('Tem certeza que deseja excluir este tipo?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _taskTypes.removeAt(index); 
              });
              Navigator.pop(context);
            },
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gerenciar Tipos de Tarefas'),
      ),
      body: ListView.builder(
        itemCount: _taskTypes.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(_taskTypes[index]),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: () => _editTaskType(index),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _deleteType(index),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNewType,
        child: const Icon(Icons.add),
      ),
    );
  }
}
