import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import 'package:hotel_management_app/providers/room_provider.dart';
import 'package:hotel_management_app/data/models/room_model.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/routes/app_routes.dart';
import '../../widgets/common_drawer.dart';

class AddEditRoomScreen extends StatefulWidget {
  final Room? room;

  const AddEditRoomScreen({super.key, this.room});

  @override
  State<AddEditRoomScreen> createState() => _AddEditRoomScreenState();
}

class _AddEditRoomScreenState extends State<AddEditRoomScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _roomNumberController;
  late TextEditingController _roomTypeController;
  late TextEditingController _floorController;
  late TextEditingController _priceController;
  late TextEditingController _maxOccupancyController;
  late TextEditingController _descriptionController;
  late TextEditingController _amenitiesController;

  final ImagePicker _picker = ImagePicker();
  final List<String> _roomImages = [];

  bool _isLoading = false;
  String _selectedStatus = 'AVAILABLE';

  final List<String> _statuses = [
    'AVAILABLE',
    'OCCUPIED',
    'MAINTENANCE',
    'RESERVED',
  ];

  // 🔥 FIX 1: Room Type Map - Update these IDs according to your database
// AddEditRoomScreen.dart e _roomTypeMap update koro:

  final Map<String, int> _roomTypeMap = {
    // ✅ Only these 2 types exist in database
    'Deluxe King Room': 1,      // ID 1
    'Standard Twin Room': 2,     // ID 2

    // ❌ Remove all other types or map them to existing ones
    // 'Standard Room': 2,          // Map to Standard Twin Room
    // 'Deluxe Room': 1,            // Map to Deluxe King Room
    // 'Deluxe Double Room': 1,     // Map to Deluxe King Room
    // 'Suite': 1,                  // Map to Deluxe King Room
    // 'Executive Suite': 1,        // Map to Deluxe King Room
    // 'Presidential Suite': 1,     // Map to Deluxe King Room
    // 'Family Room': 2,            // Map to Standard Twin Room
    // 'Twin Room': 2,              // Map to Standard Twin Room
    // 'Single Room': 2,            // Map to Standard Twin Room
  };

  List<String> get _roomTypes => _roomTypeMap.keys.toList();

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _loadRoomTypes(); // 🔥 FIX 2: Load room types from API
  }

  // 🔥 FIX 3: Separate initialization method
  void _initializeControllers() {
    _roomNumberController = TextEditingController(
      text: widget.room?.roomNumber ?? '',
    );
    _roomTypeController = TextEditingController(
      text: widget.room?.roomType ?? _roomTypes.first,
    );
    _floorController = TextEditingController(
      text: widget.room?.floor ?? '1',
    );
    _priceController = TextEditingController(
      text: widget.room?.price?.toString() ?? '',
    );
    _maxOccupancyController = TextEditingController(
      text: widget.room?.maxOccupancy?.toString() ?? '2',
    );
    _descriptionController = TextEditingController(
      text: widget.room?.description ?? '',
    );
    _amenitiesController = TextEditingController(
      text: widget.room?.amenities?.join(', ') ?? '',
    );

    if (widget.room != null) {
      _selectedStatus = widget.room!.status;
      if (_roomTypeMap.containsKey(widget.room!.roomType)) {
        _roomTypeController.text = widget.room!.roomType;
      }
      if (widget.room!.images.isNotEmpty) {
        _roomImages.addAll(widget.room!.images);
      }
    }
  }

  // 🔥 FIX 4: Load room types from API
  Future<void> _loadRoomTypes() async {
    // Optional: Fetch from API if needed
    // You can implement this if you have an API endpoint
  }

  @override
  void dispose() {
    _roomNumberController.dispose();
    _roomTypeController.dispose();
    _floorController.dispose();
    _priceController.dispose();
    _maxOccupancyController.dispose();
    _descriptionController.dispose();
    _amenitiesController.dispose();
    super.dispose();
  }

  bool get isEditing => widget.room != null;

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() => _roomImages.add(image.path));
    }
  }

  Future<void> _saveRoom() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final amenities = _amenitiesController.text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    // 🔥 FIX 5: Debug print
    final selectedRoomType = _roomTypeController.text;
    final roomTypeId = _roomTypeMap[selectedRoomType];

    print('📝 Selected room type: $selectedRoomType');
    print('📝 Room type ID: $roomTypeId');

    if (roomTypeId == null) {
      print('❌ Room type ID is null!');
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Invalid room type selected'), backgroundColor: Colors.red),
      );
      return;
    }

    final roomData = {
      'hotelId': 1,
      'roomNumber': _roomNumberController.text.trim(),
      'roomTypeId': roomTypeId,  // Now safe
      'floor': _floorController.text.trim(),
      'basePrice': double.parse(_priceController.text),
      'maxOccupancy': int.parse(_maxOccupancyController.text),
      'status': _selectedStatus,
      'description': _descriptionController.text.trim(),
      'amenities': amenities.join(','),
    };

    final provider = Provider.of<RoomProvider>(context, listen: false);
    final File? imageFile = _roomImages.isNotEmpty
        ? File(_roomImages.first)
        : null;

    final bool success = widget.room == null
        ? await provider.createRoomWithImage(roomData, imageFile)
        : await provider.updateRoomWithImage(
      widget.room!.id,
      roomData,
      imageFile,
    );

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (success) {
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Room saved successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.error ?? 'Failed to save room'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.room != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Room' : 'Add New Room'),
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      drawer: CommonDrawer(currentRoute: AppRoutes.adminRooms),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _roomInfoCard(),
              const SizedBox(height: 16),
              _roomImagesCard(),
              const SizedBox(height: 16),
              _statusCard(),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('CANCEL'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _saveRoom,
                      child: Text(isEditing ? 'UPDATE' : 'CREATE'),
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

  Widget _roomInfoCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextFormField(
              controller: _roomNumberController,
              decoration: const InputDecoration(labelText: 'Room Number *'),
              validator: (v) => v == null || v.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _roomTypeController.text,
              items: _roomTypes
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (v) => setState(() => _roomTypeController.text = v!),
              decoration: const InputDecoration(labelText: 'Room Type *'),
              validator: (v) => v == null ? 'Select room type' : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _roomImagesCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Room Images',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            if (_roomImages.isNotEmpty) ...[
              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _roomImages.length,
                  itemBuilder: (_, i) {
                    final imagePath = _roomImages[i];
                    if (imagePath.isEmpty) return const SizedBox();

                    final bool isNetwork =
                        imagePath.startsWith('/api') ||
                            imagePath.startsWith('http');

                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: isNetwork
                            ? Image.network(
                          'http://192.168.0.103:8080$imagePath',
                          width: 100,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            width: 100,
                            color: Colors.grey[300],
                            child: const Icon(Icons.error),
                          ),
                        )
                            : Image.file(
                          File(imagePath),
                          width: 100,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            width: 100,
                            color: Colors.grey[300],
                            child: const Icon(Icons.error),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ] else ...[
              Container(
                height: 100,
                width: double.infinity,
                color: Colors.grey[200],
                child: Center(
                  child: Text(
                    'No images added',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ),
              ),
            ],

            ElevatedButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.add),
              label: const Text('Add Image'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              value: _selectedStatus,
              items: _statuses
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (v) => setState(() => _selectedStatus = v!),
              decoration: const InputDecoration(labelText: 'Status'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
              maxLines: 3,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _priceController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(labelText: 'Price *'),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Price is required';
                }
                if (double.tryParse(value) == null) {
                  return 'Enter valid price';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _amenitiesController,
              decoration: const InputDecoration(
                labelText: 'Amenities',
                hintText: 'WiFi, AC, TV',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// import 'dart:io';
//
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:provider/provider.dart';
//
// import 'package:hotel_management_app/providers/room_provider.dart';
// import 'package:hotel_management_app/data/models/room_model.dart';
//
// class AddEditRoomScreen extends StatefulWidget {
//   final Room? room;
//
//   const AddEditRoomScreen({super.key, this.room});
//
//   @override
//   State<AddEditRoomScreen> createState() => _AddEditRoomScreenState();
// }
//
// class _AddEditRoomScreenState extends State<AddEditRoomScreen> {
//   final _formKey = GlobalKey<FormState>();
//
//   late TextEditingController _roomNumberController;
//   late TextEditingController _roomTypeController;
//   late TextEditingController _floorController;
//   late TextEditingController _priceController;
//   late TextEditingController _maxOccupancyController;
//   late TextEditingController _descriptionController;
//   late TextEditingController _amenitiesController;
//
//   final List<String> _statuses = [
//     'AVAILABLE',
//     'OCCUPIED',
//     'MAINTENANCE',
//     'RESERVED'
//   ];
//
//   final List<String> _roomTypes = [
//     'Standard Room',
//     'Deluxe Room',
//     'Deluxe Double Room',
//     'Suite',
//     'Standard Twin Room',
//     'Executive Suite',
//     'Presidential Suite',
//     'Family Room',
//     'Twin Room',
//     'Single Room',
//   ];
//
//   String _selectedStatus = 'AVAILABLE';
//   bool _isLoading = false;
//
//   final ImagePicker _picker = ImagePicker();
//   final List<String> _roomImages = [];
//
//   @override
//   void initState() {
//     super.initState();
//
//     _roomNumberController =
//         TextEditingController(text: widget.room?.roomNumber ?? '');
//     _roomTypeController =
//         TextEditingController(text: widget.room?.roomType ?? _roomTypes.first);
//     _floorController =
//         TextEditingController(text: widget.room?.floor ?? '1');
//     _priceController =
//         TextEditingController(text: widget.room?.price.toString() ?? '');
//     _maxOccupancyController =
//         TextEditingController(text: widget.room?.maxOccupancy.toString() ?? '2');
//     _descriptionController =
//         TextEditingController(text: widget.room?.description ?? '');
//     _amenitiesController = TextEditingController(
//       text: widget.room?.amenities.join(', ') ?? '',
//     );
//
//     if (widget.room != null && _roomTypes.contains(widget.room!.roomType)) {
//       _roomTypeController.text = widget.room!.roomType;
//     } else {
//       _roomTypeController.text = _roomTypes.first;
//     }
//   }
//
//   @override
//   void dispose() {
//     _roomNumberController.dispose();
//     _roomTypeController.dispose();
//     _floorController.dispose();
//     _priceController.dispose();
//     _maxOccupancyController.dispose();
//     _descriptionController.dispose();
//     _amenitiesController.dispose();
//     super.dispose();
//   }
//
//   Future<void> _pickImage() async {
//     final XFile? image =
//     await _picker.pickImage(source: ImageSource.gallery);
//     if (image != null) {
//       setState(() => _roomImages.add(image.path));
//     }
//   }
//
//   Future<void> _saveRoom() async {
//     if (_formKey.currentState!.validate()) {
//       setState(() => _isLoading = true);
//
//       final amenities = _amenitiesController.text
//           .split(',')
//           .map((e) => e.trim())
//           .where((e) => e.isNotEmpty)
//           .toList();
//
//       final roomData = {
//         'hotelId': 1,  // int
//         'roomNumber': _roomNumberController.text.trim(),  // String
//         'roomTypeId': 2,  // 🔥 IMPORTANT: int হতে হবে, roomType নামে না
//         'floor': _floorController.text.trim(),  // String
//         'basePrice': double.parse(_priceController.text),  // BigDecimal expects number
//         'maxOccupancy': int.parse(_maxOccupancyController.text),  // int
//         'status': _selectedStatus,  // String
//         'description': _descriptionController.text.trim(),  // String
//         'amenities': amenities.isNotEmpty ? amenities.join(',') : '',  // JSON string
//         // 'images': imageUrl,  // এইটা আলাদাভাবে send হবে
//       };
//
//       final roomProvider = Provider.of<RoomProvider>(context, listen: false);
//       bool success;
//
//       File? imageFile = _roomImages.isNotEmpty ? File(_roomImages.first) : null;
//
//       if (widget.room == null) {
//         success = await roomProvider.createRoomWithImage(roomData, imageFile);
//       } else {
//         success = await roomProvider.updateRoomWithImage(widget.room!.id, roomData, imageFile);
//       }
//
//       if (mounted) {
//         setState(() => _isLoading = false);
//         if (success) {
//           Navigator.pop(context, true);
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text('Room saved successfully'), backgroundColor: Colors.green),
//           );
//         }
//       }
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final isEditing = widget.room != null;
//
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(isEditing ? 'Edit Room' : 'Add New Room'),
//       ),
//       body: _isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             children: [
//               /// ROOM INFO
//               _roomInfoCard(context),
//
//               const SizedBox(height: 16),
//
//               /// IMAGES
//               _roomImagesCard(),
//
//               const SizedBox(height: 16),
//
//               /// STATUS & DETAILS
//               _statusCard(),
//
//               const SizedBox(height: 24),
//
//               /// ACTION BUTTONS
//               Row(
//                 children: [
//                   Expanded(
//                     child: OutlinedButton(
//                       onPressed: () => Navigator.pop(context),
//                       child: const Text('CANCEL'),
//                     ),
//                   ),
//                   const SizedBox(width: 12),
//                   Expanded(
//                     child: ElevatedButton(
//                       onPressed: _saveRoom,
//                       child: Text(isEditing ? 'UPDATE' : 'CREATE'),
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   /// ------------------ UI SECTIONS ------------------
//
//   Widget _roomInfoCard(BuildContext context) {
//     return Card(
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           children: [
//             TextFormField(
//               controller: _roomNumberController,
//               decoration: const InputDecoration(labelText: 'Room Number'),
//               validator: (v) =>
//               v == null || v.isEmpty ? 'Required' : null,
//             ),
//             const SizedBox(height: 12),
//             DropdownButtonFormField<String>(
//               value: _roomTypes.contains(_roomTypeController.text) ? _roomTypeController.text : null,
//               decoration: InputDecoration(
//                 labelText: 'Room Type *',
//                 border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
//                 prefixIcon: Icon(Icons.category),
//               ),
//               items: _roomTypes.map((type) {
//                 return DropdownMenuItem(
//                   value: type,
//                   child: Text(type),
//                 );
//               }).toList(),
//               onChanged: (value) {
//                 setState(() {
//                   _roomTypeController.text = value!;
//                 });
//               },
//               validator: (value) => value == null ? 'Please select room type' : null,
//               hint: Text('Select Room Type'),
//             )          ],
//         ),
//       ),
//     );
//   }
//
//   Widget _roomImagesCard() {
//     return Card(
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text('Room Images',
//                 style: TextStyle(fontWeight: FontWeight.bold)),
//             const SizedBox(height: 12),
//             if (_roomImages.isNotEmpty)
//               SizedBox(
//                 height: 100,
//                 child: ListView.builder(
//                   scrollDirection: Axis.horizontal,
//                   itemCount: _roomImages.length,
//                   itemBuilder: (_, i) => Padding(
//                     padding: const EdgeInsets.only(right: 8),
//                     child: Image.file(
//                       File(_roomImages[i]),
//                       width: 100,
//                       fit: BoxFit.cover,
//                     ),
//                   ),
//                 ),
//               ),
//             ElevatedButton.icon(
//               onPressed: _pickImage,
//               icon: const Icon(Icons.add),
//               label: const Text('Add Image'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _statusCard() {
//     return Card(
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           children: [
//             DropdownButtonFormField<String>(
//               value: _selectedStatus,
//               items: _statuses
//                   .map((e) => DropdownMenuItem(value: e, child: Text(e)))
//                   .toList(),
//               onChanged: (v) => setState(() => _selectedStatus = v!),
//               decoration: const InputDecoration(labelText: 'Status'),
//             ),
//             const SizedBox(height: 12),
//             TextFormField(
//               controller: _descriptionController,
//               decoration: const InputDecoration(labelText: 'Description'),
//               maxLines: 3,
//             ),
//             const SizedBox(height: 12),
//             TextFormField(
//               controller: _amenitiesController,
//               decoration: const InputDecoration(
//                 labelText: 'Amenities',
//                 hintText: 'WiFi, AC, TV',
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
