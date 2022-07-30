import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:stoat_chat/models/message.dart';
import 'dart:collection';
import 'package:web_socket_channel/io.dart';
import 'dart:convert' show jsonDecode, jsonEncode;
import 'package:stoat_chat/models/user.dart';
import 'package:stoat_chat/util/auth.dart';

// import 'package:web_socket_channel/web_socket_channel.dart';
// import 'package:web_socket_channel/status.dart' as status;
// TODO: split this into UsersVM, MessagesVM, and Networking

class ConnectionViewModel extends ChangeNotifier {
  List<Message> _messages = [];
  late IOWebSocketChannel _channel;
  UnmodifiableListView<Message> get messages => UnmodifiableListView(_messages);
  late Map<String, Function> _handlers;
  Auth? _auth;
  Function? onReceive = () {};
  late List<User> _users;
  UnmodifiableListView<User> get users => UnmodifiableListView(_users);
  String url = 'localhost:8887';
  BuildContext? messagingContext;
  String userNick = 'user';

  ConnectionViewModel({this.messagingContext, this.onReceive}) : super() {
    _initAsync();
    _setupNetworking(url);
    _defineHandlers();
    Future.delayed(Duration(seconds: 3))
        .then((_) => _showSnackbar("welcome to STOATchat"));
  }

  void _initAsync() async {
    _auth = await Auth.instance();
  }

  void _defineHandlers() {
    _handlers = {
      'message': (resp) {
        var d = resp['data'];
        final newMessage = Message(nick: d['nick'], text: d['text']);
        add(newMessage);
        onReceive!();
        notifyListeners();
      },
      'response': (resp) {
        print(
            "Message from server: ${resp['message']}; status: ${resp['status']}");
      },
      'history': (resp) {
        var d = resp['data'];
        _messages = (d as List).map((el) {
          return Message(nick: el['nick'], text: el['text']);
        }).toList();
        notifyListeners();
      },
      'users_list': (resp) {}
    };
  }

  void _setupNetworking(String url) {
    _channel = IOWebSocketChannel.connect("ws://${url}");
    _channel.stream.listen((message) {
      print("received message: $message");
      var parsed = jsonDecode(message);
      if (_handlers.containsKey(parsed['type'])) {
        _handlers[parsed['type']]!(parsed);
      } else {
        print("ERROR: got message with unhandled type! ${parsed}");
      }
    });
  }

  void _checkConnection() {
    if (_channel.closeCode != null) {
      _setupNetworking(url);
    }
  }

  // Send a new message to the server
  void send(Message message) async {
    _checkConnection();
    _channel.sink.add(
      jsonEncode({
        'type': 'message',
        'data': {
          'text': message.text,
          'nick': userNick,
          'pubkey': _auth!.encoded,
          'signature': await message.sign()
        }
      }),
    );
  }

  void reloadHistory() {
    _channel.sink.add('{"type": "history_request"}');
  }

  void add(Message message) {
    _messages.insert(0, message);
  }

  void fetchUsers() {
    _channel.sink.add('{"type": "users_request"}');
  }

  void reconnect() {
    try {
      _setupNetworking(url);
      _showSnackbar('Connected!');
    } catch (e) {
      print(e);
      _showSnackbar('Error!', status: #warn);
    }
  }

  void _showSnackbar(String message, {Symbol status = #info}) {
    if (messagingContext == null) return;
    Color color;
    switch (status) {
      case #info:
        color = Colors.transparent;
        break;
      case #warn:
        break;
      case #ok:
        break;
    }

    ScaffoldMessenger.of(messagingContext!).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Container(child: Text(message)),
      ),
    );
  }
}
