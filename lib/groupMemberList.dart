import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


Firestore _firestore=Firestore.instance;
class GroutMemberList extends StatefulWidget {
  dynamic groupId,groupName,groupProfilPic,currentUserEmail;
  GroutMemberList(groupId,groupName,groupProfilPic,currentUserEmail){
    this.groupId=groupId;
    this.groupName=groupName;
    this.groupProfilPic=groupProfilPic;
    this.currentUserEmail=currentUserEmail;
  }

  @override
  _GroutMemberListState createState() => _GroutMemberListState();
}

class _GroutMemberListState extends State<GroutMemberList> {
String buttontxt='';
  checkMemberType(memberType){
    if(memberType=='Admin'){
      buttontxt='Demote Admin';
    }else{
      buttontxt='Create Admin';
    }
    return buttontxt;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: Row(children: <Widget>[
          CircleAvatar(
            radius: 15,
            child: Image.network(widget.groupProfilPic),
          ),
          SizedBox(
            width: 10,
          ),
          Text(widget.groupName),
        ],),
      ),
      backgroundColor: Colors.blueGrey[800],
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection(
            '/chatapp/messages/groups/'+widget.groupId+'/memberList')
            .snapshots(),
        builder: (context, snap) {
          if (snap.hasData && !snap.hasError && snap.data != null) {
            return ListView.separated(
              itemCount: snap.data.documents.length,
              itemBuilder: (context, index) {
                DocumentSnapshot ds = snap.data.documents[index];
                if(ds['email']!=widget.currentUserEmail){
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
                          fontWeight: FontWeight.bold,
                          color: Colors.white
                      ),
                    ),
                    subtitle: Text(ds['email'],style: TextStyle(color: Colors.white),),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                      RaisedButton(
                        padding: EdgeInsets.all(5),
                        shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50.0),
                          ),
                        child:Text(checkMemberType(ds['userType'])),
                        color: Colors.teal,
                        onPressed: (){
                          if(ds['userType']=='Admin'){
                            _firestore.collection('/chatapp/messages/groups/'+widget.groupId+'/memberList').document(ds.documentID).updateData({'userType':'member'});
                          }else{
                            _firestore.collection('/chatapp/messages/groups/'+widget.groupId+'/memberList').document(ds.documentID).updateData({'userType':'Admin'});
                          }

                        },
                      ),
                      IconButton(icon: Icon(Icons.remove_circle,color: Colors.red), onPressed: (){
                        _firestore.collection('/chatapp/messages/groups/'+widget.groupId+'/memberList').document(ds.documentID).delete();
                        _firestore.collection('/chatapp/users/UserList/'+ds['email']+'/groupConnection').document(widget.groupId).delete();
                      }),
                    ],),
                    onTap: () {
                    },
                  ),
                );
                }else{
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
                            fontWeight: FontWeight.bold,
                            color: Colors.white
                        ),
                      ),
                      subtitle: Text(ds['email'],style: TextStyle(color: Colors.white),),
                      onTap: () {
                      },
                    ),
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
    );
  }
}


