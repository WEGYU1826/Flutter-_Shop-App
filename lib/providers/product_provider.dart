import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:state_management/models/http_exception.dart';
import 'product.dart';

class ProductProvider with ChangeNotifier {
  List<Product> _items = [
    // Product(
    //   id: 'p1',
    //   title: 'Red Shirt',
    //   desc: 'A red shirt - it is pretty red!',
    //   price: 29.99,
    //   imageUrl:
    //       'https://cdn.pixabay.com/photo/2016/10/02/22/17/red-t-shirt-1710578_1280.jpg',
    // ),
    // Product(
    //   id: 'p2',
    //   title: 'Trousers',
    //   desc: 'A nice pair of trousers.',
    //   price: 59.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e8/Trousers%2C_dress_%28AM_1960.022-8%29.jpg/512px-Trousers%2C_dress_%28AM_1960.022-8%29.jpg',
    // ),
    // Product(
    //   id: 'p3',
    //   title: 'Yellow Scarf',
    //   desc: 'Warm and cozy - exactly what you need for the winter.',
    //   price: 19.99,
    //   imageUrl:
    //       'https://live.staticflickr.com/4043/4438260868_cc79b3369d_z.jpg',
    // ),
    // Product(
    //   id: 'p4',
    //   title: 'A Pan',
    //   desc: 'Prepare any meal you want.',
    //   price: 49.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/1/14/Cast-Iron-Pan.jpg/1024px-Cast-Iron-Pan.jpg',
    // ),
  ];

  final String authToken;
  final String userID;
  ProductProvider(this.authToken, this._items, this.userID);

  var _showFavOnly = false;
  List<Product> get items {
    if (_showFavOnly) {
      return _items.where((element) => element.isFav).toList();
    }
    return [..._items];
  }

  void showFavOnly() {
    _showFavOnly = true;
    notifyListeners();
  }

  void showAll() {
    _showFavOnly = false;
    notifyListeners();
  }

  Product findByID(String id) {
    return _items.firstWhere((element) => element.id == id);
  }

  Future<void> fetchSetProducts([bool filterByUser = false]) async {
    final filterString =
        filterByUser ? 'orderBy="creatorID"&equalTo="$userID"' : '';
    final url =
        'https://shop-app-fd8a1-default-rtdb.firebaseio.com/products.json?auth=$authToken&$filterString';
    try {
      final response = await http.get(Uri.parse(url));
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      if (extractedData == null) {
        return;
      }
      final favUrl =
          'https://shop-app-fd8a1-default-rtdb.firebaseio.com/userFav/$userID.json?auth=$authToken';
      final favResponse = await http.get(Uri.parse(favUrl));
      final favData = json.decode(favResponse.body);
      final List<Product> loadedProduct = [];
      extractedData.forEach((productID, productData) {
        loadedProduct.insert(
          0,
          Product(
            id: productID,
            title: productData['title'],
            desc: productData['description'],
            price: productData['price'],
            imageUrl: productData['imageUrl'],
            isFav: favData == null ? false : favData[productID] ?? false,
          ),
        );
      });
      _items = loadedProduct;
      notifyListeners();
    } catch (e) {
      // ignore: use_rethrow_when_possible
      throw e;
    }
  }

  Future<void> addProduct(Product product) async {
    final url =
        'https://shop-app-fd8a1-default-rtdb.firebaseio.com/products.json?auth=$authToken';
    try {
      final response = await http.post(Uri.parse(url),
          body: json.encode({
            'title': product.title,
            'description': product.desc,
            'imageUrl': product.imageUrl,
            'price': product.price,
            'creatorID': userID,
          }));

      final newProduct = Product(
        id: json.decode(response.body)['name'],
        title: product.title,
        desc: product.desc,
        price: product.price,
        imageUrl: product.imageUrl,
      );
      // _items.add(newProduct);
      _items.insert(0, newProduct); // at the start of the list
      notifyListeners();
    } catch (error) {
      // ignore: use_rethrow_when_possible
      throw error;
    }
  }

  Future<void> updateProduct(String id, Product product) async {
    final productIndex = _items.indexWhere((element) => element.id == id);
    if (productIndex >= 0) {
      final url =
          'https://shop-app-fd8a1-default-rtdb.firebaseio.com/products/$id.json?auth=$authToken'; // final only constant at run time but const is const at all time

      try {
        await http.patch(Uri.parse(url),
            body: json.encode({
              'title': product.title,
              'description': product.desc,
              'imageUrl': product.imageUrl,
              'price': product.price,
            }));
        _items[productIndex] = product;
        notifyListeners();
      } catch (e) {
        // ignore: use_rethrow_when_possible
        throw e;
      }
    } else {
      // ignore: avoid_print
      print('...');
    }
  }

  Future<void> deleteProduct(String id) async {
    final url =
        'https://shop-app-fd8a1-default-rtdb.firebaseio.com/products/$id.json?auth=$authToken';
    final existingProductsIndex =
        _items.indexWhere((element) => element.id == id);
    Product? existingProduct = _items[existingProductsIndex];

    _items.removeAt(existingProductsIndex);
    notifyListeners();

    final response = await http.delete(Uri.parse(url));
    if (response.statusCode >= 400) {
      _items.insert(existingProductsIndex, existingProduct);
      notifyListeners();
      throw HttpException('could not delete product.');
    }
    existingProduct = null;
  }
}
