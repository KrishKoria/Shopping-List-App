import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shopping_list_app/data/categories.dart';
import 'package:shopping_list_app/models/category.dart';
import 'package:http/http.dart' as http;
import 'package:shopping_list_app/models/grocery_item.dart';

class NewItem extends StatefulWidget {
  const NewItem({super.key});

  @override
  State<NewItem> createState() => _NewItemState();
}

class _NewItemState extends State<NewItem> {
  final _formKey = GlobalKey<FormState>();
  var _enteredName = '';
  var _enteredQuantity = 1;
  var _selectedCategory = categories[Categories.vegetables]!;
  var _isSendingData = false;
  Future<void> _saveItem() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        _isSendingData = true;
      });
      // this is how we send the data from the new item screen using named routes
      // Navigator.of(context).pushNamed(
      //   '/',
      //   arguments: {
      //     'name': _enteredName,
      //     'quantity': _enteredQuantity,
      //     'category': _selectedCategory,
      //   },
      // );
      final url = Uri.https(
        'shopping-list-app-ee595-default-rtdb.asia-southeast1.firebasedatabase.app',
        'shopping-list.json',
      );
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(
          {
            'name': _enteredName,
            'quantity': _enteredQuantity,
            'category': _selectedCategory.name,
          },
        ),
      );
      Map<String, dynamic> responseData = json.decode(response.body);
      if (!context.mounted) {
        return;
      }
      Navigator.of(context).pop(
        GroceryItem(
          id: responseData['name'],
          name: _enteredName,
          quantity: _enteredQuantity,
          category: _selectedCategory,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Item'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Item Name',
                ),
                maxLength: 50,
                validator: (value) => value!.isEmpty ||
                        value.trim().length <= 1 ||
                        value.trim().length > 50
                    ? 'Must be between 1 and 50 characters and should not be empty'
                    : null,
                onSaved: (value) => _enteredName = value!,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Quantity',
                      ),
                      keyboardType: TextInputType.number,
                      maxLength: 3,
                      initialValue: _enteredQuantity.toString(),
                      validator: (value) => value!.isEmpty ||
                              int.tryParse(value) == null ||
                              int.tryParse(value)! <= 0
                          ? 'Must be a valid positive Number'
                          : null,
                      onSaved: (value) => _enteredQuantity = int.parse(value!),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: DropdownButtonFormField(
                      onChanged: (value) => setState(
                        () {
                          _selectedCategory = value!;
                        },
                      ),
                      value: _selectedCategory,
                      decoration: const InputDecoration(
                        label: Text('Category'),
                      ),
                      items: [
                        for (final category in categories.entries)
                          DropdownMenuItem(
                            value: category.value,
                            child: Row(
                              children: [
                                Container(
                                  width: 24,
                                  height: 24,
                                  color: category.value.color,
                                ),
                                const SizedBox(width: 8),
                                Text(category.value.name),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: !_isSendingData
                        ? () {
                            _formKey.currentState!.reset();
                          }
                        : null,
                    child: const Text("Reset"),
                  ),
                  ElevatedButton(
                    onPressed: !_isSendingData ? _saveItem : null,
                    child: _isSendingData
                        ? const SizedBox(
                            height: 16,
                            width: 16,
                            child: CircularProgressIndicator(),
                          )
                        : const Text('Add Item'),
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
