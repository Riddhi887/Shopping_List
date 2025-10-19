import 'package:flutter/material.dart';
import 'package:shopping_list/data/dummy_items.dart';
import 'package:shopping_list/widgets/new_item.dart';

class GroceryList extends StatefulWidget {
  const GroceryList({super.key});

  @override
  State<GroceryList> createState() => _GroceryListState();
}

class _GroceryListState extends State<GroceryList> {
  void _addItem() {
    Navigator.of(context).push(MaterialPageRoute(builder: (ctx) => const NewItem(),
    ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Groceries'),
        actions: [
          IconButton(
            onPressed: _addItem,

            icon: const Icon(Icons.add_circle_outline_outlined),
          ),
        ],
      ),

      //ListView is use to build optimise list and List Tile provide Optimised way to display data
      //a flag telling which item velongs to which category
      body: ListView.builder(
        itemCount: groceryItems.length, //to go through all items on the list,
        itemBuilder: (ctx, index) => ListTile(
          title: Text(
            groceryItems[index].name,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          leading: Container(
            width: 27,
            height: 27,
            color: groceryItems[index]
                .category
                .color, //get the color of specific category from the category file
          ),

          trailing: Text(
            groceryItems[index].quantity.toString(),
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          //to display the quantity
        ),
      ),
    );
  }
}
