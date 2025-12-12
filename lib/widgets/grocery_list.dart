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
  var _isLoading = true;

  String? error; //it should be in string if it is notnull or else its var

  //we are initalizing a state using init state to send a get req to backend and get data as respose and the state should be maintained even after the restart or reload

  //initalize the state at start
  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  //initially load the items if any present in the database : used async
  void _loadItems() async {
    //create url to fetch data from database
    final url = Uri.https(
      'flutter-prep-76f0c-default-rtdb.firebaseio.com',
      'shopping_list.json',
    );

    try {
      //send a get request to get the data
      final response = await http.get(url);

      print(response.statusCode);
      if (response.statusCode >= 400) {
        setState(() {
          error = "Failed to fetch data. Please try again later.";
        });
      }

      //if database is empty it returns `null` as the body
      //all items deleted from list then we see loading state due error as data being null there to solve this
      print(response.body);
      if (response.body == 'null') {
        setState(() {
          _groceryItem = [];
          _isLoading = false;
        });
        return;
      }

      //convert the console json data back to ui form
      final Map<String, dynamic> listData = json.decode(response.body);

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
      }

      setState(() {
        _groceryItem = _loadedItems;
        _isLoading = false;
      });

      // useful for debugging
      // print(response.body);
    } catch (e) {
      setState(() {
        error = 'Something went wrong. Please try again.';
        _isLoading = false;
      });
    }

    //if error occurs find the status code
  }

  //get item to the empty list from the ui data use async and await
  void _addItem() async {
    final newItem = await Navigator.of(
      context,
    ).push<GroceryItem>(MaterialPageRoute(builder: (ctx) => const NewItem()));

    if (newItem == null) {
      return;
    }

    //add the synced item from ui to list and change the state or update the UI using the setState
    setState(() {
      _groceryItem.add(newItem);
    });
  }

  void removeItem(GroceryItem item) async {
    //get the index
    final index = _groceryItem.indexOf(item);

    //set the state
    setState(() {
      _groceryItem.remove(item);
    });

    final url = Uri.https(
      'flutter-prep-76f0c-default-rtdb.firebaseio.com',
      'shopping_list/${item.id}.json', // target specific item from shopping list and get id
    );

    //send a delete request
    final response = await http.delete(url);

    //if error occurs add back the item
    if (response.statusCode >= 400) {
      //add back the item
      setState(() {
        _groceryItem.insert(index, item);
      });

      //show error snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Failed to delete item. Please try again.',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.normal,
            ),
          ),
          backgroundColor: const Color.fromARGB(255, 231, 250, 236),
          duration: const Duration(seconds: 3),
        ),
      );
    } else {
      //show success snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${item.name} deleted successfully!',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
          backgroundColor: const Color.fromARGB(255, 231, 250, 236),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    //if no items are added
    Widget content = const Center(child: Text('Uh Oh! No items added yet.'));

    //show loading indicator while fetching
    if (_isLoading) {
      content = const Center(child: CircularProgressIndicator());
    }
    //if the items are added
    else if (_groceryItem.isNotEmpty) {
      //ListView is use to build optimise list and List Tile provide Optimised way to display data
      //a flag telling which item belongs to which category

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

    //if error is null or doesnot found any error
    if (error != null) {
      content = Center(child: Text(error!));
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
