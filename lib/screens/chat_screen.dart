import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flash_chat/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart' as cloud;

final _firestore = cloud.FirebaseFirestore.instance;
auth.User loggedInUser;

class ChatScreen extends StatefulWidget {
  static const String id = "chatScreen";
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _auth = auth.FirebaseAuth.instance;
  final messageTextController = TextEditingController();
  String msgText;

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  void getCurrentUser() async {
    try {
      final user = await _auth.currentUser;
      if (user != null) {
        loggedInUser = user;
        print(loggedInUser.email);
      }
    } catch (e) {
      print(e);
    }
  }

  void getMessages() async {
    cloud.QuerySnapshot querySnapshot =
        await _firestore.collection('messages').get();
    final messages = querySnapshot.docs.map((doc) => doc.data()).toList();
    for (var message in messages) {
      print(message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: null,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                //Implement logout functionality
                getMessages();
                _auth.signOut();
                Navigator.pop(context);
              }),
        ],
        title: Text('⚡️Chat'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            MessageStream(),
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: messageTextController,
                      onChanged: (value) {
                        //Do something with the user input.
                        msgText = value;
                      },
                      decoration: kMessageTextFieldDecoration,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      //Implement send functionality.
                      messageTextController.clear();
                      _firestore.collection('messages').add({
                        'text': msgText,
                        'sender': loggedInUser.email,
                        'textTime': cloud.FieldValue.serverTimestamp(),
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

class MessageBubble extends StatelessWidget {
  MessageBubble({@required this.text, @required this.sender, this.isMe});
  final String text;
  final String sender;
  final bool isMe;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Text(
            sender,
            style: TextStyle(
              color: Colors.black45,
              fontSize: 10.0,
            ),
          ),
          Material(
            color: isMe ? Colors.blueAccent : Colors.white,
            borderRadius: isMe
                ? BorderRadius.only(
                    topLeft: Radius.circular(30.0),
                    bottomRight: Radius.circular(30.0),
                    bottomLeft: Radius.circular(30.0),
                  )
                : BorderRadius.only(
                    topRight: Radius.circular(30.0),
                    bottomRight: Radius.circular(30.0),
                    bottomLeft: Radius.circular(30.0),
                  ),
            child: Padding(
              padding: EdgeInsets.all(10.0),
              child: Text(
                text,
                style: TextStyle(
                  color: isMe ? Colors.white : Colors.black54,
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

class MessageStream extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<dynamic>(
      stream: _firestore.collection('messages').orderBy('textTime').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(
              backgroundColor: Colors.lightBlueAccent,
            ),
          );
        }
        List<MessageBubble> messageBubbles = [];
        final messages = snapshot.data.docs.reversed;
        for (var message in messages) {
          final messageText = message.get('text');
          final messageSender = message.get('sender');
          final currentUser = loggedInUser.email;

          final messageBubble = MessageBubble(
            text: messageText,
            sender: messageSender,
            isMe: currentUser == messageSender,
          );
          messageBubbles.add(messageBubble);
        }
        return Expanded(
          child: ListView(
            reverse: true,
            padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 10.0),
            children: messageBubbles,
          ),
        );
      },
    );
  }
}

// StreamBuilder<dynamic>(
//   //set up the Stream, where all the data are coming from
//   stream: _firestore.collection('messages').snapshots(),
//
//   //lets build this
//   builder: (context, snapshot) {
//     //create a list of widgets
//     List<Text> messageWidgets = [];
//
//     //check if we got data or not
//     if (snapshot.hasData) {
//       //load in our data list
//       final messages = snapshot.data.docs;
//
//       //loop all of data in our list
//       for (var message in messages) {
//         //get text
//         final messageText = message.get('text');
//
//         //get sender
//         final messageSender = message.get('sender');
//
//         //create a new Text Widget
//         final messageWidget =
//             Text('$messageText from $messageSender');
//
//         //add this Widget to our Widget list
//         messageWidgets.add(messageWidget);
//       }
//     }
//
//     return Column(
//       children: messageWidgets,
//     );
//   },
// ),
