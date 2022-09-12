import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:state_management/helper/custom_routh.dart';
import 'package:state_management/providers/auth.dart';
import 'package:state_management/providers/cart.dart';
import 'package:state_management/providers/orders.dart';
import 'package:state_management/providers/product_provider.dart';
import 'package:state_management/screens/auth_screen.dart';
import 'package:state_management/screens/cart_screen.dart';
import 'package:state_management/screens/edit_product_screen.dart';
import 'package:state_management/screens/order_screen.dart';
import 'package:state_management/screens/product_detail_screen.dart';
import 'package:state_management/screens/product_overview_screen.dart';
import 'package:state_management/screens/splash_screen.dart';
import 'package:state_management/screens/user_product_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => Auth(),
        ),
        ChangeNotifierProxyProvider<Auth, ProductProvider>(
          create: (_) => ProductProvider(
            null.toString(),
            [],
            null.toString(),
          ),
          update: (_, auth, prevProductObject) => ProductProvider(
            auth.token,
            prevProductObject == null ? [] : prevProductObject.items,
            auth.userID,
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => Cart(),
        ),
        ChangeNotifierProxyProvider<Auth, Orders>(
          create: (_) => Orders(
            null.toString(),
            null.toString(),
            [],
          ),
          update: (_, authData, prevOrdersObject) => Orders(
            authData.token,
            authData.userID,
            prevOrdersObject == null ? [] : prevOrdersObject.orders,
          ),
        ),
      ],
      child: Consumer<Auth>(
        builder: (context, authData, _) => MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'MyShop',
          theme: ThemeData(
            primarySwatch: Colors.purple,
            // ignore: deprecated_member_use
            accentColor: Colors.deepOrange,
            pageTransitionsTheme: PageTransitionsTheme(
              builders: {
                TargetPlatform.android: CustomPageTransitionBuilder(),
                TargetPlatform.iOS: CustomPageTransitionBuilder(),
              }, //for all page route
            ),
          ),
          home: authData.isAuth
              ? ProductOverViewScreen()
              : FutureBuilder(
                  future: authData.tryAutoLogin(),
                  builder: (context, snapshot) =>
                      snapshot.connectionState == ConnectionState.waiting
                          ? SplashScreen()
                          : AuthScreen(),
                ),
          routes: {
            ProductDetailScreen.routeName: (context) => ProductDetailScreen(),
            CartScreen.routeName: (context) => CartScreen(),
            OrderScreen.routeName: (context) => OrderScreen(),
            UserProductScreen.routeName: (context) => UserProductScreen(),
            EditProductScreen.routeName: (context) => EditProductScreen(),
            AuthScreen.routeName: (context) => AuthScreen(),
          },
        ),
      ),
    );
  }
}
