import 'package:flutter/foundation.dart';
import 'package:stoat_chat/models/user.dart';
import 'package:web_socket_channel/io.dart';
import 'package:stoat_chat/util/auth.dart';
import 'dart:collection';

class UsersViewModel extends ChangeNotifier {
  late List<User> _users;
  UnmodifiableListView<User> get users => UnmodifiableListView(_users);

  UsersViewModel() : super();
}
