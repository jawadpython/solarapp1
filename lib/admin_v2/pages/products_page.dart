import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:noor_energy/core/services/storage_service.dart';

class ProductsPage extends StatefulWidget {
  const ProductsPage({super.key});

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  final _firestore = FirebaseFirestore.instance;
  String _searchQuery = '';
  String _selectedCategory = 'All';

  final List<String> _categories = [
    'All',
    'Inverter',
    'Panel',
    'Battery',
    'Accessory',
    'Pump',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          _buildHeader(),
          Expanded(child: _buildProductsList()),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showProductDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Add Product'),
        backgroundColor: const Color(0xFF3A80BA),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Products Management',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search products...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: const Color(0xFFF1F5F9),
                  ),
                  onChanged: (value) => setState(() => _searchQuery = value),
                ),
              ),
              const SizedBox(width: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedCategory,
                    items: _categories.map((cat) {
                      return DropdownMenuItem(value: cat, child: Text(cat));
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) setState(() => _selectedCategory = value);
                    },
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProductsList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('products').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        var products = snapshot.data!.docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final matchesSearch = _searchQuery.isEmpty ||
              (data['model']?.toString().toLowerCase().contains(_searchQuery.toLowerCase()) ?? false) ||
              (data['brand']?.toString().toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);
          final matchesCategory = _selectedCategory == 'All' ||
              data['category'] == _selectedCategory;
          return matchesSearch && matchesCategory;
        }).toList();

        if (products.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'No products found',
                  style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                ),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  onPressed: () => _showProductDialog(context),
                  icon: const Icon(Icons.add),
                  label: const Text('Add First Product'),
                ),
              ],
            ),
          );
        }

        return GridView.builder(
          padding: const EdgeInsets.all(24),
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 350,
            childAspectRatio: 0.75,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: products.length,
          itemBuilder: (context, index) {
            final doc = products[index];
            final data = doc.data() as Map<String, dynamic>;
            return _ProductCard(
              docId: doc.id,
              data: data,
              onEdit: () => _showProductDialog(context, docId: doc.id, data: data),
              onDelete: () {
                _handleDeleteProduct(doc.id, data: Map<String, dynamic>.from(data));
              },
            );
          },
        );
      },
    );
  }

  void _showProductDialog(BuildContext context, {String? docId, Map<String, dynamic>? data}) {
    showDialog(
      context: context,
      builder: (dialogContext) => _ProductFormDialog(
        docId: docId,
        initialData: data,
        onSave: (productData, imageFile) async {
          String? imageUrl = data?['imageUrl'];
          String targetDocId = docId ?? '';

          if (targetDocId.isEmpty) {
            final ref = await _firestore.collection('products').add({
              ...productData,
              'imageUrl': null,
            });
            targetDocId = ref.id;
          }

          if (imageFile != null) {
            final path = StorageService.instance.generateProductImagePath(
              targetDocId,
              imageFile.name,
            );
            imageUrl = await StorageService.instance.uploadImage(
              file: imageFile,
              path: path,
              overwrite: true,
            );
          }

          final finalData = {...productData, 'imageUrl': imageUrl};

          await _firestore.collection('products').doc(targetDocId).update(finalData);

          if (mounted && dialogContext.mounted) Navigator.pop(dialogContext);
        },
        onDeleteProduct: docId != null && data != null
            ? () async {
                final nav = Navigator.of(dialogContext);
                final deleted =
                    await _handleDeleteProduct(docId, data: Map<String, dynamic>.from(data));
                if (deleted && mounted) {
                  nav.pop();
                }
              }
            : null,
      ),
    );
  }

  /// Returns true if the product document was deleted.
  Future<bool> _handleDeleteProduct(
    String docId, {
    required Map<String, dynamic> data,
  }) async {
    final brand = data['brand']?.toString() ?? '';
    final model = data['model']?.toString() ?? '';
    final label = [brand, model].where((s) => s.isNotEmpty).join(' ');
    final displayName = label.isEmpty ? docId.substring(0, docId.length > 8 ? 8 : docId.length) : label;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete product'),
        content: Text(
          'Delete "$displayName"?\nThis removes the marketplace listing permanently.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm != true) return false;

    try {
      final imageUrl = data['imageUrl'] as String?;
      if (imageUrl != null &&
          imageUrl.isNotEmpty &&
          imageUrl.startsWith('http')) {
        await StorageService.instance.deleteImage(imageUrl);
      }
      await _firestore.collection('products').doc(docId).delete();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Deleted: $displayName'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return true;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not delete: $e'),
            backgroundColor: Colors.red.shade700,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return false;
    }
  }
}

class _ProductCard extends StatelessWidget {
  final String docId;
  final Map<String, dynamic> data;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ProductCard({
    required this.docId,
    required this.data,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final imageUrl = data['imageUrl'] as String?;
    final status = data['status'] as String? ?? 'Active';
    final isActive = status.toLowerCase() == 'active';

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Container(
              height: 140,
              width: double.infinity,
              color: const Color(0xFFF1F5F9),
              child: imageUrl != null && imageUrl.isNotEmpty
                  ? Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _buildPlaceholder(),
                    )
                  : _buildPlaceholder(),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF3A80BA).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          data['category'] ?? 'N/A',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF3A80BA),
                          ),
                        ),
                      ),
                      const Spacer(),
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: isActive ? Colors.green : Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    data['brand'] ?? '',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  Text(
                    data['model'] ?? 'Unnamed Product',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      if (data['powerKw'] != null)
                        Text(
                          '${data['powerKw']} kW',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF3A80BA),
                          ),
                        ),
                      const Spacer(),
                      IconButton(
                        tooltip: 'Edit product',
                        icon: const Icon(Icons.edit, size: 20),
                        onPressed: onEdit,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        tooltip: 'Delete product',
                        icon: const Icon(Icons.delete_outline, size: 20, color: Colors.red),
                        onPressed: onDelete,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Center(
      child: Icon(
        Icons.image_outlined,
        size: 48,
        color: Colors.grey[400],
      ),
    );
  }
}

class _ProductFormDialog extends StatefulWidget {
  final String? docId;
  final Map<String, dynamic>? initialData;
  final Future<void> Function(Map<String, dynamic> data, XFile? imageFile) onSave;
  final Future<void> Function()? onDeleteProduct;

  const _ProductFormDialog({
    this.docId,
    this.initialData,
    required this.onSave,
    this.onDeleteProduct,
  });

  @override
  State<_ProductFormDialog> createState() => _ProductFormDialogState();
}

class _ProductFormDialogState extends State<_ProductFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _brandController;
  late final TextEditingController _modelController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _powerController;
  late final TextEditingController _warrantyController;
  
  String _category = 'Inverter';
  String _status = 'Active';
  XFile? _selectedImage;
  String? _existingImageUrl;
  bool _isLoading = false;

  final List<String> _categories = ['Inverter', 'Panel', 'Battery', 'Accessory', 'Pump'];
  final List<String> _statuses = ['Active', 'Inactive', 'Out of Stock'];

  @override
  void initState() {
    super.initState();
    final data = widget.initialData;
    _brandController = TextEditingController(text: data?['brand'] ?? '');
    _modelController = TextEditingController(text: data?['model'] ?? '');
    _descriptionController = TextEditingController(text: data?['descriptionShort'] ?? '');
    _powerController = TextEditingController(text: data?['powerKw']?.toString() ?? '');
    _warrantyController = TextEditingController(text: data?['warranty'] ?? '');
    _category = data?['category'] ?? 'Inverter';
    _status = data?['status'] ?? 'Active';
    _existingImageUrl = data?['imageUrl'];
  }

  @override
  void dispose() {
    _brandController.dispose();
    _modelController.dispose();
    _descriptionController.dispose();
    _powerController.dispose();
    _warrantyController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final image = await StorageService.instance.pickImage();
    if (image != null) {
      setState(() => _selectedImage = image);
    }
  }

  Future<void> _runDeleteProduct() async {
    await widget.onDeleteProduct?.call();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final data = {
        'brand': _brandController.text.trim(),
        'model': _modelController.text.trim(),
        'category': _category,
        'descriptionShort': _descriptionController.text.trim(),
        'powerKw': double.tryParse(_powerController.text) ?? 0,
        'warranty': _warrantyController.text.trim(),
        'status': _status,
      };

      await widget.onSave(data, _selectedImage);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.docId != null;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: 500,
        constraints: const BoxConstraints(maxHeight: 700),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Color(0xFF3A80BA),
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.inventory_2, color: Colors.white),
                  const SizedBox(width: 12),
                  Text(
                    isEditing ? 'Edit Product' : 'Add New Product',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            // Form
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Image picker
                      Center(
                        child: GestureDetector(
                          onTap: _pickImage,
                          child: Container(
                            width: 150,
                            height: 150,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: const Color(0xFF3A80BA).withOpacity(0.3),
                                width: 2,
                                style: BorderStyle.solid,
                              ),
                            ),
                            child: _buildImagePreview(),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Center(
                        child: TextButton.icon(
                          onPressed: _pickImage,
                          icon: const Icon(Icons.upload),
                          label: Text(_selectedImage != null || _existingImageUrl != null 
                              ? 'Change Image' 
                              : 'Upload Image'),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Brand & Model
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _brandController,
                              decoration: _inputDecoration('Brand'),
                              validator: (v) => v?.isEmpty == true ? 'Required' : null,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _modelController,
                              decoration: _inputDecoration('Model'),
                              validator: (v) => v?.isEmpty == true ? 'Required' : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Category & Status
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _category,
                              decoration: _inputDecoration('Category'),
                              items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                              onChanged: (v) => setState(() => _category = v!),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _status,
                              decoration: _inputDecoration('Status'),
                              items: _statuses.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                              onChanged: (v) => setState(() => _status = v!),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Power & Warranty
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _powerController,
                              decoration: _inputDecoration('Power (kW)'),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _warrantyController,
                              decoration: _inputDecoration('Warranty'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Description
                      TextFormField(
                        controller: _descriptionController,
                        decoration: _inputDecoration('Description'),
                        maxLines: 3,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Actions
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
              ),
              child: Row(
                children: [
                  if (isEditing && widget.onDeleteProduct != null)
                    TextButton.icon(
                      onPressed: _isLoading ? null : _runDeleteProduct,
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      label: const Text('Delete product', style: TextStyle(color: Colors.red)),
                    ),
                  const Spacer(),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3A80BA),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : Text(isEditing ? 'Update' : 'Add Product'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePreview() {
    if (_selectedImage != null) {
      return FutureBuilder<List<int>>(
        future: _selectedImage!.readAsBytes(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Image.memory(
                snapshot.data! as dynamic,
                fit: BoxFit.cover,
                width: 150,
                height: 150,
              ),
            );
          }
          return _buildImagePlaceholder();
        },
      );
    }
    if (_existingImageUrl != null && _existingImageUrl!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Image.network(
          _existingImageUrl!,
          fit: BoxFit.cover,
          width: 150,
          height: 150,
          errorBuilder: (_, __, ___) => _buildImagePlaceholder(),
        ),
      );
    }
    return _buildImagePlaceholder();
  }

  Widget _buildImagePlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.add_photo_alternate, size: 40, color: Colors.grey[400]),
        const SizedBox(height: 8),
        Text(
          'Add Image',
          style: TextStyle(color: Colors.grey[600], fontSize: 12),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      filled: true,
      fillColor: Colors.white,
    );
  }
}
