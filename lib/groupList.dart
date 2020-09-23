import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_flexible_toast/flutter_flexible_toast.dart';
import 'groupChatPage.dart';
import 'package:awesome_dialog/awesome_dialog.dart';


Firestore _firestore=Firestore.instance;
String _createGroupName='';
class GroutList extends StatelessWidget {
  dynamic currentUserEmail;
  GroutList(currentUserEmail){
    this.currentUserEmail=currentUserEmail;
  }
  TextEditingController _txtCtrl = TextEditingController();
  createGroup() async {
    var now = new DateTime.now();
    DocumentSnapshot  ds =await _firestore.collection('/chatapp/users/UserList').document(currentUserEmail).get();
    dynamic groupId=_txtCtrl.text+'_'+now.toString();
    _firestore.collection('/chatapp/users/UserList/'+currentUserEmail+'/groupConnection').document(groupId).setData({
      'groupname':_txtCtrl.text,
      'name':ds['name'],
    'profilePic':'https://cdn.pixabay.com/photo/2016/04/15/18/05/computer-1331579_960_720.png',
    });

    _firestore.collection('/chatapp/messages/groups').document(groupId).collection("memberList").add({
      'email':ds['email'],
      'name':ds['name'],
      'profilePic':ds['profilePic'],
      'userType':"Admin",
    });
    _firestore.collection('/chatapp/messages/groups').document(groupId).collection("chats").document('default').setData({
      'email':null,
    });
  }
  validateAndSave() {
    if (_txtCtrl.text!='') {
      createGroup();
    } else {
      FlutterFlexibleToast.showToast(
          message: "Group Name Cannot be Empty",
          toastLength: Toast.LENGTH_LONG,
          toastGravity: ToastGravity.BOTTOM,
          radius: 70,
          textColor: Colors.white,
          backgroundColor: Colors.grey,
          timeInSeconds: 2
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[800],
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection(
            '/chatapp/users/UserList/'+currentUserEmail+'/groupConnection')
            .snapshots(),
        builder: (context, snap) {
          if (snap.hasData && !snap.hasError && snap.data != null) {
            return ListView.separated(
              itemCount: snap.data.documents.length,
              itemBuilder: (context, index) {
                DocumentSnapshot ds = snap.data.documents[index];
                return Material(
                  color: Colors.blueGrey[800],
                  borderOnForeground: true,
                  child: ListTile(
                    leading: CircleAvatar(
                      radius: 15,
                      child: Image.network(ds['profilePic']),
                    ),
                    title: Text(ds['groupname'],
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white
                      ),
                    ),
                    onTap: () {
                      Navigator.push(
                          context, MaterialPageRoute(builder: (context) => GroupChatPage(currentUserEmail,ds['groupname'],ds['profilePic'],ds.documentID,ds['name'])));
                    },
                  ),
                );
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
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.greenAccent,
        child: Icon(Icons.person_add),
        onPressed: () {
          AwesomeDialog(
            context: context,
            animType: AnimType.SCALE,
            dialogType: DialogType.INFO,
            body: Center(child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 5, 45, 5),
                  child: TextField(
                    decoration: InputDecoration(
                      icon: Icon(Icons.people_outline),
                      labelText: 'Enter Group Name',
                    ),
                    controller:_txtCtrl,
                  ),
                )
              ],
            ),
            ),
            title: 'This is Ignored',
            desc:   'This is also Ignored',
            dismissOnTouchOutside: false,
            btnOkOnPress: (){
              validateAndSave();
            },
            btnCancelOnPress:(){
            },
          )..show();
        },
      ),
    );
  }
}


