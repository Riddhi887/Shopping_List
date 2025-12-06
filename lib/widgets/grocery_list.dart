import 'package:flutter/material.dart';
import 'package:shopping_list/models/grocery_items.dart';
import 'package:shopping_list/widgets/new_item.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shopping_list/data/categories.dart';

class GroceryList extends StatefulWidget {
  const GroceryList({super.key});

  @override
  State<GroceryList> createState() => _GroceryListState();
}

class _GroceryListState extends State<GroceryList> {
  List<GroceryItem> _groceryItem = [];

  //we are initalizing a state using init state to send a get req to backend and get data as respose and the state should be maintained even after the restart or reload

  //initalize the state at start
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  //initially load the items if any present in the database : used async
  void _loadItems() async {
    //create url to fetch data from database
    final url = Uri.https(
      'flutter-prep-76f0c-default-rtdb.firebaseio.com',
      'shopping_list.json',
    );

    //send a get request to get the data
    final response = await http.get(url);

    //convert the console json data back to ui form
    final Map<String, dynamic> listData = json.decode(
      response.body,
    );

    //create a empty list of loadedItems on list and will add one by one into this list individually
    final List<GroceryItem> _loadedItems = [];

    //display item using loop from above map
    for (final item in listData.entries) {
      //create temporary category item to match the http req value with local memory data provided in grocer_item.dart
      final category = categories.entries
          .firstWhere(
            (catItem) => catItem.value.title == item.value['category'],
          )
          .value;

      //add the data
      _loadedItems.add(
        GroceryItem(
          id: item.key,
          name: item.value['name'],
          quantity: item.value['quantity'],
          category: category,
        ),
      );

      setState(() {
        _groceryItem = _loadedItems;
      });
      
    }

    print(response.body);
  }

  //get item to the empty list from the ui data use async and await
  void _addItem() async {
    final newItem = await Navigator.of(
      context,
    ).push<GroceryItem>(MaterialPageRoute(builder: (ctx) => const NewItem()));

    _loadItems(); //load data

    if (newItem == null) {
      return;
    }

    //add the synced item from ui to list and change the state or update the UI using the setState
    setState(() {
      _groceryItem.add(newItem);
    });
  }

  void removeItem(GroceryItem item) {
    setState(() {
      _groceryItem.remove(item);
    });
  }

  @override
  Widget build(BuildContext context) {
    //if no items are added
    Widget content = const Center(child: Text('Uh Oh! No items added yet.'));

    //if the items are added
    if (_groceryItem.isNotEmpty) {
      //ListView is use to build optimise list and List Tile provide Optimised way to display data
      //a flag telling which item velongs to which category

      content = ListView.builder(
        itemCount: _groceryItem.length, //to go through all items on the list,
        itemBuilder: (ctx, index) =>
            //Dismissible to swipe the items out or delete it takes value key to uniquely identify each item
            Dismissible(
              onDismissed: (direction) {
                removeItem(_groceryItem[index]);
              },
              key: ValueKey(_groceryItem[index].id),

              child: ListTile(
                title: Text(
                  _groceryItem[index].name,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                leading: Container(
                  width: 27,
                  height: 27,
                  color: _groceryItem[index]
                      .category
                      .color, //get the color of specific category from the category file
                ),

                trailing: Text(
                  _groceryItem[index].quantity.toString(),
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                //to display the quantity
              ),
            ),
      );
    }
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

      body: content,
    );
  }
}
