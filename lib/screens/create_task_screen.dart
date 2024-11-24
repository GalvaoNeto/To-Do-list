import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'task.dart';

class CreateTaskScreen extends StatefulWidget {
  final List<String> taskTypes;
  final Task? task; 

  const CreateTaskScreen({
    Key? key,
    required this.taskTypes,
    this.task,
  }) : super(key: key);

  @override
  State<CreateTaskScreen> createState() => _CreateTaskScreenState();
}

class _CreateTaskScreenState extends State<CreateTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  String? _selectedType;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  bool _isComplete = false;

  @override
  void initState() {
    super.initState();

    _titleController = TextEditingController(text: widget.task?.title ?? '');
    _descriptionController =
        TextEditingController(text: widget.task?.description ?? '');

    if (widget.task != null &&
        !widget.taskTypes.contains(widget.task!.type)) {
      _selectedType = widget.taskTypes.first; 
    } else {
      _selectedType = widget.task?.type ?? widget.taskTypes.first;
    }

    _selectedDate = widget.task?.dateTime;
    _selectedTime = widget.task != null
        ? TimeOfDay(
            hour: widget.task!.dateTime.hour,
            minute: widget.task!.dateTime.minute,
          )
        : null;
    _isComplete = widget.task?.isComplete ?? false;
  }

  Future<void> _saveTaskToFirestore(Task task) async {
  final firestore = FirebaseFirestore.instance;

  try {
    if (widget.task != null) {
      // Atualiza tarefa existente
      await firestore.collection('tasks').doc(widget.task!.id).update(task.toMap());
    } else {
      // Cria nova tarefa e salva o ID gerado automaticamente
      final docRef = await firestore.collection('tasks').add(task.toMap());
      task.id = docRef.id; // Atualiza o ID da tarefa criada
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(widget.task != null
            ? 'Tarefa atualizada com sucesso!'
            : 'Tarefa criada com sucesso!'),
        backgroundColor: Colors.green,
      ),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Erro ao salvar tarefa: $e'),
        backgroundColor: Colors.red,
      ),
    );
  }
}


  Future<void> _deleteTaskFromFirestore() async {
  if (widget.task == null || widget.task!.id.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Erro: Tarefa inválida ou sem ID.'),
        backgroundColor: Colors.red,
      ),
    );
    return;
  }

  final firestore = FirebaseFirestore.instance;

  try {
    await firestore.collection('tasks').doc(widget.task!.id).delete();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Tarefa excluída com sucesso!'),
        backgroundColor: Colors.green,
      ),
    );
    Navigator.pop(context);
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Erro ao excluir tarefa: $e'),
        backgroundColor: Colors.red,
      ),
    );
  }
}


  void _submitTask(BuildContext context) {
    if (_formKey.currentState!.validate() &&
        _selectedType != null &&
        _selectedDate != null &&
        _selectedTime != null) {
      final dateTime = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _selectedTime!.hour,
        _selectedTime!.minute,
      );

      final task = Task(
        id: widget.task?.id ?? '', 
        title: _titleController.text,
        description: _descriptionController.text,
        type: _selectedType!,
        dateTime: dateTime,
        isComplete: _isComplete,
      );

      _saveTaskToFirestore(task);

      Navigator.pop(context, task); 
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, preencha todos os campos.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.task == null ? 'Criar Nova Tarefa' : 'Editar Tarefa'),
        actions: widget.task != null
            ? [
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Excluir Tarefa'),
                        content: const Text(
                            'Tem certeza que deseja excluir esta tarefa?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancelar'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context); 
                              _deleteTaskFromFirestore(); 
                            },
                            child: const Text('Excluir'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ]
            : null,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Título'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'O título é obrigatório.';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Descrição'),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'A descrição é obrigatória.';
                  }
                  return null;
                },
              ),
              DropdownButtonFormField<String>(
                value: _selectedType,
                decoration: const InputDecoration(labelText: 'Tipo'),
                items: widget.taskTypes
                    .map((type) =>
                        DropdownMenuItem(value: type, child: Text(type)))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedType = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Selecione um tipo.';
                  }
                  return null;
                },
              ),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _selectedDate == null
                          ? 'Sem data selecionada'
                          : 'Data: ${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                    ),
                  ),
                  TextButton(
                    onPressed: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate ?? DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2100),
                      );
                      if (date != null) {
                        setState(() {
                          _selectedDate = date;
                        });
                      }
                    },
                    child: const Text('Selecionar Data'),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _selectedTime == null
                          ? 'Sem horário selecionado'
                          : 'Hora: ${_selectedTime!.hour}:${_selectedTime!.minute.toString().padLeft(2, '0')}',
                    ),
                  ),
                  TextButton(
                    onPressed: () async {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: _selectedTime ?? TimeOfDay.now(),
                      );
                      if (time != null) {
                        setState(() {
                          _selectedTime = time;
                        });
                      }
                    },
                    child: const Text('Selecionar Hora'),
                  ),
                ],
              ),
              Row(
                children: [
                  Checkbox(
                    value: _isComplete,
                    onChanged: (value) {
                      setState(() {
                        _isComplete = value ?? false;
                      });
                    },
                  ),
                  const Text('Tarefa Concluída'),
                ],
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => _submitTask(context),
                child: const Text('Salvar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
