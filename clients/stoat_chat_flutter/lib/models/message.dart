import 'package:stoat_chat/util/auth.dart';

class Message {
  String text;
  String nick;
  String id;
  DateTime date;

  Message({this.text, this.nick, this.id, this.date, String dateString}) {
    if (dateString != null) {
      date = DateTime.parse(dateString);
    }
  }

  Future<String> sign() async {
    final auth = await Auth.instance();
    return auth.rsaSign64(text);
  }
}
