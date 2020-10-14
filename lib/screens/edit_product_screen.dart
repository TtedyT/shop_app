import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/products_provider.dart';
import '../providers/product_provider.dart';

// enum MapKeysEnum {
//   Title,
//   Description,
//   Price,
//   ImageUrl,
// }

// final mapKeys = [];

class EditProductScreen extends StatefulWidget {
  static const ROUTE_NAME = "/edit-product";

  @override
  _EditProductScreenState createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _priceFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();
  final _imageUrlController = TextEditingController();
  final _imageUrlFocusNode = FocusNode();
  final _form = GlobalKey<FormState>();

  var _editedProduct = Product(
    id: null,
    title: "",
    price: 0,
    description: "",
    imageUrl: "",
  );

  var _initValues = {
    //mapKeys[MapKeysEnum.Title.index]
    "title": "",
    "description": "",
    "price": "",
    "imageUrl": "",
  };

  var _isInit = true;
  var _isLoading = false;

  @override
  void initState() {
    _imageUrlFocusNode.addListener(_updateImageUrl);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (_isInit) {
      final productId = ModalRoute.of(context).settings.arguments as String;
      if (_editMode(productId)) {
        _editedProduct = Provider.of<ProductsProvider>(context, listen: false)
            .findById(productId);
        _initValues = {
          "title": _editedProduct.title,
          "description": _editedProduct.description,
          "price": _editedProduct.price.toString(),
          // "imageUrl": _editedProduct.imageUrl
          // already doing it in the imageUrl controller
          "imageUrl": ""
        };
        _imageUrlController.text = _editedProduct.imageUrl;
      }
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _imageUrlController.removeListener(_updateImageUrl);
    _priceFocusNode.dispose();
    _descriptionFocusNode.dispose();
    _imageUrlController.dispose();
    _imageUrlFocusNode.dispose();
    super.dispose();
  }

  // returns true if we are editing an existing product
  //         false if adding a new one
  bool _editMode(String productId) {
    return productId != null;
  }

  void _updateImageUrl() {
    if (!_imageUrlFocusNode.hasFocus) {
      if (!_imageUrlController.text.isEmpty) {
        if (isValidImageUrl(_imageUrlController.text) != null) {
          // url not valid
          return;
        }
      }
      setState(() {});
    }
  }

  Widget _alertMsg(BuildContext ctx) {
    return AlertDialog(
      title: Text("An Error!"),
      content: Text("Something went wrong :("),
      actions: [
        FlatButton(
          child: Text("OK"),
          onPressed: () {
            Navigator.of(ctx).pop();
          },
        )
      ],
    );
  }

  @override
  Future<void> _saveForm() async {
    final isvalid = _form.currentState.validate();
    if (!isvalid) {
      return; // will not save
    }
    _form.currentState.save();
    setState(() {
      _isLoading = true;
    });
    if (_editMode(_editedProduct.id)) {
      try {
        await Provider.of<ProductsProvider>(context, listen: false)
            .updateProduct(_editedProduct.id, _editedProduct);
      } catch (error) {
        throw error;
        // handle
      }
    } else {
      // not editMode => adding new product
      try {
        await Provider.of<ProductsProvider>(context, listen: false)
            .addProduct(_editedProduct);
      } catch (error) {
        await showDialog<Null>(
          context: context,
          builder: (ctx) => _alertMsg(ctx),
        );
      }
    }
    setState(() {
      _isLoading = false;
    });
    Navigator.of(context).pop();

    //Navigator.of(context).pop();

    /// checks if the saving works
    // //print(_editedProduct.title);
    // //print(_editedProduct.description);
    // //print(_editedProduct.price);
    // //print(_editedProduct.imageUrl);
  }

  /// returns a null when url valid
  ///
  String isValidImageUrl(String value) {
    if (value.isEmpty) {
      return "plese provide a URL";
    }
    if ((!value.startsWith("http")) && (!value.startsWith("https"))) {
      return "plese provide a valid image URL";
    }
    if ((!value.endsWith(".png")) &&
        (!value.endsWith(".jpg")) &&
        (!value.endsWith(".jpeg"))) {
      return "plese provide a valid image URL";
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Product"),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveForm,
          )
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              child: Form(
                key: _form,
                child: ListView(
                  children: <Widget>[
                    TextFormField(
                      initialValue: _initValues["title"],
                      //onChanged: , dispite what max say we have such listener
                      decoration: InputDecoration(
                        labelText: "Title",
                        errorStyle: TextStyle(color: Colors.red),
                      ),
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_) {
                        FocusScope.of(context).requestFocus(_priceFocusNode);
                      },
                      validator: (value) {
                        // returning null mean correct input
                        // returning text means it's our err text
                        if (value.isEmpty) {
                          return "plese provide a title";
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _editedProduct = Product(
                          id: _editedProduct.id,
                          title: value,
                          price: _editedProduct.price,
                          description: _editedProduct.description,
                          imageUrl: _editedProduct.imageUrl,
                          isFavorite: _editedProduct.isFavorite,
                        );
                      },
                    ),
                    TextFormField(
                      initialValue: _initValues["price"],
                      //onChanged: , dispite what max say we have such listener
                      decoration: InputDecoration(labelText: "Price"),
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.number,
                      focusNode: _priceFocusNode,
                      onFieldSubmitted: (_) {
                        FocusScope.of(context)
                            .requestFocus(_descriptionFocusNode);
                      },
                      validator: (value) {
                        // returning null mean correct input
                        // returning text means it's our err text
                        if (value.isEmpty) {
                          return "plese provide a price";
                        }
                        var parsed = double.tryParse(value);
                        if (parsed == null) {
                          return "plese provide a valid price";
                        }
                        if (parsed <= 0) {
                          return "plese provide a positive price";
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _editedProduct = Product(
                          id: _editedProduct.id,
                          title: _editedProduct.title,
                          price: double.parse(value),
                          description: _editedProduct.description,
                          imageUrl: _editedProduct.imageUrl,
                          isFavorite: _editedProduct.isFavorite,
                        );
                      },
                    ),
                    TextFormField(
                      initialValue: _initValues["description"],
                      //onChanged: , dispite what max say we have such listener
                      decoration: InputDecoration(labelText: "Description"),
                      focusNode: _descriptionFocusNode,
                      maxLines: 3,
                      keyboardType: TextInputType.multiline,
                      validator: (value) {
                        // returning null mean correct input
                        // returning text means it's our err text
                        if (value.isEmpty) {
                          return "plese provide a description";
                        }
                        if (value.length < 10) {
                          return "plese provide a description at least 10 caracters long";
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _editedProduct = Product(
                          id: _editedProduct.id,
                          title: _editedProduct.title,
                          price: _editedProduct.price,
                          description: value,
                          imageUrl: _editedProduct.imageUrl,
                          isFavorite: _editedProduct.isFavorite,
                        );
                      },
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          margin: EdgeInsets.only(
                            top: 8,
                            right: 10,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(
                              width: 1,
                              color: Colors.grey,
                            ),
                          ),
                          // https://www.kidsworldfun.com/images/funpics/0146b.jpg
                          child: Container(
                            child: _imageUrlController.text.isEmpty
                                ? Text("Enter URL")
                                : FittedBox(
                                    child: Image.network(
                                      _imageUrlController.text,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                          ),
                        ),
                        Expanded(
                          child: TextFormField(
                            decoration: InputDecoration(labelText: "Imae URL"),
                            keyboardType: TextInputType.url,
                            textInputAction: TextInputAction.done,
                            controller: _imageUrlController,
                            focusNode: _imageUrlFocusNode,
                            onEditingComplete: () {
                              setState(() {});
                            },
                            onFieldSubmitted: (_) {
                              _saveForm();
                            },
                            validator: (value) {
                              // returning null mean correct input
                              // returning text means it's our err text
                              //
                              // regex: (check if right 4 our case!)
                              // var urlPattern = r"(https?|ftp)://([-A-Z0-9.]+)(/[-A-Z0-9+&@#/%=~_|!:,.;]*)?(\?[A-Z0-9+&@#/%=~_|!:‌​,.;]*)?";
                              // var result = new RegExp(urlPattern, caseSensitive: false).
                              //                  firstMatch(value);
                              return isValidImageUrl(value);
                            },
                            onSaved: (value) {
                              _editedProduct = Product(
                                id: _editedProduct.id,
                                title: _editedProduct.title,
                                price: _editedProduct.price,
                                description: _editedProduct.description,
                                imageUrl: value,
                                isFavorite: _editedProduct.isFavorite,
                              );
                            },
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
    );
  }
}
