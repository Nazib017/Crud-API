import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:crud_api/models/product_model.dart';
import '../utils/urls.dart';

class UpdateProductScreen extends StatefulWidget {
  const UpdateProductScreen({super.key, required this.product});

  final ProductModel product;

  @override
  State<UpdateProductScreen> createState() => _UpdateProductScreenState();
}

class _UpdateProductScreenState extends State<UpdateProductScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameTEController = TextEditingController();
  final TextEditingController _codeTEController = TextEditingController();
  final TextEditingController _priceTEController = TextEditingController();
  final TextEditingController _quantityTEController = TextEditingController();
  final TextEditingController _imageUrlTEController = TextEditingController();

  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _nameTEController.text = widget.product.name;
    _codeTEController.text = widget.product.code.toString();
    _quantityTEController.text = widget.product.quantity.toString();
    _priceTEController.text = widget.product.unitPrice.toString();
    _imageUrlTEController.text = widget.product.image;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Update product')),
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
                  validator: (value) => (value?.trim().isEmpty ?? true) ? 'Enter a name' : null,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _codeTEController,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    hintText: 'Product code',
                    labelText: 'Product code',
                  ),
                  validator: (value) => (value?.trim().isEmpty ?? true) ? 'Enter a code' : null,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _quantityTEController,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    hintText: 'Quantity',
                    labelText: 'Quantity',
                  ),
                  validator: (value) => (value?.trim().isEmpty ?? true) ? 'Enter a quantity' : null,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _priceTEController,
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    hintText: 'Unit price',
                    labelText: 'Unit price',
                  ),
                  validator: (value) => (value?.trim().isEmpty ?? true) ? 'Enter a price' : null,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _imageUrlTEController,
                  decoration: const InputDecoration(
                    hintText: 'Image Url',
                    labelText: 'Image Url',
                  ),
                  validator: (value) => (value?.trim().isEmpty ?? true) ? 'Enter an image URL' : null,
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: Visibility(
                    visible: _isUpdating == false,
                    replacement: const Center(child: CircularProgressIndicator()),
                    child: FilledButton(
                      onPressed: _updateProduct,
                      child: const Text('Update'),
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

  Future<void> _updateProduct() async {
    if (_formKey.currentState!.validate() == false) {
      return;
    }

    setState(() {
      _isUpdating = true;
    });

    // 1. Get the correct URL with the product ID
    String updateUrl = Urls.updateProductUrl(widget.product.id);

    // 2. Prepare the request body from the controllers' text
    int quantity = int.parse(_quantityTEController.text);
    int unitPrice = int.parse(_priceTEController.text);

    Map<String, dynamic> requestBody = {
      "ProductName": _nameTEController.text.trim(),
      "ProductCode": _codeTEController.text.trim(),
      "Img": _imageUrlTEController.text.trim(),
      "Qty": quantity,
      "UnitPrice": unitPrice,
      "TotalPrice": quantity * unitPrice // Calculate total price as in the API
    };

    try {
      // 3. Make the POST request
      final response = await http.post(
        Uri.parse(updateUrl),
        headers: {'Content-Type': 'application/json'}, // Set the content type
        body: jsonEncode(requestBody), // Encode the map to a JSON string
      );

      // 4. Handle the response
      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Product updated successfully!')),
          );
          Navigator.pop(context, true); // Pop and return true to indicate success
        }
      } else {
        throw Exception('Failed to update product. Status: ${response.statusCode}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An error occurred: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUpdating = false;
        });
      }
    }
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