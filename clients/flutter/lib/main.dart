import 'package:flutter/material.dart';
import 'package:stoat_chat/viewmodels/connection.dart';
import 'package:provider/provider.dart';
import 'screens/chat.dart';
import 'screens/drawer.dart';

void main() async {
  runApp(
    ChangeNotifierProvider<ConnectionViewModel>(
      create: (ctx) => ConnectionViewModel(),
      child: Root(),
    ),
  );
}

class Root extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(),
        body: ChatScreen(),
        drawer: AppDrawer(),
      ),
    );
  }
}
