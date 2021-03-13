import 'package:flutter/material.dart';
import 'screens/chat.dart';
import 'package:stoat_chat/viewmodels/connection.dart';
import 'package:provider/provider.dart';

void main() async {
  runApp(
    ChangeNotifierProvider<ConnectionViewModel>(
      create: (_) => ConnectionViewModel(),
      child: Root(),
    ),
  );
}

class Root extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(body: ChatScreen()),
    );
  }
}
