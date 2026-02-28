import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hotel_management_app/providers/inventory_provider.dart';
import 'package:hotel_management_app/data/models/inventory_model.dart';
import 'package:hotel_management_app/presentation/widgets/common_drawer.dart';
import 'package:hotel_management_app/core/routes/app_routes.dart';

class AddEditInventoryScreen extends StatefulWidget {
  final InventoryItem? item;

  const AddEditInventoryScreen({Key? key, this.item}) : super(key: key);

  @override
  _AddEditInventoryScreenState createState() => _AddEditInventoryScreenState();
}

class _AddEditInventoryScreenState extends State<AddEditInventoryScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _codeController;
  late TextEditingController _categoryController;
  late TextEditingController _descriptionController;
  late TextEditingController _quantityController;
  late TextEditingController _unitController;
  late TextEditingController _unitPriceController;
  late TextEditingController _reorderLevelController;
  late TextEditingController _maximumLevelController;
  late TextEditingController _locationController;
  late TextEditingController _supplierController;
  late TextEditingController _brandController;

  DateTime? _expiryDate;
  bool _isLoading = false;
  bool _isEditing = false;
  final int _hotelId = 1;

  final List<String> _categories = [
    'Food',
    'Beverage',
    'Cleaning',
    'Linen',
    'Amenities',
    'Stationery',
    'Maintenance',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _isEditing = widget.item != null;
  }

  void _initializeControllers() {
    _nameController = TextEditingController(text: widget.item?.itemName ?? '');
    _codeController = TextEditingController(text: widget.item?.itemCode ?? '');
    _categoryController = TextEditingController(text: widget.item?.category ?? '');
    _descriptionController = TextEditingController(text: widget.item?.description ?? '');
    _quantityController = TextEditingController(text: widget.item?.quantity.toString() ?? '');
    _unitController = TextEditingController(text: widget.item?.unit ?? 'pcs');
    _unitPriceController = TextEditingController(text: widget.item?.unitPrice.toString() ?? '');
    _reorderLevelController = TextEditingController(text: widget.item?.reorderLevel.toString() ?? '');
    _maximumLevelController = TextEditingController(text: widget.item?.maximumLevel?.toString() ?? '');
    _locationController = TextEditingController(text: widget.item?.location ?? '');
    _supplierController = TextEditingController(text: widget.item?.supplier ?? '');
    _brandController = TextEditingController(text: widget.item?.brand ?? '');

    _expiryDate = widget.item?.expiryDate;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    _categoryController.dispose();
    _descriptionController.dispose();
    _quantityController.dispose();
    _unitController.dispose();
    _unitPriceController.dispose();
    _reorderLevelController.dispose();
    _maximumLevelController.dispose();
    _locationController.dispose();
    _supplierController.dispose();
    _brandController.dispose();
    super.dispose();
  }

  Future<void> _selectExpiryDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _expiryDate ?? DateTime.now().add(Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365 * 2)),
    );

    if (picked != null) {
      setState(() => _expiryDate = picked);
    }
  }

  Future<void> _saveItem() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final itemData = {
        'itemName': _nameController.text.trim(),
        'itemCode': _codeController.text.trim(),
        'category': _categoryController.text.trim(),
        'description': _descriptionController.text.trim(),
        'quantity': int.parse(_quantityController.text),
        'unit': _unitController.text.trim(),
        'unitPrice': double.parse(_unitPriceController.text),
        'reorderLevel': int.parse(_reorderLevelController.text),
        'maximumLevel': _maximumLevelController.text.isNotEmpty
            ? int.parse(_maximumLevelController.text)
            : null,
        'location': _locationController.text.trim(),
        'supplier': _supplierController.text.trim(),
        'brand': _brandController.text.trim(),
        'expiryDate': _expiryDate?.toIso8601String().split('T')[0],
        'hotelId': _hotelId,
      };

      final provider = Provider.of<InventoryProvider>(context, listen: false);
      bool success;

      if (_isEditing) {
        success = await provider.updateItem(widget.item!.id, itemData);
      } else {
        success = await provider.createItem(itemData);
      }

      if (mounted) {
        setState(() => _isLoading = false);

        if (success) {
          Navigator.pop(context, true);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_isEditing ? 'Item updated' : 'Item created'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(provider.error ?? 'Failed to save'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: false,
      appBar: AppBar(
        toolbarHeight: 90,
        title: Text(_isEditing ? 'Edit Item' : 'Add New Item'),
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      drawer: CommonDrawer(currentRoute: AppRoutes.adminInventory),
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
                      Text('Basic Information', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      SizedBox(height: 16),

                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: 'Item Name *',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          prefixIcon: Icon(Icons.inventory),
                        ),
                        validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                      ),

                      SizedBox(height: 12),

                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _codeController,
                              decoration: InputDecoration(
                                labelText: 'Item Code *',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                prefixIcon: Icon(Icons.qr_code),
                              ),
                              validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              isExpanded: true,
                              value: _categories.contains(_categoryController.text)
                                  ? _categoryController.text
                                  : null,
                              decoration: InputDecoration(
                                labelText: 'Category *',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                prefixIcon: Icon(Icons.category),
                              ),
                              items: _categories.map((category) {
                                return DropdownMenuItem<String>(
                                  value: category,
                                  child: Text(
                                    category,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                );
                              }).toList(),
                              selectedItemBuilder: (context) {
                                return _categories.map((category) {
                                  return Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      category,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  );
                                }).toList();
                              },
                              onChanged: (value) {
                                setState(() => _categoryController.text = value!);
                              },
                              validator: (value) => value == null ? 'Select category' : null,
                              hint: Text('Select Category'),
                            ),
                          ),

                        ],
                      ),

                      SizedBox(height: 12),

                      TextFormField(
                        controller: _descriptionController,
                        decoration: InputDecoration(
                          labelText: 'Description',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          alignLabelWithHint: true,
                        ),
                        maxLines: 3,
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
                      Text('Stock Information', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      SizedBox(height: 16),

                      Row(
                        children: [
                          Expanded(
                            child: // আগের code:
                            TextFormField(
                              controller: _quantityController,
                              decoration: InputDecoration(
                                labelText: 'Quantity *',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                prefixIcon: Icon(Icons.numbers),
                              ),
                              keyboardType: TextInputType.number,

                              validator: (value) {
                                if (value == null || value.isEmpty) return 'Required';
                                if (int.tryParse(value) == null) return 'Invalid number';
                                return null;
                              },
                            )
                          ),

                          SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _unitController,
                              decoration: InputDecoration(
                                labelText: 'Unit *',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                prefixIcon: Icon(Icons.scale),
                              ),
                              validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 12),

                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _unitPriceController,
                              decoration: InputDecoration(
                                labelText: 'Unit Price *',
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
                            child: TextFormField(
                              controller: _reorderLevelController,
                              decoration: InputDecoration(
                                labelText: 'Reorder Level *',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                prefixIcon: Icon(Icons.warning),
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty) return 'Required';
                                if (int.tryParse(value) == null) return 'Invalid number';
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 12),

                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _maximumLevelController,
                              decoration: InputDecoration(
                                labelText: 'Maximum Level (Optional)',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                prefixIcon: Icon(Icons.trending_up),
                              ),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: InkWell(
                              onTap: _selectExpiryDate,
                              child: InputDecorator(
                                decoration: InputDecoration(
                                  labelText: 'Expiry Date',
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                  prefixIcon: Icon(Icons.calendar_today),
                                ),
                                child: Text(
                                  _expiryDate == null
                                      ? 'Select date'
                                      : '${_expiryDate!.day}/${_expiryDate!.month}/${_expiryDate!.year}',
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
                      Text('Additional Information', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      SizedBox(height: 16),

                      TextFormField(
                        controller: _locationController,
                        decoration: InputDecoration(
                          labelText: 'Storage Location',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          prefixIcon: Icon(Icons.location_on),
                        ),
                      ),

                      SizedBox(height: 12),

                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _supplierController,
                              decoration: InputDecoration(
                                labelText: 'Supplier',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                prefixIcon: Icon(Icons.business),
                              ),
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _brandController,
                              decoration: InputDecoration(
                                labelText: 'Brand',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                prefixIcon: Icon(Icons.branding_watermark),
                              ),
                            ),
                          ),
                        ],
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
                      onPressed: _saveItem,
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
}