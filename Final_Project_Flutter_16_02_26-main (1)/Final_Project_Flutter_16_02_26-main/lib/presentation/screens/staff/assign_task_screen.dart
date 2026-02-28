// lib/presentation/screens/staff/assign_task_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hotel_management_app/providers/staff_provider.dart';
import 'package:hotel_management_app/data/models/staff_task_model.dart';
import 'package:hotel_management_app/data/models/staff_user_model.dart';

class AssignTaskScreen extends StatefulWidget {
  @override
  _AssignTaskScreenState createState() => _AssignTaskScreenState();
}

class _AssignTaskScreenState extends State<AssignTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _notesController = TextEditingController();

  StaffUser? _selectedStaff;
  String _selectedPriority = 'Medium';
  DateTime? _dueDate;

  List<StaffUser> _staffList = [];
  bool _isLoading = false;

  final List<String> _priorities = ['High', 'Medium', 'Low'];

  @override
  void initState() {
    super.initState();
    _loadStaffList();
  }

  Future<void> _loadStaffList() async {
    // You need to add a method to get all staff users
    // For now, we'll use demo data
    setState(() {
      _staffList = [
        StaffUser(id: 1, name: 'Rahul', email: 'man@g.com', password: '', role: 'Manager', phone: ''),
        StaffUser(id: 2, name: 'Sima', email: 'recep@g.com', password: '', role: 'Receptionist', phone: ''),
        StaffUser(id: 3, name: 'Karim', email: 'house@g.com', password: '', role: 'Housekeeping', phone: ''),
      ];
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDueDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _dueDate = picked);
    }
  }

  Future<void> _submitTask() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedStaff == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select staff member'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isLoading = true);

    final task = StaffTask(
      id: 0,
      staffId: _selectedStaff!.id,
      staffName: _selectedStaff!.name,
      title: _titleController.text,
      description: _descriptionController.text,
      assignedDate: DateTime.now(),
      dueDate: _dueDate,
      priority: _selectedPriority,
      status: 'Pending',
      notes: _notesController.text.isNotEmpty ? _notesController.text : null,
      assignedBy: Provider.of<StaffProvider>(context, listen: false).currentUser?.name,
    );

    final provider = Provider.of<StaffProvider>(context, listen: false);
    final success = await provider.assignTask(task);

    if (!mounted) return;

    setState(() => _isLoading = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Task assigned successfully'), backgroundColor: Colors.green),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(provider.error ?? 'Failed to assign task'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Assign New Task'),
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Staff Selection
              Text('Assign To', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              DropdownButton<StaffUser>(
                isExpanded: true,
                itemHeight: null, // 🔥 এটা add করো
                hint: Padding(
                  padding: EdgeInsets.all(12),
                  child: Text('Select Staff Member'),
                ),
                value: _selectedStaff,
                items: _staffList.map((staff) {
                  return DropdownMenuItem<StaffUser>(
                    value: staff,
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min, // 🔥 এটা খুব গুরুত্বপূর্ণ
                        children: [
                          Text(
                            staff.name,
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                          SizedBox(height: 2),
                          Text(
                            staff.role,
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _selectedStaff = value),
              ),
              SizedBox(height: 16),

              // Task Title
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Task Title',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.task),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter task title';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),

              // Description
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.description),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter description';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),

              // Priority and Due Date Row
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedPriority,
                      decoration: InputDecoration(
                        labelText: 'Priority',
                        border: OutlineInputBorder(),
                      ),
                      items: _priorities.map((p) {
                        return DropdownMenuItem(value: p, child: Text(p));
                      }).toList(),
                      onChanged: (value) => setState(() => _selectedPriority = value!),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: InkWell(
                      onTap: _selectDueDate,
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'Due Date',
                          border: OutlineInputBorder(),
                          suffixIcon: Icon(Icons.calendar_today),
                        ),
                        child: Text(
                          _dueDate == null
                              ? 'Select Date'
                              : '${_dueDate!.day}/${_dueDate!.month}/${_dueDate!.year}',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),

              // Notes (Optional)
              TextFormField(
                controller: _notesController,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: 'Additional Notes (Optional)',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 24),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitTask,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[800],
                    padding: EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text('ASSIGN TASK'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}