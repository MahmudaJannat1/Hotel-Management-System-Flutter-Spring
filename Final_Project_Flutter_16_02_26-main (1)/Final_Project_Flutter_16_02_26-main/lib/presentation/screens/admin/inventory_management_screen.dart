import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hotel_management_app/providers/inventory_provider.dart';
import 'package:hotel_management_app/presentation/widgets/common_drawer.dart';
import 'package:hotel_management_app/presentation/widgets/loading_indicator.dart';
import 'package:hotel_management_app/presentation/widgets/error_widget.dart';
import 'package:hotel_management_app/core/routes/app_routes.dart';
import 'package:hotel_management_app/core/utils/currency_formatter.dart';
import 'package:hotel_management_app/presentation/screens/admin/add_edit_inventory_screen.dart';

import '../../../data/models/inventory_model.dart';

class InventoryManagementScreen extends StatefulWidget {
  @override
  _InventoryManagementScreenState createState() => _InventoryManagementScreenState();
}

class _InventoryManagementScreenState extends State<InventoryManagementScreen> {
  String _selectedFilter = 'all';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  final int _hotelId = 1; // Current hotel ID

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadItems();
    });
  }

  Future<void> _loadItems() async {
    final provider = Provider.of<InventoryProvider>(context, listen: false);
    await provider.loadAllItems(_hotelId);
  }

  List<InventoryItem> _getFilteredItems(List<InventoryItem> items) {
    List<InventoryItem> filtered = List.from(items);

    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((item) {
        return item.itemName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            item.itemCode.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            item.category.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }

    switch (_selectedFilter) {
      case 'low_stock':
        filtered = filtered.where((i) => i.status == 'LOW_STOCK').toList();
        break;
      case 'out_of_stock':
        filtered = filtered.where((i) => i.status == 'OUT_OF_STOCK').toList();
        break;
      case 'expiring':
        filtered = filtered.where((i) => i.status == 'EXPIRING_SOON').toList();
        break;
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: false,
      drawer: CommonDrawer(currentRoute: AppRoutes.adminInventory),
      appBar: AppBar(
        toolbarHeight: 90,
        title: Text('Inventory Management'),
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadItems,
          ),
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddEditInventoryScreen(),
                ),
              ).then((_) => _loadItems());
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(100),
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.all(16),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search items...',
                    prefixIcon: Icon(Icons.search, color: Colors.white70),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                      icon: Icon(Icons.clear, color: Colors.white70),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _searchQuery = '');
                      },
                    )
                        : null,
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.2),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  style: TextStyle(color: Colors.white),
                  onChanged: (value) => setState(() => _searchQuery = value),
                ),
              ),
              Container(
                height: 50,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    _buildFilterChip('All', 'all', Icons.inventory),
                    _buildFilterChip('Low Stock', 'low_stock', Icons.warning, Colors.orange),
                    _buildFilterChip('Out of Stock', 'out_of_stock', Icons.error, Colors.red),
                    _buildFilterChip('Expiring Soon', 'expiring', Icons.timer, Colors.amber),
                  ],
                ),
              ),
              SizedBox(height: 8),
            ],
          ),
        ),
      ),
      body: Consumer<InventoryProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.items.isEmpty) {
            return LoadingIndicator(message: 'Loading inventory...');
          }

          if (provider.error != null) {
            return ErrorWidgetWithRetry(
              message: provider.error!,
              onRetry: _loadItems,
            );
          }

          final filteredItems = _getFilteredItems(provider.items);

          if (filteredItems.isEmpty) {
            return _buildEmptyState();
          }

          return RefreshIndicator(
            onRefresh: _loadItems,
            child: ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: filteredItems.length,
              itemBuilder: (context, index) {
                final item = filteredItems[index];
                return _buildItemCard(item, provider);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildFilterChip(String label, String value, IconData icon, [Color? color]) {
    bool isSelected = _selectedFilter == value;
    return Padding(
      padding: EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: isSelected ? Colors.white : (color ?? Colors.black54)),
            SizedBox(width: 4),
            Text(label),
          ],
        ),
        selected: isSelected,
        onSelected: (selected) => setState(() => _selectedFilter = selected ? value : 'all'),
        backgroundColor: Colors.grey[200],
        selectedColor: color ?? Theme.of(context).primaryColor,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : Colors.black,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildItemCard(InventoryItem item, InventoryProvider provider) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          provider.selectItem(item);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddEditInventoryScreen(item: item),
            ),
          ).then((_) => _loadItems());
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: item.statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.inventory,
                      color: item.statusColor,
                      size: 30,
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.itemName,
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 4),
                        Text(
                          '${item.category} • ${item.itemCode}',
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: item.statusColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      item.status.replaceAll('_', ' '),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: item.statusColor,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Quantity', style: TextStyle(fontSize: 11, color: Colors.grey[500])),
                        Text(
                          '${item.quantity} ${item.unit}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: item.quantity <= item.reorderLevel ? Colors.orange : Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Unit Price', style: TextStyle(fontSize: 11, color: Colors.grey[500])),
                        Text(
                          CurrencyFormatter.format(item.unitPrice),
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('Total Value', style: TextStyle(fontSize: 11, color: Colors.grey[500])),
                        Text(
                          CurrencyFormatter.format(item.totalValue),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (item.expiryDate != null) ...[
                SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                    SizedBox(width: 4),
                    Text(
                      'Expires: ${item.expiryDate!.day}/${item.expiryDate!.month}/${item.expiryDate!.year}',
                      style: TextStyle(
                        fontSize: 12,
                        color: item.expiryDate!.isBefore(DateTime.now().add(Duration(days: 30)))
                            ? Colors.orange
                            : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: Icon(Icons.edit, color: Colors.blue),
                    onPressed: () {
                      provider.selectItem(item);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddEditInventoryScreen(item: item),
                        ),
                      ).then((_) => _loadItems());
                    },
                  ),

                  IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteItem(context, item.id, provider),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _deleteItem(BuildContext context, int id, InventoryProvider provider) async {
    final confirmed = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Item'),
        content: Text('Are you sure you want to delete this item?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('CANCEL'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('DELETE', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await provider.deleteItem(id);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Item deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory, size: 80, color: Colors.grey[400]),
          SizedBox(height: 16),
          Text(
            'No items found',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            _searchQuery.isNotEmpty || _selectedFilter != 'all'
                ? 'Try changing filters'
                : 'Click + to add new item',
            style: TextStyle(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }


}