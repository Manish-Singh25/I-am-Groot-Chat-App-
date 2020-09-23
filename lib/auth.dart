import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

abstract class baseAuth {
  Future<String> signInWithEmailAndPassword(String email, String password);
  Future<String> createUserWithEmailAndPassword(
      String email, String password, String name, String about);
  Future<String> signedInWithGoogle();
  Future<String> currentUser();
  Future<void> signedOut();
  Future<void> signOutGoogle();
  Future<void> userDelete();
}

class Auth implements baseAuth {

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();
  Future<String> signInWithEmailAndPassword(
      String email, String password) async {
    AuthResult result = await _firebaseAuth.signInWithEmailAndPassword(
        email: email, password: password);
    FirebaseUser user = result.user;
    currentUser();
    return user.email;
  }

  Future<String> signedInWithGoogle() async {

    final GoogleSignInAccount googleSignInAccount = await googleSignIn.signIn();
    final GoogleSignInAuthentication googleSignInAuthentication =
        await googleSignInAccount.authentication;
    final AuthCredential credential = GoogleAuthProvider.getCredential(
      accessToken: googleSignInAuthentication.accessToken,
      idToken: googleSignInAuthentication.idToken,
    );
    final AuthResult authResult =
        await _firebaseAuth.signInWithCredential(credential);
    final FirebaseUser user = authResult.user;
    assert(!user.isAnonymous);
    assert(await user.getIdToken() != null);
    final FirebaseUser currentUser = await _firebaseAuth.currentUser();
    assert(user.uid == currentUser.uid);
    String path = '/chatapp/users/UserList';
    final snapshot = await Firestore.instance.collection(path+user.email).getDocuments();
    if (snapshot.documents.length==0) {
      Firestore.instance.collection(path).document(user.email).setData({
        'name': user.displayName,
        'email': user.email,
        'password': 'GoogleSignIn',
        'about': 'Hey I,am on chat app',
        'profilePic': user.photoUrl
      });
    }
    return currentUser.uid;
  }

  Future<String> createUserWithEmailAndPassword(
      String email, String password, String name, String about) async {
    AuthResult result = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email, password: password);
    String path = '/chatapp/users/UserList';
    Firestore.instance.collection(path).document(email).setData({
      'name': name,
      'email': email,
      'password': password,
      'about': about,
      'profilePic':
          'https://upload.wikimedia.org/wikipedia/commons/thumb/7/7e/Circle-icons-profile.svg/1200px-Circle-icons-profile.svg.png'
    });
    FirebaseUser user = result.user;
    return user.uid;
  }

  Future<String> currentUser() async {
    FirebaseUser user = await _firebaseAuth.currentUser();
    try {
      return user.email;
    } catch (e) {
      return null;
    }
  }
  Future<void> userDelete() async {
    FirebaseUser user = await _firebaseAuth.currentUser();
    try {
      user.delete();
      print('user Deleted');
    } catch (e) {
      print(e);
      print('user Delete fail');
    }
  }
  Future<void> signOutGoogle() async {
    await googleSignIn.signOut();
    print("User Sign Out");
  }

  Future<void> signedOut() async {
    return _firebaseAuth.signOut();
  }
}
