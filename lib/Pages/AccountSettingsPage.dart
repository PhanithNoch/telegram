import 'dart:async';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:telegramchatapp/Widgets/ProgressWidget.dart';
import 'package:telegramchatapp/main.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class Settings extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Colors.lightBlueAccent,
        title: Text(
          "Account Settings",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SettingsScreen(),
    );
  }
}

class SettingsScreen extends StatefulWidget {
  @override
  State createState() => SettingsScreenState();
}

class SettingsScreenState extends State<SettingsScreen> {
  SharedPreferences preferences;
  TextEditingController nickNameTextEditingController = TextEditingController();
  TextEditingController aboutMeTextEditingController = TextEditingController();
  String id = "";
  String nickname = "";
  String aboutMe = "";
  String photoUrl = "";
  File imageFileAvatar;
  bool isLoading = false;
  final FocusNode nickNameFocusNode = FocusNode();
  final FocusNode aboutMeFocusNode = FocusNode();
  final GoogleSignIn googleSignIn = GoogleSignIn();
  @override
  void initState() {
    readDataFromLocal();
    super.initState();
  }

  void readDataFromLocal() async {
    preferences = await SharedPreferences.getInstance();
    id = preferences.getString('id');
    nickname = preferences.getString('nickname');
    aboutMe = preferences.getString('aboutMe');
    photoUrl = preferences.getString('photoUrl');
    print("photoUrl $photoUrl");

    nickNameTextEditingController = TextEditingController(text: nickname);
    aboutMeTextEditingController = TextEditingController(text: aboutMe);

    setState(() {});
  }

  Future getImage() async {
    File newImageFile =
        await ImagePicker.pickImage(source: ImageSource.gallery);
    if (newImageFile != null) {
      setState(() {
        this.imageFileAvatar = newImageFile;
        isLoading = true;
      });
    }
    uploadsImageToFirestoreAndStorage();
  }

  Future uploadsImageToFirestoreAndStorage() {
    String mFileName = id;
    StorageReference storageReference =
        FirebaseStorage.instance.ref().child(mFileName);
    StorageUploadTask storageUploadTask =
        storageReference.putFile(imageFileAvatar);
    StorageTaskSnapshot storageTaskSnapshot;
    storageUploadTask.onComplete.then((value) {
      if (value.error == null) {
        storageTaskSnapshot.ref.getDownloadURL().then((newImageDownloadUrl) {
          photoUrl = newImageDownloadUrl;
          Firestore.instance.collection("users").document(id).updateData({
            'photoUrl': photoUrl,
            'aboutMe': aboutMe,
            'nickName': nickname
          }).then((data) async {
            await preferences.setString('photoUrl', photoUrl);

            setState(() {
              isLoading = false;
            });
            Fluttertoast.showToast(msg: "Updated Successfully");
          });
        }, onError: (errorMsg) {
          setState(() {
            isLoading = false;
          });
          Fluttertoast.showToast(msg: "Error occured in getting Download Url");
        });
      }
    }, onError: (errorMsg) {
      setState(() {
        isLoading = false;
      });
      Fluttertoast.showToast(msg: errorMsg.toString());
    });
  }

  Future<Null> logOutUser() async {
    await FirebaseAuth.instance.signOut();
    await googleSignIn.disconnect();
    await googleSignIn.signOut();
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => MyApp(),
        ),
        (Route<dynamic> route) => false);
    setState(() {
      isLoading = false;
    });
  }

  void updateData() {
    nickNameFocusNode.unfocus();
    aboutMeFocusNode.unfocus();

    setState(() {
      isLoading = false;
    });

    Firestore.instance.collection("users").document(id).updateData({
      'photoUrl': photoUrl,
      'aboutMe': aboutMe,
      'nickName': nickname
    }).then((data) async {
      await preferences.setString('photoUrl', photoUrl);
      await preferences.setString('aboutMe', aboutMe);
      await preferences.setString('nickname', nickname);

      setState(() {
        isLoading = false;
      });

      Fluttertoast.showToast(msg: "Updated Successfully");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SingleChildScrollView(
            child: Column(
          children: [
            Container(
              child: Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // if imagefielAvatar is null == true
                    (imageFileAvatar == null)
                        // if photoUrl is not null
                        ? (photoUrl != null)
                            ? Material(
                                child: CachedNetworkImage(
                                  placeholder: (context, url) => Container(
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation(
                                          Colors.lightBlueAccent),
                                    ),
                                    padding: EdgeInsets.all(20),
                                    width: 200,
                                    height: 200,
                                  ),
                                  imageUrl: photoUrl,
                                  width: 200,
                                  height: 200,
                                  fit: BoxFit.cover,
                                ),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(125)),
                                clipBehavior: Clip.hardEdge,
                              )
                            : Icon(
                                Icons.account_circle,
                                size: 90,
                                color: Colors.grey,
                              )
                        :
                        // update image
                        Material(
                            child: Image.file(
                              imageFileAvatar,
                              width: 200,
                              height: 200,
                              fit: BoxFit.cover,
                            ),
                            borderRadius:
                                BorderRadius.all(Radius.circular(125)),
                            clipBehavior: Clip.hardEdge,
                          ),

                    IconButton(
                      onPressed: getImage,
                      icon: Icon(
                        Icons.camera_alt,
                        size: 100,
                        color: Colors.white54.withOpacity(0.3),
                      ),
                      padding: EdgeInsets.all(0),
                      splashColor: Colors.transparent,
                      highlightColor: Colors.grey,
                      iconSize: 200,
                    ),
                  ],
                ),
              ),
              width: double.infinity,
              margin: EdgeInsets.all(20),
              alignment: Alignment.center,
            ),
            // input fields

            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                      padding: EdgeInsets.all(1),
                      child: isLoading ? circularProgress() : Container()),
                  Container(
                    child: Text(
                      "Nick Name",
                      style: TextStyle(
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  Container(
                    child: Theme(
                      data: Theme.of(context)
                          .copyWith(primaryColor: Colors.lightBlueAccent),
                      child: TextFormField(
                        decoration: InputDecoration(
                            hintText: "Phanit Noch",
                            contentPadding: EdgeInsets.all(5.0),
                            hintStyle: TextStyle(color: Colors.grey)),
                        controller: nickNameTextEditingController,
                        onChanged: (value) {
                          nickname = value;
                        },
                        focusNode: nickNameFocusNode,
                      ),
                    ),
                  ),
                  // about me - user BIO
                  Container(
                    padding: EdgeInsets.only(top: 20),
                    child: Text(
                      "About me",
                      style: TextStyle(
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  Container(
                    child: Theme(
                      data: Theme.of(context)
                          .copyWith(primaryColor: Colors.lightBlueAccent),
                      child: TextFormField(
                        decoration: InputDecoration(
                            hintText: "Bio ...",
                            contentPadding: EdgeInsets.all(5.0),
                            hintStyle: TextStyle(color: Colors.grey)),
                        controller: aboutMeTextEditingController,
                        onChanged: (value) {
                          aboutMe = value;
                        },
                        focusNode: aboutMeFocusNode,
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        child: TextButton(
                          child: Text(
                            'Update',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                    ],
                  ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        child: TextButton(
                          child: Text(
                            'Sign Out',
                            style: TextStyle(fontSize: 16),
                          ),
                          onPressed: logOutUser,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        )),
      ],
    );
  }
}
