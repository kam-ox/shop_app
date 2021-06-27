import 'package:flutter/material.dart';
import 'package:my_shop/providers/product.dart';
import 'package:provider/provider.dart';
import '../providers/products.dart';

class EditProductScreen extends StatefulWidget {
  static const routeName = '/edit-product';

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
    title: '',
    price: 0,
    description: '',
    imageUrl: '',
  );
  var _initValues = {
    'title': '',
    'description': '',
    'price': '',
    'imageUrl': '',
  };

  var _isInit = true;

  @override
  void initState() {
    _imageUrlFocusNode.addListener(_updateImageUrl);

    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (_isInit) {
      final productId = ModalRoute.of(context).settings.arguments as String;
      if (productId != null) {
        _editedProduct =
            Provider.of<Products>(context, listen: false).findById(productId);
        _initValues = {
          'title': _editedProduct.title,
          'description': _editedProduct.description,
          'price': _editedProduct.price.toString(),
          // 'imageURL': _editedProduct.imageUrl,
          'imageURL': '',
        };
        _imageUrlController.text = _editedProduct.imageUrl;
      }
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  @override //! always dispose focusNodes.
  void dispose() {
    _imageUrlFocusNode.removeListener(_updateImageUrl);
    _priceFocusNode.dispose();
    _descriptionFocusNode.dispose();
    _imageUrlController.dispose();
    _imageUrlFocusNode.dispose();
    super.dispose();
  }

  void _updateImageUrl() {
    if (!_imageUrlFocusNode.hasFocus) {
      if ((!_imageUrlController.text.startsWith('http') &&
              !_imageUrlController.text.startsWith('https')) ||
          (!_imageUrlController.text.endsWith('.jpg') &&
              !_imageUrlController.text.endsWith('.png') &&
              !_imageUrlController.text.endsWith('.jpeg'))) {
        return; // if does return then it won't update image in the container
      }
      setState(() {});
    }
  }

  void _saveForm() {
    final isValid =
        _form.currentState.validate(); // returns true if there is an error
    if (!isValid) {
      return; //stops the following code
    }

    _form.currentState.save();
    if (_editedProduct.id != null) {
      Provider.of<Products>(context, listen: false)
          .updateProduct(_editedProduct.id, _editedProduct);
    } else {
      Provider.of<Products>(context, listen: false).addProduct(_editedProduct);
    }

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Product'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: () {
              _saveForm();
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          //* is stateful
          key: _form,
          child: ListView(
            children: [
              TextFormField(
                // onSaved: (value) { //* Max's approach
                //   _editedProduct = Product(
                //     title: value,
                //     price: _editedProduct.price,
                //     imageUrl: _editedProduct.imageUrl,
                //     id: null,
                //     description: _editedProduct.description,
                //   );
                // },
                initialValue: _initValues['title'],
                validator: (value) {
                  if (value.isEmpty) {
                    return 'You didn\'t set a title';
                  }

                  return null;
                },
                onSaved: (value) {
                  //* Mike's approach
                  _editedProduct.copyWith(title: value);
                },
                decoration: InputDecoration(
                  labelText: 'Title',
                  errorStyle: TextStyle(
                    color: Theme.of(context).errorColor,
                  ),
                ),
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (_) {
                  FocusScope.of(context).requestFocus(_priceFocusNode);
                },
              ),
              TextFormField(
                initialValue: _initValues['price'],
                validator: (value) {
                  if (value.isEmpty) {
                    // checks whether the value is empty
                    return 'You didn\'t enter a price';
                  }
                  if (double.tryParse(value) == null) {
                    // * if the value isn't a number it will return a null
                    return 'Please enter a valid number';
                  }
                  if (double.parse(value) <= 0) {
                    // if the value is less or equal than 0 throws a text below
                    return 'Please enter a number greater than zero';
                  }
                },
                onSaved: (value) {
                  _editedProduct =
                      _editedProduct.copyWith(price: double.parse(value));
                },
                decoration: InputDecoration(labelText: 'Price'),
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.number,
                focusNode: _priceFocusNode,
                onFieldSubmitted: (_) {
                  FocusScope.of(context).requestFocus(_descriptionFocusNode);
                },
              ),
              TextFormField(
                initialValue: _initValues['description'],
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Please enter a description';
                  }
                  if (value.length < 10) {
                    return 'Enter more than 10 symbols';
                  }
                  return null;
                },
                onSaved: (value) {
                  _editedProduct = _editedProduct.copyWith(description: value);
                },
                decoration: InputDecoration(labelText: 'Description'),
                maxLines: 3,
                keyboardType: TextInputType.multiline,
                focusNode: _descriptionFocusNode,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    margin: EdgeInsets.only(top: 8, right: 10),
                    decoration: BoxDecoration(
                      border: Border.all(
                        width: 1,
                        color: Colors.grey,
                      ),
                    ),
                    child: _imageUrlController.text.isEmpty
                        ? Text('Enter a URL')
                        : FittedBox(
                            child: Image.network(
                              _imageUrlController.text,
                              fit: BoxFit.cover,
                            ),
                          ),
                  ),
                  Expanded(
                    child: TextFormField(
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Please enter an image URL';
                        }
                        if (!value.startsWith('http') &&
                            !value.startsWith('https')) {
                          return 'Please enter a valid URL';
                        }
                        if (!value.endsWith('.jpg') &&
                            !value.endsWith('.png') &&
                            !value.endsWith('.jpeg')) {
                          return 'Invalid image';
                        }
                      },
                      onSaved: (value) {
                        _editedProduct =
                            _editedProduct.copyWith(imageUrl: value);
                      },
                      onFieldSubmitted: (_) {
                        _saveForm();
                      },
                      focusNode: _imageUrlFocusNode,
                      // * takes as much width as it can get in a Row, so you need to wrap it with Expanded
                      controller: _imageUrlController,
                      textInputAction: TextInputAction.done,
                      keyboardType: TextInputType.url,
                      decoration: InputDecoration(labelText: 'Image URL'),
                    ),
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
