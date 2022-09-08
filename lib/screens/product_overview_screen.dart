import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:state_management/providers/product_provider.dart';
import 'package:state_management/screens/cart_screen.dart';
import 'package:state_management/widgets/app_drawer.dart';
import 'package:state_management/widgets/badge.dart';

import '../providers/cart.dart';
import '../widgets/product_grid.dart';

enum FilterOptions {
  Fav,
  All,
}

class ProductOverViewScreen extends StatefulWidget {
  const ProductOverViewScreen({Key? key}) : super(key: key);

  @override
  State<ProductOverViewScreen> createState() => _ProductOverViewScreenState();
}

class _ProductOverViewScreenState extends State<ProductOverViewScreen> {
  var _isInit = true;
  var _isLoading = false;

  @override
  void initState() {
    // Provider.of<ProductProvider>(context).fetchSetProducts(); //of(context) won't work in initState remember that
    // Future.delayed(Duration.zero).then((_) => {
    //       Provider.of<ProductProvider>(context).fetchSetProducts(),
    //     }); // This one is work but initState run once it work but...
    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (_isInit) {
      setState(() {
        _isLoading = true;
      }); // to update the UI

      Provider.of<ProductProvider>(context).fetchSetProducts().then((_) {
        setState(() {
          _isLoading = false;
        });
      });
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final productContainer = Provider.of<ProductProvider>(
      context,
      listen: false,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('MyShop'),
        centerTitle: true,
        actions: <Widget>[
          PopupMenuButton(
            onSelected: (FilterOptions selectedValue) {
              if (selectedValue == FilterOptions.Fav) {
                productContainer.showFavOnly();
              } else {
                productContainer.showAll();
              }
            },
            // icon: const Icon(Icons.more_vert_sharp),
            itemBuilder: (_) => const [
              PopupMenuItem(
                value: FilterOptions.Fav,
                child: Text('Only Fav'),
              ),
              PopupMenuItem(
                value: FilterOptions.All,
                child: Text('Show All'),
              ),
            ],
          ),
          Consumer<Cart>(
            builder: (_, cart, ch) => Badge(
              value: cart.itemCount.toString(),
              child: ch!,
            ),
            child: IconButton(
              icon: const Icon(
                Icons.shopping_cart,
              ),
              onPressed: () {
                Navigator.of(context).pushNamed(CartScreen.routeName);
              },
            ),
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : RefreshIndicator(
              onRefresh: () async =>
                  await Provider.of<ProductProvider>(context, listen: false)
                      .fetchSetProducts(),
              child: const ProductGrid()),
    );
  }
}
