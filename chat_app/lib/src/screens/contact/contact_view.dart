import 'package:chat_app/src/data/models/user.dart';
import 'package:chat_app/src/screens/contact/contact_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ContactScreen extends StatefulWidget {
  final User user;

  ContactScreen({
    @required this.user,
  });

  @override
  _ContactScreenState createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {

  ContactController _contactController;

  @override
  void initState() {
    super.initState();
    _contactController = ContactController(
      context: context,
      user: widget.user,
    );
  }

  @override
  void dispose() {
    _contactController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Object>(
        stream: _contactController.streamController.stream,
        builder: (context, snapshot) {
          return Scaffold(
            backgroundColor: Color(0xFFEEEEEE),
            appBar: AppBar(
              title: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    _contactController.user.name,
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  renderOnline(),
                ],
              ),
            ),
            body: SafeArea(
              child: Container(
                child: Column(
                  children: <Widget>[
                    Expanded(
                      child: ListView(
                        reverse: true,
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.only(
                              left: 15,
                              right: 15,
                              top: 5,
                            ),
                            child: renderMessages(context),
                          ),
                        ],
                      ),
                    ),
                    Material(
                      color: Colors.transparent,
                      child: Padding(
                        padding: const EdgeInsets.all(5),
                        child: Container(
                          height: 55,
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                child: Card(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 25,
                                    ),
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: TextField(
                                        cursorColor:
                                            Theme.of(context).primaryColor,
                                        controller:
                                            _contactController.textController,
                                        onSubmitted: (_) {
                                          _contactController.sendMessage();
                                        },
                                        decoration: InputDecoration(
                                          contentPadding:
                                              EdgeInsets.only(bottom: 0),
                                          hintText: 'Digite uma mensagem',
                                          hintStyle: TextStyle(fontSize: 16),
                                          border: InputBorder.none,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              Material(
                                color: Theme.of(context).primaryColor,
                                borderRadius: BorderRadius.circular(50),
                                child: InkWell(
                                  onTap: _contactController.sendMessage,
                                  borderRadius: BorderRadius.circular(50),
                                  child: Container(
                                    width: 50,
                                    height: 50,
                                    alignment: Alignment.center,
                                    child: Icon(
                                      Icons.send,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }

  Widget renderMessages(BuildContext context) {
    return Column(
      children: _contactController.messages.map((message) {
        return Column(
          children: <Widget>[
            // SizedBox(
            //   height: 5,
            // ),
            Material(
              color: Colors.transparent,
              child: Align(
                alignment: message.socketId == 'MY_SOCKET_ID'
                    ? Alignment.centerRight
                    : Alignment.centerLeft,
                child: Container(
                  constraints: BoxConstraints(maxWidth: double.infinity - 30),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Card(
                    margin: EdgeInsets.symmetric(
                      vertical: 2,
                    ),
                    color: message.socketId == 'MY_SOCKET_ID'
                        ? Color(0xFFFFC0CB)
                        : Colors.white,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      child: Text(
                        message.text,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 14.5,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget renderOnline() {
    if (_contactController.userOnlineInMyChat) {
      return Text(
        'online na sua conversa',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.greenAccent,
        ),
      );
    }
    return Container(width: 0, height: 0);
  }
}