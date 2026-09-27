import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../models/expense_model.dart';
import '../providers/expense_provider.dart';
import '../services/storage_service.dart';
import '../utils/categories.dart';
import '../widgets/glass_container.dart';

class AddExpenseScreen extends StatefulWidget {
  final Expense? existingExpense;

  const AddExpenseScreen({super.key, this.existingExpense});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  String _selectedCategory = kCategories.first.name;
  DateTime _selectedDate = DateTime.now();
  bool _isSaving = false;
  bool _isUploadingReceipt = false;

  // Receipt photo state: either a freshly picked local file, an existing
  // uploaded URL (when editing), or neither.
  File? _pickedReceipt;
  String? _existingReceiptUrl;
  bool _removeExistingReceipt = false;
  final _storageService = StorageService();

  bool get _isEditing => widget.existingExpense != null;
  bool get _hasReceipt =>
      _pickedReceipt != null || (_existingReceiptUrl != null && !_removeExistingReceipt);

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      final e = widget.existingExpense!;
      _titleController.text = e.title;
      _amountController.text = e.amount.toString();
      _noteController.text = e.note ?? '';
      _selectedCategory = e.category;
      _selectedDate = e.date;
      _existingReceiptUrl = e.receiptUrl;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF34D399),
              surface: Color(0xFF12181F),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _pickReceipt() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: const Color(0xFF12181F),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined, color: Colors.white70),
              title: const Text('Take a photo', style: TextStyle(color: Colors.white)),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined, color: Colors.white70),
              title: const Text('Choose from gallery', style: TextStyle(color: Colors.white)),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (source == null) return;

    try {
      final picked = await ImagePicker().pickImage(
        source: source,
        maxWidth: 1600,
        imageQuality: 70,
      );
      if (picked == null) return;
      setState(() {
        _pickedReceipt = File(picked.path);
        _removeExistingReceipt = false;
      });
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open camera/gallery. Please try again.')),
        );
      }
    }
  }

  void _removeReceipt() {
    setState(() {
      _pickedReceipt = null;
      _removeExistingReceipt = true;
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    final provider = context.read<ExpenseProvider>();

    try {
      // Upload the new receipt photo first (if one was picked), so the
      // expense document is only written once with its final receiptUrl.
      String? receiptUrl = _existingReceiptUrl;
      if (_removeExistingReceipt && _pickedReceipt == null) {
        receiptUrl = null;
      }
      if (_pickedReceipt != null) {
        setState(() => _isUploadingReceipt = true);
        receiptUrl = await _storageService.uploadReceipt(_pickedReceipt!);
        if (mounted) setState(() => _isUploadingReceipt = false);
      }

      final expense = Expense(
        id: widget.existingExpense?.id,
        title: _titleController.text.trim(),
        amount: double.parse(_amountController.text.trim()),
        category: _selectedCategory,
        date: _selectedDate,
        note: _noteController.text.trim(),
        receiptUrl: receiptUrl,
      );

      if (_isEditing) {
        await provider.updateExpense(expense);
      } else {
        await provider.addExpense(expense);
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      setState(() {
        _isSaving = false;
        _isUploadingReceipt = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not save expense. Please try again.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0.8, -0.6),
            radius: 1.4,
            colors: [Color(0xFF14261E), Color(0xFF0B0F14)],
            stops: [0.0, 0.7],
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 12, 20, 4),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                    Text(
                      _isEditing ? 'Edit Expense' : 'Add Expense',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                  child: Form(
                    key: _formKey,
                    child: GlassContainer(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Title', style: TextStyle(color: Colors.white70, fontSize: 13)),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _titleController,
                            style: const TextStyle(color: Colors.white),
                            decoration: _inputDecoration('e.g. Grocery shopping'),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter a title';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 18),
                          const Text('Amount (Rs.)', style: TextStyle(color: Colors.white70, fontSize: 13)),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _amountController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            style: const TextStyle(color: Colors.white),
                            decoration: _inputDecoration('0.00'),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter an amount';
                              }
                              final parsed = double.tryParse(value.trim());
                              if (parsed == null || parsed <= 0) {
                                return 'Enter a valid amount greater than 0';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 18),
                          const Text('Category', style: TextStyle(color: Colors.white70, fontSize: 13)),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: kCategories.map((cat) {
                              final isSelected = _selectedCategory == cat.name;
                              return GestureDetector(
                                onTap: () => setState(() => _selectedCategory = cat.name),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 150),
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? cat.color.withOpacity(0.22)
                                        : Colors.white.withOpacity(0.05),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: isSelected ? cat.color : Colors.white.withOpacity(0.1),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(cat.icon, size: 15, color: isSelected ? cat.color : Colors.white54),
                                      const SizedBox(width: 6),
                                      Text(
                                        cat.name,
                                        style: TextStyle(
                                          color: isSelected ? cat.color : Colors.white60,
                                          fontSize: 13,
                                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 18),
                          const Text('Date', style: TextStyle(color: Colors.white70, fontSize: 13)),
                          const SizedBox(height: 6),
                          InkWell(
                            onTap: _pickDate,
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.white.withOpacity(0.1)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.calendar_today, color: Color(0xFF34D399), size: 18),
                                  const SizedBox(width: 10),
                                  Text(
                                    '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),
                          const Text('Note (optional)', style: TextStyle(color: Colors.white70, fontSize: 13)),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _noteController,
                            maxLines: 3,
                            style: const TextStyle(color: Colors.white),
                            decoration: _inputDecoration('Add a note...'),
                          ),
                          const SizedBox(height: 18),
                          const Text('Receipt (optional)', style: TextStyle(color: Colors.white70, fontSize: 13)),
                          const SizedBox(height: 8),
                          _buildReceiptPicker(),
                          const SizedBox(height: 28),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _isSaving ? null : _save,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF34D399),
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              child: _isSaving
                                  ? Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                                        ),
                                        if (_isUploadingReceipt) ...[
                                          const SizedBox(width: 10),
                                          const Text('Uploading receipt...',
                                              style: TextStyle(color: Colors.black, fontSize: 13)),
                                        ],
                                      ],
                                    )
                                  : Text(
                                      _isEditing ? 'Update Expense' : 'Save Expense',
                                      style: const TextStyle(
                                          color: Colors.black, fontWeight: FontWeight.w600, fontSize: 16),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReceiptPicker() {
    if (!_hasReceipt) {
      return InkWell(
        onTap: _pickReceipt,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.1), style: BorderStyle.solid),
          ),
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.add_a_photo_outlined, color: Color(0xFF34D399), size: 22),
              SizedBox(height: 6),
              Text('Attach a receipt photo', style: TextStyle(color: Colors.white70, fontSize: 13)),
            ],
          ),
        ),
      );
    }

    final imageWidget = _pickedReceipt != null
        ? Image.file(_pickedReceipt!, height: 160, width: double.infinity, fit: BoxFit.cover)
        : Image.network(
            _existingReceiptUrl!,
            height: 160,
            width: double.infinity,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, progress) {
              if (progress == null) return child;
              return const SizedBox(
                height: 160,
                child: Center(child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF34D399))),
              );
            },
            errorBuilder: (context, error, stack) => Container(
              height: 160,
              alignment: Alignment.center,
              color: Colors.white.withOpacity(0.05),
              child: const Icon(Icons.broken_image_outlined, color: Colors.white38),
            ),
          );

    return Stack(
      children: [
        ClipRRect(borderRadius: BorderRadius.circular(12), child: imageWidget),
        Positioned(
          top: 8,
          right: 8,
          child: GestureDetector(
            onTap: _removeReceipt,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(color: Colors.black87, shape: BoxShape.circle),
              child: const Icon(Icons.close, color: Colors.white, size: 16),
            ),
          ),
        ),
        Positioned(
          bottom: 8,
          right: 8,
          child: GestureDetector(
            onTap: _pickReceipt,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text('Replace', style: TextStyle(color: Colors.white, fontSize: 12)),
            ),
          ),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
      filled: true,
      fillColor: Colors.white.withOpacity(0.05),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.08)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF34D399)),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }
}