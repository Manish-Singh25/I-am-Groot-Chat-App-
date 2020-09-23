import 'package:flutter/material.dart';
import 'auth.dart';
import 'home_page.dart';
import 'login.dart';

class RootPage extends StatefulWidget {
  final baseAuth auth;
  RootPage({this.auth});

  @override
  _RootPageState createState() => _RootPageState();
}

enum AuthStatus { signedIn, notSignedIn }

class _RootPageState extends State<RootPage> {
  AuthStatus _authStatus = AuthStatus.notSignedIn;
  dynamic currentUserEmail;
  void _signedIn() async {
    setState(()  {
      widget.auth.currentUser().then((value){currentUserEmail = value;});
      _authStatus = AuthStatus.signedIn;
    });
  }

  void _signedOut() {
    setState(() {
      _authStatus = AuthStatus.notSignedIn;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    widget.auth.currentUser().then((value) {
      _authStatus =
          value == null ? AuthStatus.notSignedIn : AuthStatus.signedIn;
    });
  }

  @override
  Widget build(BuildContext context) {
    switch (_authStatus) {
      case AuthStatus.notSignedIn:
        return LoginPage(auth: widget.auth, onSignedIn: _signedIn);
      case AuthStatus.signedIn:
        return HomePage(auth: widget.auth, onSingedout: _signedOut,currentuser: currentUserEmail,);
    }
  }
}
