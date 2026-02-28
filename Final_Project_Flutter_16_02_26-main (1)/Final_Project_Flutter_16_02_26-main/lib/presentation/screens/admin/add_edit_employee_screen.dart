import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hotel_management_app/providers/hr_provider.dart';
import 'package:hotel_management_app/data/models/employee_model.dart';
import 'package:hotel_management_app/presentation/widgets/common_drawer.dart';
import 'package:hotel_management_app/core/routes/app_routes.dart';

class AddEditEmployeeScreen extends StatefulWidget {
  final Employee? employee;

  const AddEditEmployeeScreen({Key? key, this.employee}) : super(key: key);

  @override
  _AddEditEmployeeScreenState createState() => _AddEditEmployeeScreenState();
}

class _AddEditEmployeeScreenState extends State<AddEditEmployeeScreen> {
  final _formKey = GlobalKey<FormState>();
  final int _hotelId = 1;

  late TextEditingController _employeeIdController;
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _positionController;
  late TextEditingController _basicSalaryController;
  late TextEditingController _joiningDateController;
  late TextEditingController _emergencyContactController;
  late TextEditingController _emergencyPhoneController;
  late TextEditingController _addressController;

  String _selectedEmploymentType = 'FULL_TIME';
  String _selectedEmploymentStatus = 'ACTIVE';
  int? _selectedDepartmentId;
  bool _isLoading = false;
  bool _isEditing = false;

  final List<String> _employmentTypes = ['FULL_TIME', 'PART_TIME', 'CONTRACT', 'INTERN'];
  final List<String> _employmentStatuses = ['ACTIVE', 'ON_LEAVE', 'TERMINATED', 'RESIGNED'];

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _isEditing = widget.employee != null;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDepartments();
    });
  }

  void _initializeControllers() {
    _employeeIdController = TextEditingController(text: widget.employee?.employeeId ?? '');
    _firstNameController = TextEditingController(text: widget.employee?.firstName ?? '');
    _lastNameController = TextEditingController(text: widget.employee?.lastName ?? '');
    _emailController = TextEditingController(text: widget.employee?.email ?? '');
    _phoneController = TextEditingController(text: widget.employee?.phone ?? '');
    _positionController = TextEditingController(text: widget.employee?.position ?? '');
    _basicSalaryController = TextEditingController(
      text: widget.employee?.basicSalary.toString() ?? '',
    );
    _joiningDateController = TextEditingController(
      text: widget.employee != null
          ? '${widget.employee!.joiningDate.day}/${widget.employee!.joiningDate.month}/${widget.employee!.joiningDate.year}'
          : '',
    );
    _emergencyContactController = TextEditingController(text: widget.employee?.emergencyContact ?? '');
    _emergencyPhoneController = TextEditingController(text: widget.employee?.emergencyPhone ?? '');
    _addressController = TextEditingController(text: widget.employee?.address ?? '');

    if (widget.employee != null) {
      _selectedEmploymentType = widget.employee!.employmentType;
      _selectedEmploymentStatus = widget.employee!.employmentStatus;
      _selectedDepartmentId = widget.employee!.departmentId;
    }
  }

  Future<void> _loadDepartments() async {
    if (!mounted) return;
    final hrProvider = Provider.of<HrProvider>(context, listen: false);
    await hrProvider.loadAllDepartments(_hotelId);
    print('Departments loaded: ${hrProvider.departments.length}');
    if (mounted) setState(() {});
  }



  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: widget.employee?.joiningDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (picked != null && mounted) {
      setState(() {
        _joiningDateController.text = '${picked.day}/${picked.month}/${picked.year}';
      });
    }
  }

  Future<void> _saveEmployee() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final List<String> dateParts = _joiningDateController.text.split('/');
      final joiningDate = DateTime(
        int.parse(dateParts[2]),
        int.parse(dateParts[1]),
        int.parse(dateParts[0]),
      );

      final employeeData = {
        'employeeId': _employeeIdController.text.trim(),
        'firstName': _firstNameController.text.trim(),
        'lastName': _lastNameController.text.trim(),
        'email': _emailController.text.trim(),
        'phone': _phoneController.text.trim(),
        'position': _positionController.text.trim(),
        'departmentId': _selectedDepartmentId,
        'employmentType': _selectedEmploymentType,
        'employmentStatus': _selectedEmploymentStatus,
        'basicSalary': double.parse(_basicSalaryController.text),
        'joiningDate': joiningDate.toIso8601String().split('T')[0],
        'emergencyContact': _emergencyContactController.text.trim(),
        'emergencyPhone': _emergencyPhoneController.text.trim(),
        'address': _addressController.text.trim(),
        'hotelId': _hotelId,
      };

      final hrProvider = Provider.of<HrProvider>(context, listen: false);
      bool success;

      if (_isEditing) {
        success = await hrProvider.updateEmployee(widget.employee!.id, employeeData);
      } else {
        success = await hrProvider.createEmployee(employeeData);
      }

      if (mounted) {
        setState(() => _isLoading = false);

        if (success) {
          Navigator.pop(context, true);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_isEditing ? 'Employee updated' : 'Employee created'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(hrProvider.error ?? 'Failed to save'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final hrProvider = Provider.of<HrProvider>(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(  // 🔥 Back Button
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);  // HR Dashboard এ ফিরে যাবে
          },
        ),
        title: Text(_isEditing ? 'Edit Employee' : 'Add New Employee'),
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
        elevation: 0,
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
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Personal Information', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      SizedBox(height: 16),

                      TextFormField(
                        controller: _employeeIdController,
                        decoration: InputDecoration(
                          labelText: 'Employee ID *',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          prefixIcon: Icon(Icons.badge),
                        ),
                        validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                      ),

                      SizedBox(height: 12),

                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _firstNameController,
                              decoration: InputDecoration(
                                labelText: 'First Name *',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                prefixIcon: Icon(Icons.person),
                              ),
                              validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _lastNameController,
                              decoration: InputDecoration(
                                labelText: 'Last Name *',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                prefixIcon: Icon(Icons.person),
                              ),
                              validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 12),

                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: 'Email *',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          prefixIcon: Icon(Icons.email),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Required';
                          if (!value.contains('@')) return 'Invalid email';
                          return null;
                        },
                      ),

                      SizedBox(height: 12),

                      TextFormField(
                        controller: _phoneController,
                        decoration: InputDecoration(
                          labelText: 'Phone *',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          prefixIcon: Icon(Icons.phone),
                        ),
                        validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 16),

              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Job Information', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      SizedBox(height: 16),

                      TextFormField(
                        controller: _positionController,
                        decoration: InputDecoration(
                          labelText: 'Position *',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          prefixIcon: Icon(Icons.work),
                        ),
                        validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                      ),

                      SizedBox(height: 12),

                      DropdownButtonFormField<int>(
                        value: _selectedDepartmentId != null &&
                            hrProvider.departments.any((d) => d.id == _selectedDepartmentId)
                            ? _selectedDepartmentId
                            : null,
                        decoration: InputDecoration(
                          labelText: 'Department *',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          prefixIcon: Icon(Icons.business),
                        ),
                        items: hrProvider.departments.isEmpty
                            ? [
                          DropdownMenuItem(
                            value: null,
                            child: Text('Loading departments...'),
                          )
                        ]
                            : hrProvider.departments.map((dept) {
                          return DropdownMenuItem(
                            value: dept.id,
                            child: Text(dept.name),
                          );
                        }).toList(),
                        onChanged: hrProvider.departments.isEmpty
                            ? null
                            : (value) => setState(() => _selectedDepartmentId = value),
                        validator: (value) {
                          if (hrProvider.departments.isEmpty) return 'Loading departments...';
                          return value == null ? 'Select department' : null;
                        },
                        hint: Text('Select Department'),  // 🔥 hint যোগ করুন
                      ),

                      SizedBox(height: 12),

                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              isExpanded: true,
                              value: _selectedEmploymentType,
                              decoration: InputDecoration(
                                labelText: 'Employment Type',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                prefixIcon: Icon(Icons.schedule),
                              ),
                              items: _employmentTypes.map((type) {
                                return DropdownMenuItem(
                                  value: type,
                                  child: Text(type.replaceAll('_', ' ')),
                                );
                              }).toList(),
                              onChanged: (value) => setState(() => _selectedEmploymentType = value!),
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              isExpanded: true,
                              value: _selectedEmploymentStatus,
                              decoration: InputDecoration(
                                labelText: 'Status',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                prefixIcon: Icon(Icons.info),
                              ),
                              items: _employmentStatuses.map((status) {
                                return DropdownMenuItem(
                                  value: status,
                                  child: Text(status.replaceAll('_', ' ')),
                                );
                              }).toList(),
                              onChanged: (value) => setState(() => _selectedEmploymentStatus = value!),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 12),

                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _basicSalaryController,
                              decoration: InputDecoration(
                                labelText: 'Basic Salary *',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                prefixIcon: Icon(Icons.attach_money),
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty) return 'Required';
                                if (double.tryParse(value) == null) return 'Invalid amount';
                                return null;
                              },
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: InkWell(
                              onTap: _selectDate,
                              child: InputDecorator(
                                decoration: InputDecoration(
                                  labelText: 'Joining Date *',
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                  prefixIcon: Icon(Icons.calendar_today),
                                ),
                                child: Text(
                                  _joiningDateController.text.isEmpty
                                      ? 'Select date'
                                      : _joiningDateController.text,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 16),

              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Emergency Contact', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      SizedBox(height: 16),

                      TextFormField(
                        controller: _emergencyContactController,
                        decoration: InputDecoration(
                          labelText: 'Contact Person',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          prefixIcon: Icon(Icons.person),
                        ),
                      ),

                      SizedBox(height: 12),

                      TextFormField(
                        controller: _emergencyPhoneController,
                        decoration: InputDecoration(
                          labelText: 'Emergency Phone',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          prefixIcon: Icon(Icons.phone),
                        ),
                        keyboardType: TextInputType.phone,
                      ),

                      SizedBox(height: 12),

                      TextFormField(
                        controller: _addressController,
                        decoration: InputDecoration(
                          labelText: 'Address',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          prefixIcon: Icon(Icons.location_on),
                        ),
                        maxLines: 2,
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 24),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide(color: Colors.grey),
                      ),
                      child: Text('CANCEL'),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _saveEmployee,
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Colors.blue[800],
                      ),
                      child: Text(_isEditing ? 'UPDATE' : 'CREATE'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _employeeIdController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _positionController.dispose();
    _basicSalaryController.dispose();
    _joiningDateController.dispose();
    _emergencyContactController.dispose();
    _emergencyPhoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }
}