import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:state_management/providers/auth.dart';
import 'package:state_management/providers/cart.dart';
import 'package:state_management/providers/product.dart';

import 'package:state_management/screens/product_detail_screen.dart';

class ProductItem extends StatelessWidget {
  const ProductItem({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final product = Provider.of<Product>(context, listen: false);
    final cart = Provider.of<Cart>(context, listen: false);
    final authData = Provider.of<Auth>(context, listen: false);
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: GridTile(
        footer: GridTileBar(
          backgroundColor: Colors.black45,
          leading: Consumer<Product>(
            builder: (context, value, child) => IconButton(
              icon: Icon(
                value.isFav ? Icons.favorite : Icons.favorite_border_outlined,
              ),
              // label: child,
              color: Colors.deepOrange,
              onPressed: () {
                value.toggleFavStatus(authData.token, authData.userID);
              },
            ),
            // child: const Text('Never Change!'),
          ),
          title: Text(
            product.title,
            textAlign: TextAlign.center,
            style: GoogleFonts.anton(fontWeight: FontWeight.bold),
          ),
          trailing: IconButton(
            onPressed: () {
              cart.addItem(product.id, product.price, product.title);
              Scaffold.of(context).hideCurrentSnackBar();
              Scaffold.of(context).showSnackBar(
                SnackBar(
                  content: const Text(
                    'Added item to cart!',
                    textAlign: TextAlign.center,
                  ),
                  duration: const Duration(seconds: 2),
                  action: SnackBarAction(
                    label: 'UNDO',
                    onPressed: () {
                      cart.removeSingleItems(product.id);
                    },
                  ),
                  backgroundColor: Colors.purple,
                ),
              );
            },
            color: Theme.of(context).accentColor,
            icon: const Icon(Icons.shopping_cart_outlined),
          ),
        ),
        child: GestureDetector(
          onTap: () {
            Navigator.of(context).pushNamed(
              ProductDetailScreen.routeName,
              arguments: product.id,
            );
          },
          child: Image.network(
            product.imageUrl,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
