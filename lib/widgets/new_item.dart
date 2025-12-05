import 'package:flutter/material.dart';
import 'package:shopping_list/data/categories.dart';
import 'package:shopping_list/models/category.dart';
import 'package:shopping_list/models/grocery_items.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class NewItem extends StatefulWidget {
  const NewItem({super.key});

  @override
  State<NewItem> createState() {
    return _NewItemState();
  }
}

class _NewItemState extends State<NewItem> {
  final _formKey = GlobalKey<FormState>();
  var _enteredName = '';
  var _enteredQuantity = 1;
  var _enteredCategory = categories[Categories.vegetables]!;

  void _saveItem() {
    //checks if the form has the form key and will automatically reach out to the validator  of each form field
    if (_formKey.currentState!.validate()) {
      //save the entered value
      _formKey.currentState!.save();

      //to save the data on the backend (firebase) database we created using http request

      //first create a url using Uri class
      //this creates a url in firebase backend (1st url) and a subfolder (shopping_list)
      final url = Uri.https(
        'flutter-prep-76f0c-default-rtdb.firebaseio.com',
        'shopping_list.json',
      );

      //to add data to database we use POST method of http request
      http.post(
        url, //the one we created
        headers: {
          //metadata to be added in form of maps here tells what is the file format
          'Content-Type': 'application/json',
        },
        //encode is use to convert data automatically into json format we used map here
        body: json.encode(
          {
            //data to be encoded
            'name': _enteredName,
            'quantity': _enteredQuantity,
            'category': _enteredCategory.title,
          }
        )
      );

      //generate a new item and add to list
     /* Navigator.of(context).pop(
        GroceryItem(
          id: DateTime.now().toString(),
          name: _enteredName,
          quantity: _enteredQuantity,
          category: _enteredCategory,
        ),
      );*/
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add a new item')),

      // Wrap the form in a scroll view so the keyboard won't cause
      // an unbounded overflow when fields receive focus.
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  maxLength: 50,
                  decoration: const InputDecoration(label: Text('Name')),

                  //validator is to tell dart when to validate the form
                  validator: (value) {
                    if (value == null ||
                        value.isEmpty ||
                        value.trim().length <= 1 ||
                        value.trim().length > 50)
                    //.trim() to reove white spaces
                    {
                      return 'Name must be between 1-50 characters.';
                    }
                    return null;
                  },

                  //saving the entered value in the form
                  onSaved: (value) {
                    _enteredName = value!;
                  },
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: TextFormField(
                        decoration: InputDecoration(label: Text('Quantity')),
                        keyboardType: TextInputType.number,
                        initialValue: _enteredQuantity
                            .toString(), //set inital value

                        validator: (value) {
                          if (value == null ||
                              value.isEmpty ||
                              int.tryParse(value) == null ||
                              int.tryParse(value)! <= 0)
                          //.trim() to reove white spaces
                          {
                            return 'Quantity must be a valid number greater than zero.';
                          }
                          return null;
                        },

                        onSaved: (value) {
                          _enteredQuantity = int.parse(value!);
                        },
                      ),
                    ),

                    const SizedBox(width: 15),

                    Expanded(
                      child: DropdownButtonFormField<Category>(
                        initialValue: _enteredCategory,
                        items: [
                          for (final category in categories.entries)
                            DropdownMenuItem<Category>(
                              value: category.value,
                              child: Row(
                                children: [
                                  Container(
                                    width: 20,
                                    height: 20,
                                    color: category.value.color,
                                  ),

                                  const SizedBox(width: 10),
                                  Text(category.value.title),
                                ],
                              ),
                            ),
                        ],
                        onChanged: (Category? value) {
                          // update selected category
                          setState(() {
                            _enteredCategory = value!;
                          });
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 25),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        _formKey.currentState!.reset();
                      },
                      child: Text(
                        'Reset',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),
                    const SizedBox(width: 15),
                    ElevatedButton(
                      onPressed: _saveItem,
                      child: Text(
                        'Add Item',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
