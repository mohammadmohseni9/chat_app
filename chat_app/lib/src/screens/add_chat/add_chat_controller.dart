import 'dart:async';
import 'dart:convert';

import 'package:chat_app/src/data/models/chat.dart';
import 'package:chat_app/src/data/models/custom_error.dart';
import 'package:chat_app/src/data/models/user.dart';
import 'package:chat_app/src/data/providers/chats_provider.dart';
import 'package:chat_app/src/data/repositories/chat_repository.dart';
import 'package:chat_app/src/data/repositories/user_repository.dart';
import 'package:chat_app/src/screens/contact/contact_view.dart';
import 'package:chat_app/src/screens/login/login_view.dart';
import 'package:chat_app/src/utils/custom_shared_preferences.dart';
import 'package:chat_app/src/utils/socket_controller.dart';
import 'package:chat_app/src/utils/state_control.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:provider/provider.dart';

import 'package:socket_io_client/socket_io_client.dart' as IO;

class AddChatController extends StateControl {
  UserRepository _userRepository = UserRepository();
  ChatRepository _chatRepository = ChatRepository();

  final BuildContext context;

  bool _loading = true;
  bool get loading => _loading;

  bool _error = false;
  bool get error => _error;

  List<User> _users = [];
  List<User> get users => _users;

  Chat _chat;

  ProgressDialog _progressDialog;

  AddChatController({
    @required this.context,
  }) {
    this.init();
  }

  @override
  void init() {
    getUsers();
  }

  void getUsers() async {
    dynamic response = await _userRepository.getUsers();
    if (response is CustomError) {
      _error = true;
    }
    if (response is List<User>) {
      _users = response;
    }
    _loading = false;
    notifyListeners();
  }

  void newChat(User user) async {
    
    _showProgressDialog();
    dynamic response = await _chatRepository.getChatByUsersIds(user.id);
    if (response is CustomError) {
      _error = true;
    }
    if (response is Chat) {
      await _dismissProgressDialog();
      _chat = await response.formatChat();
      ChatsProvider _chatsProvider = Provider.of<ChatsProvider>(context, listen: false);
      bool findChatIndex = _chatsProvider.chats.indexWhere((chat) => chat.id == _chat.id) > -1;
      if (!findChatIndex) {
        List<Chat> newChats = new List<Chat>.from(_chatsProvider.chats);
        newChats.add(_chat);
        _chatsProvider.setChats(newChats);
      }
      _chatsProvider.setSelectedChat(_chat.id);
      Navigator.of(context).pushNamed(ContactScreen.routeName);
    }
    await _dismissProgressDialog();
    _loading = false;
    notifyListeners();
  }

  void _showProgressDialog() {
    _progressDialog = ProgressDialog(context,
        type: ProgressDialogType.Normal, isDismissible: false);
    _progressDialog.style(
        message: 'Carregando...',
        borderRadius: 10.0,
        backgroundColor: Colors.white,
        progressWidget: CupertinoActivityIndicator(),
        elevation: 10.0,
        insetAnimCurve: Curves.easeInOut,
        progress: 0.0,
        maxProgress: 100.0,
        progressTextStyle: TextStyle(
            color: Colors.black, fontSize: 13.0, fontWeight: FontWeight.w400),
        messageTextStyle: TextStyle(
            color: Colors.black, fontSize: 19.0, fontWeight: FontWeight.w600));
    _progressDialog.show();
  }

  Future<bool> _dismissProgressDialog() {
    return _progressDialog.hide();
  }

  @override
  void dispose() {
    super.dispose();
  }
}