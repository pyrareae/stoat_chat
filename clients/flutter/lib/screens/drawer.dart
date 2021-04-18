import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stoat_chat/viewmodels/connection.dart';

class AppDrawer extends StatelessWidget {
  final _urlController = TextEditingController();
  final _nickController = TextEditingController();

  void apply(context) {
    Provider.of<ConnectionViewModel>(context, listen: false).reconnect();
  }

  @override
  Widget build(BuildContext context) {
    _urlController.text =
        Provider.of<ConnectionViewModel>(context, listen: false).url;
    _nickController.text =
        Provider.of<ConnectionViewModel>(context, listen: false).userNick;
    return Theme(
      data: ThemeData.dark().copyWith(
        // backgroundColor: Color(0x00ffffffff),
        canvasColor: Color(0x90000000),
        shadowColor: Color(0x00000000),
      ),
      child: Drawer(
        child: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
            child: Container(
              height: double.infinity,
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Consumer<ConnectionViewModel>(
                  builder: (context, connection, _) => Column(
                    children: [
                      Flex(
                        direction: Axis.vertical,
                        children: [
                          Text('Nick'),
                          TextField(
                            controller: _nickController,
                            onChanged: (v) => connection.userNick = v,
                          )
                        ],
                      ),
                      Flex(
                        direction: Axis.vertical,
                        children: [
                          Text('Server URL'),
                          TextField(
                            controller: _urlController,
                            onChanged: (v) => connection.url = v,
                          )
                        ],
                      ),
                      ElevatedButton(
                          onPressed: () => apply(context),
                          child: Text('APPLY')),
                      ElevatedButton(
                          onPressed: () => connection.reloadHistory(),
                          child: Text('reload history')),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
