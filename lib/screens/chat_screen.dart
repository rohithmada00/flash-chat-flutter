import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flash_chat/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';

final _firestore = FirebaseFirestore.instance;
late User loggedInUser;

class ChatScreen extends StatefulWidget {
  static String id = 'chat';
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final messagetextController = TextEditingController();
  final _auth = FirebaseAuth.instance;
  late String messageText;

  void getCurrentUser() {
    try {
      final user = _auth.currentUser!;
      loggedInUser = user;
      if (user != null) {
        loggedInUser = user;
        print(loggedInUser.email);
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: null,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.alarm),
              onPressed: () {
                _firestore.collection('messages').add({
                  'text': 'qwertyuiopasdfghjklzxcvbnm',
                  'sender': loggedInUser.email,
                  'time': DateTime.now()
                });
                FlutterRingtonePlayer.playAlarm();
              }),
          IconButton(
              icon: Icon(Icons.check),
              onPressed: () {
                _firestore.collection('messages').add({
                  'text': 'I\'m on my way ',
                  'sender': loggedInUser.email,
                  'time': DateTime.now()
                });
              }),
          IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                _firestore.collection('messages').add({
                  'text': 'I can\'t join now',
                  'sender': loggedInUser.email,
                  'time': DateTime.now()
                });
              }),
          IconButton(
              icon: Icon(Icons.alarm_off),
              onPressed: () {
                FlutterRingtonePlayer.stop();
              }),
          IconButton(
              icon: Icon(Icons.logout),
              onPressed: () {
                _auth.signOut();
                Navigator.pop(context);
              }),
        ],
        title: Text('Flash Chat ⚡'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            MessagesStream(),
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: messagetextController,
                      onChanged: (value) {
                        messageText = value;
                      },
                      decoration: kMessageTextFieldDecoration,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      messagetextController.clear();
                      _firestore.collection('messages').add({
                        'text': messageText,
                        'sender': loggedInUser.email,
                        'time': DateTime.now()
                      });
                    },
                    child: Text(
                      'Send',
                      style: kSendButtonTextStyle,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MessagesStream extends StatelessWidget {
  const MessagesStream({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('messages').orderBy('time').snapshots(),
      builder: (context, snapshot) {
        List<MessageBubble> messageBubbles = [];

        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(
              backgroundColor: Colors.lightBlueAccent,
            ),
          );
        }

        final messages = snapshot.data;

        if (messages != null) {
          // messages.docs.sort((a, b) => a['time'].compareTo(b['time']));
          for (var messageData in messages.docs.reversed) {
            final messageText = messageData['text'];
            final messageSender = messageData['sender'];
            final messageTime = messageData['time'];
            final currentUser = loggedInUser.email;
            MessageBubble messageBubble;

            if (messageText == 'qwertyuiopasdfghjklzxcvbnm') {
              // FlutterRingtonePlayer.play(
              //   android: AndroidSounds.ringtone,
              //   ios: IosSounds.glass,
              //   looping: true, // Android only - API >= 28
              //   asAlarm: true, // Android only - all APIs
              // );

              final formattedTime = messageTime.toDate();

              if (formattedTime.hour == DateTime.now().hour &&
                  formattedTime.minute == DateTime.now().minute &&
                  DateTime.now().day == formattedTime.day &&
                  DateTime.now().month == formattedTime.month &&
                  DateTime.now().year == formattedTime.year) {
                FlutterRingtonePlayer.playAlarm();
              }
              messageBubble = MessageBubble(
                sender: messageSender,
                text: 'Lets go to mess',
                isMe: currentUser == messageSender,
              );
            } else {
              messageBubble = MessageBubble(
                sender: messageSender,
                text: messageText,
                isMe: currentUser == messageSender,
              );
            }

            messageBubbles.add(messageBubble);
          }
        }
        return Expanded(
          child: ListView(
            reverse: true,
            padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
            children: messageBubbles,
          ),
        );
      },
    );
  }
}

class MessageBubble extends StatelessWidget {
  late final String sender;
  late final String text;
  final bool isMe;

  MessageBubble({required this.sender, required this.text, required this.isMe});

  //$messageText  $messageSender

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            sender,
            style: TextStyle(
              fontSize: 12.0,
              color: Colors.black54,
            ),
          ),
          Material(
            elevation: 10,
            borderRadius: isMe
                ? BorderRadius.only(
                    topLeft: Radius.circular(30.0),
                    bottomLeft: Radius.circular(30.0),
                    bottomRight: Radius.circular(30.0),
                  )
                : BorderRadius.only(
                    topRight: Radius.circular(30.0),
                    bottomLeft: Radius.circular(30.0),
                    bottomRight: Radius.circular(30.0),
                  ),
            color: isMe ? Colors.lightBlueAccent : Colors.white,
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 15.0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
