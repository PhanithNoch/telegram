import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:telegramchatapp/Pages/HomePage.dart';
import 'package:telegramchatapp/Widgets/ProgressWidget.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  final GoogleSignIn googleSignIn = GoogleSignIn();
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  bool isLoggedIn = false;
  bool isLoading = false;
  FirebaseUser currentUser;
  SharedPreferences preferences;

  @override
  void initState() {
    isSignedIn();
    super.initState();
  }

  void isSignedIn() async {
    setState(() {
      isLoggedIn = true;
    });
    preferences = await SharedPreferences.getInstance();
    isLoggedIn = await googleSignIn.isSignedIn();
    if (isLoggedIn) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => HomeScreen(
            currentUserId: preferences.getString('id'),
          ),
        ),
      );
    } else {
      setState(() {
        isLoggedIn = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [Colors.lightBlueAccent, Colors.purpleAccent],
        )),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Telegram Clone",
              style: TextStyle(
                  fontSize: 82, color: Colors.white, fontFamily: "Signatra"),
            ),
            GestureDetector(
              onTap: controlSignIn,
              child: Center(
                child: Column(
                  children: [
                    Container(
                      width: 270,
                      height: 65,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                            image: AssetImage(
                                "assets/images/google_signin_button.png")),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(10),
                      child: isLoading ? circularProgress() : Container(),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<Null> controlSignIn() async {
    this.setState(() {
      isLoading = true;
    });
    GoogleSignInAccount googleUser = await googleSignIn.signIn();
    GoogleSignInAuthentication googleSignInAuthentication =
        await googleUser.authentication;

    final AuthCredential credential = GoogleAuthProvider.getCredential(
        idToken: googleSignInAuthentication.idToken,
        accessToken: googleSignInAuthentication.accessToken);

    FirebaseUser firebaseUser =
        (await firebaseAuth.signInWithCredential(credential)).user;

    // signIn success
    if (firebaseAuth != null) {
      // check if already signup
      final QuerySnapshot resultQuery = await Firestore.instance
          .collection('users')
          .where('id', isEqualTo: firebaseUser.uid)
          .getDocuments();
      final List<DocumentSnapshot> documentSnapshots = resultQuery.documents;
      // doesn't have this user in db
      // if doesn't have let save info of user to db
      if (documentSnapshots.length == 0) {
        Firestore.instance
            .collection('users')
            .document(firebaseUser.uid)
            .setData({
          'nickname': firebaseUser.displayName,
          'photoUrl': firebaseUser.photoUrl,
          'id': firebaseUser.uid,
          'aboutMe': 'i am an Mobile Developer',
          'createAt': DateTime.now().millisecondsSinceEpoch.toString(),
          'chattingWith': null,
        });
        //write data to local
        currentUser = firebaseUser;
        print("current user ${currentUser}");

        // why we write user info to local because we want to show this info in another screen
        // without request to user  again
        await preferences.setString('id', currentUser.uid);
        await preferences.setString('nickname', currentUser.displayName);
        await preferences.setString('photoUrl', currentUser.photoUrl);
      }
      //  the users is already signed we just update some info
      else {
        // update local info
        await preferences.setString('id', documentSnapshots[0]['id']);
        await preferences.setString(
            'nickname', documentSnapshots[0]['nickname']);
        await preferences.setString(
            'photoUrl', documentSnapshots[0]['photoUrl']);
        await preferences.setString('aboutMe', documentSnapshots[0]['aboutMe']);
      }
      Fluttertoast.showToast(msg: 'Congratulation, Sign in Successful');
      setState(() {
        isLoading = false;
      });
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => HomeScreen(currentUserId: firebaseUser.uid),
        ),
      );
    }
    // signIn failed
    else {
      Fluttertoast.showToast(msg: 'Try Again Signed Failed');
      setState(() {
        isLoading = false;
      });
    }
  }
}
