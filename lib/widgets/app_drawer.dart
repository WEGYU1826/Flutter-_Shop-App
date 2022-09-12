import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:state_management/helper/custom_routh.dart';
import 'package:state_management/screens/order_screen.dart';
import 'package:state_management/screens/user_product_screen.dart';

import '../providers/auth.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: <Widget>[
          AppBar(
            title: const Text('Hello Friend!'),
            centerTitle: true,
            automaticallyImplyLeading: false,
          ),
          const Divider(),
          ListTile(
            leading: Icon(
              Icons.shop,
              color: Theme.of(context).primaryColor,
            ),
            title: const Text('Shop'),
            onTap: () {
              Navigator.of(context).pushReplacementNamed("/");
            },
          ),
          const Divider(),
          ListTile(
            leading: Icon(
              Icons.paypal_outlined,
              color: Theme.of(context).primaryColor,
            ),
            title: const Text('Orders'),
            onTap: () {
              Navigator.of(context).pushReplacementNamed(
                OrderScreen.routeName,
              );
              // Navigator.of(context).pushReplacement(
              //   CustomRoute(
              //     builder: (context) => OrderScreen(),
              //   ),
              // ); // this how we can apply custom route to individual page
            },
          ),
          const Divider(),
          ListTile(
            leading: Icon(
              Icons.edit_note_outlined,
              color: Theme.of(context).primaryColor,
            ),
            title: const Text('Mange Product'),
            onTap: () {
              Navigator.of(context).pushReplacementNamed(
                UserProductScreen.routeName,
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: Icon(
              Icons.exit_to_app_outlined,
              color: Theme.of(context).primaryColor,
            ),
            title: const Text('Logout'),
            onTap: () {
              // Navigator.of(context).pushReplacementNamed(
              //   UserProductScreen.routeName,
              // );
              Navigator.of(context).pop();
              Navigator.of(context).pushReplacementNamed('/');
              Provider.of<Auth>(context, listen: false).logout();
            },
          ),
        ],
      ),
    );
  }
}
