import 'dart:async';
import 'groupMemberList.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_flexible_toast/flutter_flexible_toast.dart';
import 'package:intl/intl.dart';
import 'package:bubble/bubble.dart';
import 'groupChatConnectionList.dart';
class GroupChatPage extends StatefulWidget {
  dynamic currentUserEmail,groupName,groupProfilPic,groupId,currentUserName;
  List memberList = [];
  GroupChatPage(currentUserEmail,groupName,groupProfilPic,groupId,currentUserName){
    this.currentUserEmail=currentUserEmail;
    this.groupName=groupName;
    this.groupProfilPic=groupProfilPic;
    this.groupId=groupId;
    this.currentUserName=currentUserName;
  }

  @override
  _GroupChatPageState createState() => _GroupChatPageState();
}
class _GroupChatPageState extends State<GroupChatPage> {
  TextEditingController _txtCtrl = TextEditingController();
  int datecarditerator1 = 1;
  bool datecarditerator2 = true;
  String dateSeter = '';
  String memberType = "member";
  Firestore fb = Firestore.instance;
  final _controller = ScrollController();

    checkMemberType() async{
    QuerySnapshot ds = await fb
        .collection('/chatapp/messages/groups/'+widget.groupId+'/memberList').where('email', isEqualTo: widget.currentUserEmail).getDocuments();

    memberType = ds.documents[0].data['userType'];
    QuerySnapshot ds1 = await fb
        .collection('/chatapp/messages/groups/'+widget.groupId+'/memberList').getDocuments();
    var d = ds1.documents.length;
    for(int i= 0;i<d;i++){
      widget.memberList.add(ds1.documents[i].data['email']);
    }
  }
  void sendMessage(){
    var now = new DateTime.now();
    String message = _txtCtrl.text;

    fb
        .collection('/chatapp/messages/groups/'+widget.groupId+'/chats')
        .document(now.toString())
        .setData({
      'email': widget.currentUserEmail,
      'name':widget.currentUserName,
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(ds['name'],textAlign: TextAlign.left, maxLines: null,style: TextStyle(
              fontWeight: FontWeight.bold,
            ),),
            Text(
              ds['message'], maxLines: null,
            ),
            Text(
              ds['time'],textAlign: TextAlign.right,
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
    checkMemberType();
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: FlatButton(
          onPressed: (){
            Navigator.push(
                context, MaterialPageRoute(builder: (context) =>
                GroutMemberList(widget.groupId,widget.groupName,widget.groupProfilPic,widget.currentUserEmail)));
          },
          child: Row(
            children: <Widget>[
              CircleAvatar(
                radius: 15,
                child: Image.network(widget.groupProfilPic),
              ),
              SizedBox(
                width: 10,
              ),
              Text(widget.groupName),
            ],
          ),
        ),
        actions: <Widget>[
        IconButton(
          icon: Icon(Icons.person_add), onPressed:(){
          if(memberType == "Admin") {
            print(widget.memberList);
            Navigator.push(
                context, MaterialPageRoute(builder: (context) =>
                GroupChatConnectionList(widget.currentUserEmail, widget.groupId,
                    widget.groupProfilPic,widget.groupName,widget.memberList)));
          }
          else{
            FlutterFlexibleToast.showToast(
                message: "Only Group Admin Can Add New Member",
                toastLength: Toast.LENGTH_LONG,
                toastGravity: ToastGravity.BOTTOM,
                radius: 70,
                textColor: Colors.white,
                backgroundColor: Colors.grey,
                timeInSeconds: 2
            );
          }
          }
    )
        ],
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
                        '/chatapp/messages/groups/'+widget.groupId+'/chats')
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
                maxLines: null,

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
                color: Colors.white,
                icon: Icon(Icons.send),
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
