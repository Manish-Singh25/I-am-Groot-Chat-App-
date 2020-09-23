import 'package:flutter/material.dart';
import 'auth.dart';
import 'login.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'mainChatPage.dart';
import 'userList.dart';
import 'groupList.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
Firestore _firestore = Firestore.instance;
dynamic _currentUserEmail = '';
dynamic connectedUserlist;
List memberList=List();
class HomePage extends StatefulWidget {
  final baseAuth auth;
  final VoidCallback onSingedout;
  final String currentuser;
  HomePage({this.auth, this.onSingedout, this.currentuser});
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const List<String> choices=<String>['Delete Account','Logout'];
  void _signedOut() async {
    try {
      memberList.clear();
      if (formTypeReturn()) {
        await widget.auth.signOutGoogle();
        widget.onSingedout();
        print('google signout');
      }
      await widget.auth.signedOut();
      widget.onSingedout();
    } catch (e) {
      print(e);
    }
  }
  deleteUser()async{
    String id,email,memberType;
    QuerySnapshot userGroupConnections=await _firestore.collection('/chatapp/users/UserList/'+_currentUserEmail+'/groupConnection').getDocuments();
    for(int i= 0;i<userGroupConnections.documents.length;i++) {
      id = userGroupConnections.documents[i].documentID;
      QuerySnapshot u=await _firestore.collection('/chatapp/messages/groups').document(id).collection(
          'memberList').where('email', isEqualTo: _currentUserEmail).getDocuments();
      print('first for loop Pass 1 $i');
      print(u.documents.length);
      memberType=u.documents[0].data['userType'];
      print('first for loop Pass 2');
      _firestore.collection('/chatapp/messages/groups').document(id).collection('memberList').document(u.documents[0].documentID).delete();
      if(memberType=='Admin'){
        QuerySnapshot qq =await _firestore.collection('/chatapp/messages/groups').document(id).collection('memberList').getDocuments();
        _firestore.collection('/chatapp/messages/groups').document(id).collection('memberList').document(qq.documents[0].documentID).updateData({'userType':'Admin'});
      }
    }
    //TODO:Delete user from userList at end
    print('first for loop Pass 3');
    QuerySnapshot userConnections=await _firestore.collection('/chatapp/users/UserList/'+_currentUserEmail+'/connections').getDocuments();
    for(int i= 0;i<userConnections.documents.length;i++){
      email=userConnections.documents[i].documentID;
      id=userConnections.documents[i].data['chatId'];
      print('Second for loop Pass 1 $i');
      _firestore.collection('/chatapp/messages/solo').document(id).delete();
      _firestore.collection('/chatapp/users/UserList').document(email).collection('connections').document(_currentUserEmail).delete();
    }
    print('Second for loop Pass 2');
    _firestore.collection('/chatapp/users/UserList').document(_currentUserEmail).delete();
    widget.auth.userDelete();
    try{
    widget.onSingedout;
    print('user Signed Out ');
    }catch(e){
      print(e);
      print('user Signed Out Fail');
    }
  }
  void choiceAction(String choice) {
    if(choice == 'Logout'){
      _signedOut();
    }else if(choice=='Delete Account'){
      deleteUser();
    }
  }
  @override
  Widget build(BuildContext context) {
    _currentUserEmail = widget.currentuser;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.teal,
          title: Text('I\'m Groot',style: TextStyle(fontFamily: 'DancingScript',fontWeight: FontWeight.bold,fontSize: 25.0),),
          actions: <Widget>[
//            FlatButton(
//              child: Text('Logout',style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white),),
//              onPressed: _signedOut,
//            ),
            PopupMenuButton<String>(
              offset: Offset(0,100),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              color: Colors.blueGrey[800],
              onSelected: choiceAction,
              itemBuilder: (BuildContext context) {
                return choices.map((String choice) {
                  return PopupMenuItem<String>(
                    value: choice,
                    child: Text(choice,style: TextStyle(color: Colors.white),
                    ),
                  );
                }).toList();
              },
            ),
          ],
        ),
        body: connectedUserPage(widget.auth),

      ),
    );
  }
}

class connectedUserPage extends StatefulWidget {
  baseAuth auth;
  connectedUserPage(auth) {
    this.auth = auth;
  }

  @override
  _connectedUserPage createState() => _connectedUserPage();
}
class _connectedUserPage extends State<connectedUserPage> {
  int bottomSelectedIndex = 0;
  PageController pageController = PageController(
    initialPage: 0,
    keepPage: true,
  );
  void pageChanged(int index) {
    setState(() {
      bottomSelectedIndex = index;
    });
  }

  void bottomTapped(int index) {
    setState(() {
      bottomSelectedIndex = index;
      pageController.animateToPage(index, duration: Duration(milliseconds: 800), curve: Curves.ease);
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: pageController,
        onPageChanged: (index) {
          setState(() {
            pageChanged(index);
          });
        },
        children: <Widget>[
          Scaffold(
            backgroundColor: Colors.blueGrey[800],
            body: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection(
                  '/chatapp/users/UserList/$_currentUserEmail/connections')
                  .snapshots(),
              builder: (context, snap) {
                if (snap.hasData && !snap.hasError && snap.data != null) {
                  for(int i= 0;i<snap.data.documents.length;i++){
                    memberList.add(snap.data.documents[i].documentID);
                  }
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
                          title: Text(ds['name'],
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          subtitle: Text(ds['about'],
                              style: TextStyle(color: Colors.white,),
                          ),
                          onTap: () {
                            Navigator.push(
                                context, MaterialPageRoute(builder: (context) => MainChatPage(_currentUserEmail,ds['name'],ds['email'],ds['profilePic'],ds['chatId'])));
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
                  return Center(
                    child: CircularProgressIndicator(
                    ),
                  );
              },
            ),
            floatingActionButton: FloatingActionButton(
              backgroundColor: Colors.greenAccent,
              child: Icon(Icons.message),
              onPressed: () {
                Navigator.push(
                    context, MaterialPageRoute(builder: (context) => userList(_currentUserEmail,memberList)));
              },
            ),

          ),
          GroutList(_currentUserEmail,),
        ],

      ),
      bottomNavigationBar: CurvedNavigationBar(
        index: bottomSelectedIndex,
        height: 50,
        color: Colors.teal,
        buttonBackgroundColor:Colors.teal,
        backgroundColor: Colors.blueGrey[800],
        items: <Widget>[
          Icon(Icons.person, size: 30),
          Icon(Icons.people, size: 30),
        ],
        onTap: (index) {
          setState(() {
            bottomTapped(index);
          });
        },
      ),
    );
  }
}




