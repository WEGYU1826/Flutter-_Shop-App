import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:state_management/providers/orders.dart' as ord;

class OrderItem extends StatefulWidget {
  const OrderItem({Key? key, this.order}) : super(key: key);

  final ord.OrderItem? order;

  @override
  State<OrderItem> createState() => _OrderItemState();
}

class _OrderItemState extends State<OrderItem> {
  var _expanded = false;
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(10.0),
      child: Column(
        children: <Widget>[
          ListTile(
            title: Text('\$${widget.order!.amount.toStringAsFixed(2)}'),
            subtitle: Text(
                DateFormat('dd/mm/yyyy hh:mm').format(widget.order!.dateTime)),
            trailing: IconButton(
              icon: Icon(
                _expanded
                    ? Icons.expand_less_outlined
                    : Icons.expand_more_outlined,
              ),
              onPressed: () {
                setState(() {
                  _expanded = !_expanded;
                });
              },
            ),
          ),
          if (_expanded)
            Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 4,
                ),
                height: min(widget.order!.products.length * 20 + 10, 180),
                child: ListView(
                    children: widget.order!.products
                        .map((e) => Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text(
                                  e.title,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '${e.quantity}x \$${e.price}',
                                  style: const TextStyle(
                                    fontSize: 18.0,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ))
                        .toList())),
        ],
      ),
    );
  }
}
