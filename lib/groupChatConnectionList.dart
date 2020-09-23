import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_flexible_toast/flutter_flexible_toast.dart';

class GroupChatConnectionList extends StatefulWidget {
  dynamic currentUserEmail,groupId,groupProfilPic,groupName;
  List memberList=List();
  GroupChatConnectionList(currentUserEmail,groupId,groupProfilPic,groupName,memberList){
    this.currentUserEmail=currentUserEmail;
    this.groupId=groupId;
    this.groupProfilPic=groupProfilPic;
    this.groupName=groupName;
    this.memberList=memberList;
  }
  @override
  _GroupChatConnectionListState createState() => _GroupChatConnectionListState();
}

class _GroupChatConnectionListState extends State<GroupChatConnectionList> {
  Firestore _firestore=Firestore.instance;


  createGroupConnection(ds){
    _firestore.collection('/chatapp/users/UserList').document(ds['email']).collection('groupConnection').document(widget.groupId).setData({
      'groupname':widget.groupName,
      'profilePic':widget.groupProfilPic,
      'name':ds['name'],
    });
    _firestore.collection('/chatapp/messages/groups').document(widget.groupId).collection('memberList').add({
      'email':ds['email'],
      'name':ds['name'],
      'profilePic':ds['profilePic'],
      'userType':'member'
    });
    setState(() {
      widget.memberList.add(ds['email']);
    });
  }

  @override
  Widget build(BuildContext context) {

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
                  print(widget.memberList.length);
                  if (ds['email'] != widget.currentUserEmail && !widget.memberList.contains(ds['email'])) {
                    return Material(
                      color: Colors.blueGrey[800],
                      borderOnForeground: true,
                      child: ListTile(
                        leading: CircleAvatar(
                          radius: 15,
                          child: Image.network(ds['profilePic']),
                        ),
                        title: Text(ds['name'],style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold
                        ),
                        ),
                        subtitle: Text(ds['email'],style: TextStyle(
                            color: Colors.white,
                        ),
                        ),
                        trailing: IconButton(
                          icon:Icon(Icons.add),
                          color: Colors.white,
                          onPressed: (){
                            createGroupConnection(ds);
                            FlutterFlexibleToast.showToast(
                                message: "User Added !",
                                toastLength: Toast.LENGTH_LONG,
                                toastGravity: ToastGravity.BOTTOM,
                                radius: 70,
                                textColor: Colors.white,
                                backgroundColor: Colors.grey,
                                timeInSeconds: 1
                            );
                        },
                        ),
                        onTap: () {

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

