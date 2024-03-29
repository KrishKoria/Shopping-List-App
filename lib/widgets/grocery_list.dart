import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shopping_list_app/data/categories.dart';
import 'package:shopping_list_app/models/grocery_item.dart';
import 'package:http/http.dart' as http;

class GroceryList extends StatefulWidget {
  const GroceryList({super.key});

  @override
  State<GroceryList> createState() => _GroceryListState();
}

class _GroceryListState extends State<GroceryList> {
  List<GroceryItem> _groceryItems = [];
  var _isLoading = true;
  String? _hasErroredOut;
  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  void _loadItems() async {
    final url = Uri.https(
      'shopping-list-app-ee595-default-rtdb.asia-southeast1.firebasedatabase.app',
      'shopping-list.json',
    );
    try {
      final response = await http.get(url);
      if (response.statusCode >= 400) {
        setState(() {
          _hasErroredOut = 'Something went wrong!, Maybe Try again later.';
        });
      }
      if (response.body == 'null') {
        setState(() {
          _isLoading = false;
        });
        return;
      }
      final Map<String, dynamic> responseData = json.decode(response.body);
      final List<GroceryItem> loadedItems = [];
      for (final item in responseData.entries) {
        final category = categories.entries.firstWhere(
          (catItem) => catItem.value.name == item.value['category'],
        );
        final groceryItem = GroceryItem(
          id: item.key,
          name: item.value['name'],
          quantity: item.value['quantity'],
          category: category.value,
        );
        loadedItems.add(groceryItem);
      }
      setState(
        () {
          _groceryItems = loadedItems;
          _isLoading = false;
        },
      );
    } catch (error) {
      setState(() {
        _hasErroredOut = 'Something went wrong!, Maybe Try again later.';
      });
    }
  }

  void _addItem() async {
    final newItem =
        await Navigator.of(context).pushNamed('/new-item') as GroceryItem;
    _loadItems();

    setState(() {
      _groceryItems.add(newItem);
    });
  }

  void _deleteItem(GroceryItem item) async {
    final url = Uri.https(
      'shopping-list-app-ee595-default-rtdb.asia-southeast1.firebasedatabase.app',
      'shopping-list/${item.id}.json',
    );
    final index = _groceryItems.indexOf(item);
    setState(() {
      _groceryItems.remove(item);
    });
    final response = await http.delete(url);
    if (response.statusCode >= 400) {
      setState(
        () {
          _groceryItems.insert(index, item);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Error occurred while deleting item.'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              duration: Duration(seconds: 1),
            ),
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget content = const Center(
      child: Text("No Items Added Yet."),
    );
    if (_isLoading) {
      content = const Center(
        child: CircularProgressIndicator(),
      );
    }
    if (_groceryItems.isNotEmpty) {
      content = ListView.builder(
        itemCount: _groceryItems.length,
        itemBuilder: (context, index) => Dismissible(
          onDismissed: (direction) {
            _deleteItem(_groceryItems[index]);
          },
          key: ValueKey(_groceryItems[index].id),
          child: ListTile(
            leading: Container(
              width: 24,
              height: 24,
              color: _groceryItems[index].category.color,
            ),
            title: Text(_groceryItems[index].name),
            trailing: Text(
              _groceryItems[index].quantity.toString(),
            ),
          ),
        ),
      );
    }
    if (_hasErroredOut != null) {
      content = Center(
        child: Text(_hasErroredOut!),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Grocery List'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _addItem,
          ),
        ],
      ),
      body: content,
    );
  }
}
