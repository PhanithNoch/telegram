import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:telegramchatapp/Pages/ChattingPage.dart';
import 'package:telegramchatapp/main.dart';
import 'package:telegramchatapp/models/user.dart';
import 'package:telegramchatapp/Pages/AccountSettingsPage.dart';
import 'package:telegramchatapp/Widgets/ProgressWidget.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_sign_in/google_sign_in.dart';

class HomeScreen extends StatefulWidget {
  final String currentUserId;
  HomeScreen({@required this.currentUserId});

  @override
  State createState() => HomeScreenState(currentUserId);
}

class HomeScreenState extends State<HomeScreen> {
  final TextEditingController searchTextEditingController =
      TextEditingController();
  final String currentUserId;
  HomeScreenState(this.currentUserId);
  Future<QuerySnapshot> futureSearchingResult;
  Widget homePageHeader() {
    return AppBar(
      automaticallyImplyLeading: false,
      actions: [
        IconButton(
          onPressed: () {
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => Settings()));
          },
          icon: Icon(Icons.settings),
        ),
      ],
      title: Container(
        child: TextFormField(
          controller: searchTextEditingController,
          style: TextStyle(fontSize: 18, color: Colors.white),
          decoration: InputDecoration(
            hintText: "Search ....",
            hintStyle: TextStyle(color: Colors.white),
            enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.grey)),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
            ),
            filled: true,
            prefixIcon: Icon(
              Icons.person_pin,
              color: Colors.white,
              size: 30,
            ),
            suffixIcon: IconButton(
              icon: Icon(Icons.clear),
              color: Colors.white,
              onPressed: emptyTextFormField,
            ),
          ),
          onFieldSubmitted: controlSearchingUser,
        ),
      ),
    );
  }

  //
  emptyTextFormField() {
    searchTextEditingController.clear();
  }

  controlSearchingUser(String userName) {
    print("username$userName");
    Future<QuerySnapshot> allFoundUsers = Firestore.instance
        .collection('users')
        .where('nickname', isGreaterThanOrEqualTo: userName)
        .getDocuments();

    setState(() {
      futureSearchingResult = allFoundUsers;
    });
  }

  @override
  Widget build(BuildContext context) {
    // return TextButton.icon(
    //   onPressed: logOutUser,
    //   icon: Icon(Icons.close),
    //   label: Text("Sign Out"),
    // );

    return Scaffold(
      appBar: homePageHeader(),
      body: futureSearchingResult == null
          ? displayNoSearchResultScreen()
          : displayUserFoundScreen(),
    );
  }

  displayNoSearchResultScreen() {
    final Orientation orientation = MediaQuery.of(context).orientation;
    return Container(
      child: Center(
        child: ListView(
          shrinkWrap: true,
          children: [
            Center(
              child: Column(
                children: [
                  Icon(
                    Icons.group,
                    color: Colors.lightBlueAccent,
                    size: 200,
                  ),
                  Text(
                    "Search Users",
                    style:
                        TextStyle(color: Colors.lightBlueAccent, fontSize: 20),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  displayUserFoundScreen() {
    return FutureBuilder(
      future: futureSearchingResult,
      builder: (context, AsyncSnapshot<QuerySnapshot> dataSnapshot) {
        if (!dataSnapshot.hasData) {
          return circularProgress();
        }
        List<UserResult> searchUserResult = [];
        dataSnapshot.data.documents.forEach((document) {
          User eachUser = User.fromDocument(document);
          // print(eachUser.nickname);
          UserResult userResult = UserResult(eachUser);
          if (currentUserId != document['id']) {
            searchUserResult.add(userResult);
          }
        });
        return ListView(
          children: searchUserResult,
        );
      },
    );
  }
}

class UserResult extends StatelessWidget {
  final User eachUser;
  UserResult(this.eachUser);
  @override
  Widget build(BuildContext context) {
    print(eachUser.nickname);
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          GestureDetector(
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.black,
                backgroundImage: CachedNetworkImageProvider(eachUser.photoUrl),
              ),
              title: Text(eachUser.nickname),
              subtitle: Text("Joined" +
                  DateFormat("dd MMMM, yyyy - hh:mm:aa").format(
                      DateTime.fromMillisecondsSinceEpoch(
                          (int.parse(eachUser.createdAt ?? "0"))))),
            ),
            onTap: () {
              sendUserToChatPage(context);
            },
          ),
        ],
      ),
    );
  }

  void sendUserToChatPage(BuildContext context) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => Chat(
                  receiverId: eachUser.id,
                  receiverName: eachUser.nickname,
                  receiverPhotoUrl: eachUser.photoUrl,
                )));
  }
}
