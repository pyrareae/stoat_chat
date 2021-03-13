import 'package:flutter/foundation.dart';
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
  String lastUrl;
  IOWebSocketChannel channel;
  UnmodifiableListView<Message> get messages => UnmodifiableListView(_messages);
  Map<String, Function> _handlers;
  Auth _auth;
  Function onReceive = () {};
  List<User> _users;
  UnmodifiableListView<User> get users => UnmodifiableListView(_users);

  ConnectionViewModel({String url = "10.0.0.34:8887"}) : super() {
    _initAsync();
    _setupNetworking(url);
    _defineHandlers();
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
        onReceive();
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
      }
    };
  }

  void _setupNetworking(String url) {
    lastUrl = url;
    channel = IOWebSocketChannel.connect("ws://${url}");
    channel.stream.listen((message) {
      print("received message: $message");
      var parsed = jsonDecode(message);
      if (_handlers.containsKey(parsed['type'])) {
        _handlers[parsed['type']](parsed);
      } else {
        print("ERROR: got message with unhandled type! ${parsed}");
      }
    });
  }

  void _checkConnection() {
    if (channel.closeCode != null) {
      _setupNetworking(lastUrl);
    }
  }

  // Send a new message to the server
  void send(Message message) async {
    _checkConnection();
    channel.sink.add(
      jsonEncode({
        'type': 'message',
        'data': {
          'text': message.text,
          'nick': message.nick,
          'pubkey': _auth.encoded,
          'signature': await message.sign()
        }
      }),
    );
  }

  void reloadHistory() {
    channel.sink.add('{"type": "history_request"}');
  }

  void add(Message message) {
    _messages.insert(0, message);
  }

  void fetchUsers() {
    channel.sink.add('{"type": "users_request"}');
  }
}
