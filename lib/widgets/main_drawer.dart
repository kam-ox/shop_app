import 'package:flutter/material.dart';
import '../screens/orders_screen.dart';

class MainDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            AppBar(
              title: Text('Hello buddy'),
              automaticallyImplyLeading: false,
            ),
            Divider(),
            SizedBox(height: 20),
            ListTile(
              leading: Icon(Icons.shop),
              title: Text(
                'Shop',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              onTap: () {
                Navigator.of(context).pushNamed('/');
              },
            ),
            ListTile(
              leading: Icon(Icons.payment),
              title: Text(
                'Orders',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              onTap: () {
                Navigator.of(context).pushNamed(OrderScreen.routeName);
              },
            ),
          ],
        ),
      ),
    );
  }
}
