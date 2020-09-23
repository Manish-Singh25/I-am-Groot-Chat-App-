import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_flexible_toast/flutter_flexible_toast.dart';
Firestore _firestore=Firestore.instance;
class userList extends StatefulWidget {
  dynamic currentUserEmail;
  List memberList;
  userList(currentUserEmail,memberList){
    this.currentUserEmail=currentUserEmail;
    this.memberList=memberList;
  }

  @override
  _userListState createState() => _userListState();
}

class _userListState extends State<userList> {
  createChatConnection(email) async {
    setState(() {
      widget.memberList.add(email);
    });
    String name, about, profilPic;
    var j = email.toString().split("@");
    var yy = widget.currentUserEmail.toString().split("@");
    String chatId = j[0] + '_' + yy[0];
    DocumentSnapshot result = await _firestore
        .collection('chatapp/users/UserList')
        .document(widget.currentUserEmail)
        .get();
    name = result['name'];
    about = result['about'];
    profilPic = result['profilePic'];
    _firestore
        .collection('chatapp/users/UserList')
        .document(email)
        .collection('connections')
        .document(widget.currentUserEmail)
        .setData({
      'chatId': chatId,
      'name': name,
      'profilePic': profilPic,
      'about': about
    });
    result = await _firestore
        .collection('chatapp/users/UserList')
        .document(email)
        .get();
    name = result['name'];
    about = result['about'];
    profilPic = result['profilePic'];
    _firestore
        .collection('chatapp/users/UserList')
        .document(widget.currentUserEmail)
        .collection('connections')
        .document(email)
        .setData({
      'chatId': chatId,
      'name': name,
      'profilePic': profilPic,
      'about': about
    });
    _firestore
        .collection('/chatapp/messages/solo')
        .document(chatId)
        .collection('chats').document('default').setData({'email': null});
    }

  @override
  Widget build(BuildContext context) {
    print(widget.memberList );
    return Scaffold(
      backgroundColor: Colors.blueGrey[800],
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: Text("User List"),
      ),
      body: Center(
        child: StreamBuilder<QuerySnapshot>(
          stream: _firestore.collection("chatapp/users/UserList").snapshots(),
          builder: (context, snap) {
            if (snap.hasData && !snap.hasError && snap.data != null) {
              return ListView.separated(
                itemCount: snap.data.documents.length,
                itemBuilder: (context, index) {
                  DocumentSnapshot ds = snap.data.documents[index];

                  if (ds['email'] != widget.currentUserEmail && !widget.memberList.contains(ds['email'])) {
                    return Material(
                      color: Colors.blueGrey[800],
                      borderOnForeground: true,
                      child: ListTile(
                        leading: CircleAvatar(
                          radius: 15,
                          child: Image.network(ds['profilePic']),
                        ),
                        title: Text(ds['name'],
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold
                        ),
                        ),
                        subtitle: Text(ds['about'],
                          style: TextStyle(
                          color: Colors.white,
                        ),
                        ),
                        onTap: () {

                          FlutterFlexibleToast.showToast(
                              message: "User Added !",
                              toastLength: Toast.LENGTH_LONG,
                              toastGravity: ToastGravity.BOTTOM,
                              radius: 70,
                              textColor: Colors.white,
                              backgroundColor: Colors.grey,
                              timeInSeconds: 1
                          );
                          createChatConnection(ds['email']);
                          Navigator.pop(context);
                        },
                      ),
                    );
                  } else {
                    return SizedBox(
                      height: 0,
                    );
                  }
                },
                separatorBuilder: (context, index) {
                  return Divider(
                    color: Colors.grey,
                    height: 0.5,
                    indent: 70,
                  );
                },
              );
            } else
              return Text("No data found");
          },
        ),
      ),
    );
  }
}