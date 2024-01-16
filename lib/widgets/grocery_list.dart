import 'package:flutter/material.dart';
import 'package:shopping_list_app/models/grocery_item.dart';

class GroceryList extends StatefulWidget {
  const GroceryList({super.key});

  @override
  State<GroceryList> createState() => _GroceryListState();
}

class _GroceryListState extends State<GroceryList> {
  final List<GroceryItem> _groceryItems = [];
  void _addItem() async {
    final newItem =
        await Navigator.of(context).pushNamed('/new-item') as GroceryItem;
    setState(() {
      _groceryItems.add(newItem);
    });
  }

  void _deleteItem(GroceryItem item) {
    setState(() {
      _groceryItems.remove(item);
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget content = const Center(
      child: Text("No Items Added Yet."),
    );
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
    // this is how we get the data from the new item screen using named routes
    // final routeArgs =
    //     ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    // if (routeArgs != null) {
    //   final newItems = [
    //     GroceryItem(
    //       id: DateTime.now().toString(),
    //       name: routeArgs['name'] ?? '',
    //       quantity: routeArgs['quantity'] ?? 1,
    //       category: routeArgs['category'] ?? categories[Categories.vegetables]!,
    //     ),
    //   ];
    //   setState(() {
    //     _groceryItems.addAll(newItems);
    //   });
    // }
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
