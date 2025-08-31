import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
// I'm assuming your custom snackbar is in this file.
// If not, replace it with ScaffoldMessenger.of(context).showSnackBar(...)
import 'package:crud_api/widgets/snackbar_message.dart';

class AddNewProductScreen extends StatefulWidget {
  const AddNewProductScreen({super.key});

  @override
  State<AddNewProductScreen> createState() => _AddNewProductScreenState();
}

class _AddNewProductScreenState extends State<AddNewProductScreen> {
  bool _addProductInProgress = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameTEController = TextEditingController();
  final TextEditingController _codeTEController = TextEditingController();
  final TextEditingController _priceTEController = TextEditingController();
  final TextEditingController _quantityTEController = TextEditingController();
  final TextEditingController _imageUrlTEController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add New Product')),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextFormField(
                  controller: _nameTEController,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    hintText: 'Product name',
                    labelText: 'Product name',
                  ),
                  validator: (String? value) {
                    if (value?.trim().isEmpty ?? true) {
                      return 'Enter product name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _codeTEController,
                  keyboardType: TextInputType.text, // Product codes can be alphanumeric
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    hintText: 'Product code',
                    labelText: 'Product code',
                  ),
                  validator: (String? value) {
                    if (value?.trim().isEmpty ?? true) {
                      return 'Enter product code';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _quantityTEController,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    hintText: 'Quantity',
                    labelText: 'Quantity',
                  ),
                  validator: (String? value) {
                    if (value?.trim().isEmpty ?? true) {
                      return 'Enter quantity';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _priceTEController,
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    hintText: 'Unit price',
                    labelText: 'Unit price',
                  ),
                  validator: (String? value) {
                    if (value?.trim().isEmpty ?? true) {
                      return 'Enter unit price';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _imageUrlTEController,
                  textInputAction: TextInputAction.done,
                  decoration: const InputDecoration(
                    hintText: 'Image Url',
                    labelText: 'Image Url',
                  ),
                  validator: (String? value) {
                    if (value?.trim().isEmpty ?? true) {
                      return 'Enter image URL';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: Visibility(
                    visible: _addProductInProgress == false,
                    replacement: const Center(
                      child: CircularProgressIndicator(),
                    ),
                    child: FilledButton(
                      onPressed: _onTapAddProductButton,
                      child: const Text('Add Product'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _onTapAddProductButton() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _addProductInProgress = true;
    });

    try {
      // Safely parse numbers to prevent crashes
      final int quantity = int.tryParse(_quantityTEController.text.trim()) ?? 0;
      final int unitPrice = int.tryParse(_priceTEController.text.trim()) ?? 0;

      Map<String, dynamic> requestBody = {
        "ProductName": _nameTEController.text.trim(),
        "ProductCode": _codeTEController.text.trim(), // Keep as string if it can have letters
        "Img": _imageUrlTEController.text.trim(),
        "Qty": quantity,
        "UnitPrice": unitPrice,
        "TotalPrice": quantity * unitPrice
      };

      Uri uri = Uri.parse('http://35.73.30.144:2008/api/v1/CreateProduct');
      final http.Response response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );


      if (!mounted) return;

      if (response.statusCode == 200) {
        final decodedJson = jsonDecode(response.body);
        if (decodedJson['status'] == 'success') {
          _clearTextFields();
          showSnackBarMessage(context, 'Product created successfully!');

        } else {
          showSnackBarMessage(context, decodedJson['data'] ?? 'Failed to create product.');
        }
      } else {

        showSnackBarMessage(context, 'Error: Could not add product. Status code: ${response.statusCode}');
      }
    } catch (e) {

      if (mounted) {
        showSnackBarMessage(context, 'An error occurred: $e');
      }
    } finally {

      setState(() {
        _addProductInProgress = false;
      });
    }
  }

  void _clearTextFields() {
    _nameTEController.clear();
    _codeTEController.clear();
    _priceTEController.clear();
    _quantityTEController.clear();
    _imageUrlTEController.clear();
  }

  @override
  void dispose() {
    _nameTEController.dispose();
    _priceTEController.dispose();
    _quantityTEController.dispose();
    _imageUrlTEController.dispose();
    _codeTEController.dispose();
    super.dispose();
  }
}