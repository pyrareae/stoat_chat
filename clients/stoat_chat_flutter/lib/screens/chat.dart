import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
import 'package:stoat_chat/models/message.dart';
import 'package:stoat_chat/viewmodels/connection.dart';
import 'package:provider/provider.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _inputController = TextEditingController();
  String text = '';
  final _inputFocus = FocusNode();

  @override
  void initState() {
    var messages = Provider.of<ConnectionViewModel>(context, listen: false);
    messages.onReceive = () {
      setState(() {});
    };
    messages.messagingContext = context;
    messages.reloadHistory();
    super.initState();
  }

  void sendMessage() {
    var messages = Provider.of<ConnectionViewModel>(context, listen: false);
    messages.send(Message(nick: 'user', text: text));
    _inputController.clear();
    _inputFocus.requestFocus();
    setState(() {
      text = '';
    });
  }

  @override
  void dispose() {
    _inputFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Expanded(
            child: Consumer<ConnectionViewModel>(
              builder: (context, messages, _) => ListView.builder(
                reverse: true,
                itemCount: messages.messages.length,
                itemBuilder: (context, index) => Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(color: Colors.grey[200]),
                      padding: EdgeInsets.all(5),
                      child: Text(messages.messages[index].nick ?? '?'),
                    ),
                    Text(messages.messages[index].text ?? '<null>'),
                  ],
                ),
              ),
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: TextField(
                  focusNode: _inputFocus,
                  controller: _inputController,
                  onSubmitted: (value) => sendMessage(),
                  onChanged: (v) => setState(() => text = v),
                ),
              ),
              IconButton(
                icon: Icon(Icons.send),
                onPressed: () => sendMessage(),
              )
            ],
          ),
        ],
      ),
    );
  }
}
