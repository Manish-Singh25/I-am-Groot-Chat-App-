import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:flutter_flexible_toast/flutter_flexible_toast.dart';
import 'auth.dart';
class LoginPage extends StatefulWidget {
  final VoidCallback onSignedIn;
  final baseAuth auth;
  LoginPage({this.auth, this.onSignedIn});

  @override
  _LoginPageState createState() => _LoginPageState();
}

enum FormType { login, register, googleSignIn }
FormType _formType = FormType.login;
bool formTypeReturn() {
  if (_formType == FormType.googleSignIn) {
    return true;
  } else {
    return false;
  }
}

class _LoginPageState extends State<LoginPage> {
  final formkey = GlobalKey<FormState>();
  String _email, _password,_name,_about;

  bool validateAndSave() {
    final form = formkey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    } else {
      return false;
    }
  }

  void validateAndSubmit() async {
    if (_formType == FormType.googleSignIn || validateAndSave()) {
      try {
        FlutterFlexibleToast.showToast(
            message: " Logging In",
            toastLength: Toast.LENGTH_LONG,
            toastGravity: ToastGravity.BOTTOM,
            icon: ICON.LOADING,
            radius: 70,
            textColor: Colors.white,
            backgroundColor: Colors.grey,
            timeInSeconds: 2
        );
        if (_formType == FormType.login) {
          String userID =
              await widget.auth.signInWithEmailAndPassword(_email, _password);
          print('login Success $userID');
        } else if (_formType == FormType.googleSignIn) {
          String userID = await widget.auth.signedInWithGoogle();
          googleSignIn();
          print('Google Login Success');
        } else {
          String userID = await widget.auth
              .createUserWithEmailAndPassword(_email, _password,_name,_about);
          print(userID);
          print('Register Success $userID');
        }
        widget.onSignedIn();
      } catch (e) {
        print(e);
        print('Man Fail');
        FlutterFlexibleToast.showToast(
            message: "Login Fail !",
            toastLength: Toast.LENGTH_LONG,
            toastGravity: ToastGravity.BOTTOM,
            radius: 70,
            textColor: Colors.white,
            backgroundColor: Colors.grey,
            timeInSeconds: 2
        );
      }
    }
  }

  void moveToRegister() {
    formkey.currentState.reset();
    setState(() {
      _formType = FormType.register;
    });
  }

  void moveToLogin() {
    formkey.currentState.reset();
    setState(() {
      _formType = FormType.login;
    });
  }
  void signInWithEmailAndPassword() {
    setState(() {
      _formType = FormType.login;
    });
  }
  void googleSignIn() {
    setState(() {
      _formType = FormType.googleSignIn;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.blueGrey[800],
        resizeToAvoidBottomPadding: true,
        body: Padding(
          padding: EdgeInsets.fromLTRB(25.0,25.0,25.0,0),
          child: Form(
            key: formkey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: buildInputs() + buildSubmitButtons(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> buildInputs() {
    return [
      Padding(
        padding: const EdgeInsets.only(top: 50),
        child: CircleAvatar(
          radius: 50,
          child: ClipOval(
            child:Image.asset('images/LoginPageAvatar.jpg',
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
      Center(child: Text('I\'m Groot',style: TextStyle(fontSize: 30.0,color: Colors.white,fontWeight: FontWeight.bold,fontFamily: 'DancingScript'),)),
      SizedBox(
        height: 10,
      ),
      Material(
        elevation: 10,
        borderRadius: BorderRadius.circular(50),
        child: TextFormField(
          decoration: InputDecoration(
            labelText: 'Enter Email',
            prefixIcon: Icon(Icons.mail_outline),
            contentPadding: EdgeInsets.only(left: 50),
            border: InputBorder.none,
          ),
          validator: (value) => value.isEmpty ? 'Email can\'t be empty' : null,
          onSaved: (value) => _email = value.trim(),
        ),
      ),
      SizedBox(height: 5.0,),
      Material(
        elevation: 10,
        borderRadius: BorderRadius.circular(50),
        child: TextFormField(

          decoration: InputDecoration(
            border: InputBorder.none,
            labelText: 'Enter Password',
            prefixIcon: Icon(Icons.vpn_key),
            contentPadding: EdgeInsets.only(left: 50),
          ),
          obscureText: true,
          validator: (value) => value.isEmpty ? 'Password can\'t be empty' : null,

          onSaved: (value) => _password = value.trim(),
        ),
      ),
      SizedBox(height: 5.0,),
    ];
  }

  List<Widget> buildSubmitButtons() {
    if (_formType == FormType.login || _formType == FormType.googleSignIn) {
      return [
        SizedBox(height: 5.0,),
        RaisedButton.icon(
            label: Text('Login'),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(50.0),
            ),
            onPressed: (){
              signInWithEmailAndPassword();
              validateAndSubmit();
            },
            icon: Icon(Icons.lock_outline)),
        SizedBox(height: 5.0,),
        SignInButton(
          Buttons.Google,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50.0)),
          text: "Sign up with Google",
          onPressed: () {
            googleSignIn();
            validateAndSubmit();
          },
        ),
        SizedBox(height: 5.0,),
        FlatButton(
          child: Text('Create an account',style: TextStyle(color: Colors.white),),
          onPressed: moveToRegister,
        ),
      ];
    } else {
      return [
        SizedBox(height: 5.0,),
        Material(
          elevation: 10,
          borderRadius: BorderRadius.circular(50),
          child: TextFormField(
            decoration: InputDecoration(
              border: InputBorder.none,
              labelText: 'Enter Name',
              contentPadding: EdgeInsets.only(left: 50),
              prefixIcon: Icon(Icons.supervised_user_circle),
            ),
            validator: (value) => value.isEmpty ? 'Name can\'t be empty' : null,
            onSaved: (value) => _name = value.trim(),
          ),
        ),
        SizedBox(height: 5.0,),
        Material(
          elevation: 10,
          borderRadius: BorderRadius.circular(50),
          child: TextFormField(
            decoration: InputDecoration(
              border: InputBorder.none,
              labelText: 'About',
              contentPadding: EdgeInsets.only(left: 50),
              prefixIcon: Icon(Icons.library_books),
            ),
            validator: (value) => value.isEmpty ? 'About can\'t be empty' : null,
            onSaved: (value) => _about = value.trim(),
          ),
        ),
        SizedBox(height: 5.0,),
        RaisedButton.icon(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50.0)),
          label: Text('Create an account'),
          onPressed: validateAndSubmit,
          icon: Icon(Icons.lock_outline),
        ),
        SizedBox(height: 5.0,),
        FlatButton(
          child: Text('Already have account ? Login',style: TextStyle(color: Colors.white),),
          onPressed: moveToLogin,
        ),
      ];
    }
  }
}
