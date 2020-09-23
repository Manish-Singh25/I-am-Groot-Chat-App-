import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:bubble/bubble.dart';

class MainChatPage extends StatefulWidget {
  dynamic currentUserEmail,reciverName,reciverProfilPic,chatId,reciverEmail;
  MainChatPage(currentUserEmail,reciverName,reciverEmail,reciverProfilPic,chatId){
    this.currentUserEmail=currentUserEmail;
    this.reciverName=reciverName;
    this.reciverEmail=reciverEmail;
    this.reciverProfilPic=reciverProfilPic;
    this.chatId=chatId;
  }

  @override
  _MainChatPageState createState() => _MainChatPageState();
}
class _MainChatPageState extends State<MainChatPage> {
  TextEditingController _txtCtrl = TextEditingController();
  final _controller = ScrollController();
  int datecarditerator1 = 1;
  bool datecarditerator2 = true;
  String dateSeter = '';
  Firestore fb = Firestore.instance;
  void sendMessage(){
    var now = new DateTime.now();
    String message = _txtCtrl.text;
    fb
        .collection('/chatapp/messages/solo/'+widget.chatId+'/chats')
        .document(now.toString())
        .setData({
      'email': widget.currentUserEmail,
      'message': message.trim(),
      'time': DateFormat("h:m a").format(now),
      'date': DateFormat("dd-MM-yyyy").format(now)
    });
  }

  chatBubbleDate(ds) {
    var now = new DateTime.now();

    var msgDate = ds['date'];
    var currentDate = DateFormat("dd-MM-yyyy").format(now);
    var currentDate1 = new DateFormat("dd-MM-yyyy").parse(currentDate);
    DateTime tempDate = new DateFormat("dd-MM-yyyy").parse(msgDate);
    var difference = tempDate.difference(currentDate1).inDays;
    if (datecarditerator1 == difference) {
      datecarditerator2 = false;
    } else {
      datecarditerator2 = true;
    }
    if (difference == 0) {
      datecarditerator1 = difference;
      dateSeter = "Today";
    } else if (difference == -1) {
      datecarditerator1 = difference;
      dateSeter = "Yesterday";
    } else if (difference < -1) {
      datecarditerator1 = difference;
      dateSeter = msgDate;
    }
  }

  chatBubbleAlignment(ds) {

    if (ds['email'] == widget.currentUserEmail) {

      return Bubble(
        padding: BubbleEdges.all(8),
        margin: BubbleEdges.fromLTRB(120,10,0,0),
        alignment: Alignment.topRight,
        nip: BubbleNip.rightTop,
        color: Color.fromRGBO(225, 255, 199, 1.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            Text(ds['message'], maxLines: null, textAlign: TextAlign.right),
            Text(
              ds['time'],
              style: TextStyle(fontSize: 10, color: Colors.grey),
            ),
          ],
        ),
      );
    } else {

      return Bubble(
        padding: BubbleEdges.all(8),
        margin: BubbleEdges.fromLTRB(0,10,120,0),
        alignment: Alignment.topLeft,
        nip: BubbleNip.leftTop,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            Text(
              ds['message'],
              maxLines: null,
            ),
            Text(
              ds['time'],
              style: TextStyle(fontSize: 10, color: Colors.grey),
            ),
          ],
        ),
      );
    }
  }

  chatBubble(ds) {

    chatBubbleDate(ds);
    if (datecarditerator2) {

      return Column(
        children: [
          Bubble(
            padding: BubbleEdges.all(8),
            margin: BubbleEdges.only(top: 10),
            alignment: Alignment.center,
            color: Color.fromRGBO(212, 234, 244, 1.0),
            child: Text(dateSeter,
                textAlign: TextAlign.center, style: TextStyle(fontSize: 11.0)),
          ),
          chatBubbleAlignment(ds),
        ],
      );
    } else {

      return chatBubbleAlignment(ds);
    }
  }
  @override
  Widget build(BuildContext context) {
    Timer(
      Duration(seconds: 1),
          () => _controller.jumpTo(_controller.position.maxScrollExtent),
    );
    return Scaffold(
      backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.teal,
          title: Row(
            children: <Widget>[
              CircleAvatar(
                radius: 15,
                child: Image.network(widget.reciverProfilPic),
              ),
              SizedBox(
                width: 10,
              ),
              Text(widget.reciverName),
            ],
          ),
        ),
        body: Container(
          decoration: BoxDecoration(image: DecorationImage(image:AssetImage('images/chatPageBackground.jpg'),
          ),
          ),
            child: Column(

                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    flex: 9,
                    child: StreamBuilder<QuerySnapshot>(
                      stream: fb
                          .collection(
                          '/chatapp/messages/solo/'+widget.chatId+'/chats')
                          .snapshots(),
                      builder: (context, snap) {
                        if (snap.hasData && !snap.hasError && snap.data != null) {
                          return ListView.builder(
                            controller: _controller,
                            itemCount: snap.data.documents.length,
                            itemBuilder: (context, index) {
                              DocumentSnapshot ds = snap.data.documents[index];
                              if(ds['email'] != null) {
                                return chatBubble(ds);
                              }
                              else{

                                return SizedBox(
                                  height: 1,
                                );
                              }
                            },
                          );
                        } else
                          return Text("No data");
                      },
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: SizedBox(
                      height: 1,
                    ),
                  ),
                  SizedBox(
                    height: 14,
                  )
                ])),
        bottomSheet: Container(
          decoration: BoxDecoration(color: Colors.black ),
          child: SingleChildScrollView(
            child: ListTile(
              title: Material(
                elevation: 10,
                borderRadius: BorderRadius.circular(50),
                color: Colors.grey[400],
                child: TextField(
                  cursorColor: Colors.teal,
                  decoration: InputDecoration(hintText: "Enter Message",
                  border: InputBorder.none,
                    contentPadding: EdgeInsets.only(left: 25),
                  ),
                  controller: _txtCtrl,
                  maxLines: null ,
                  style: TextStyle(
                    fontSize: 18,
                  ),
                ),
              ),
              trailing: Material(
                elevation: 10,
                borderRadius: BorderRadius.circular(50),
                color: Colors.teal,
                child: IconButton(
                  icon: Icon(Icons.send),
                  color: Colors.white,
                  onPressed: () {
                    if(_txtCtrl.text.trim()!=''){
                      sendMessage();
                    }
                    _txtCtrl.clear();
                  },
                ),
              ),
            ),
          ),
        ),
      );

  }
}
