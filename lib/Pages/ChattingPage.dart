import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:telegramchatapp/Widgets/FullImageWidget.dart';
import 'package:telegramchatapp/Widgets/ProgressWidget.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Chat extends StatelessWidget {
  final String receiverId;
  final String receiverName;
  final String receiverPhotoUrl;

  Chat({this.receiverId, this.receiverName, this.receiverPhotoUrl});
  @override
  Widget build(BuildContext context) {
    print('receiver id get from home chat $receiverId');
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightBlueAccent,
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          receiverName,
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: CircleAvatar(
              backgroundColor: Colors.black,
              backgroundImage: CachedNetworkImageProvider(receiverPhotoUrl),
            ),
          ),
        ],
      ),
      body:
          ChatScreen(receiverId: receiverId, receiverAvatar: receiverPhotoUrl),
    );
  }
}

class ChatScreen extends StatefulWidget {
  final String receiverId;
  final String receiverAvatar;
  ChatScreen({this.receiverId, this.receiverAvatar});

  @override
  State createState() =>
      ChatScreenState(receiverAvatar: receiverAvatar, receiverId: receiverId);
}

class ChatScreenState extends State<ChatScreen> {
  ChatScreenState({this.receiverId, this.receiverAvatar});
  final String receiverId;
  final String receiverAvatar;
  final TextEditingController textEditingController = TextEditingController();
  final FocusNode focusNode = FocusNode();
  File imageFile;
  String imageUlr;
  final ScrollController scrollController = ScrollController();

  bool isDisplaySticker;
  bool isLoading;
  SharedPreferences sharedPreferences;
  String chatId;
  String id;
  var listMessages;
  onFocusChange() {
    if (focusNode.hasFocus) {
      setState(() {
        isDisplaySticker = false;
      });
    }
  }

  @override
  void initState() {
    print('receiver id .. $receiverId');
    isDisplaySticker = false;
    isLoading = false;
    focusNode.addListener(onFocusChange);
    chatId = "";
    readLocal();
    super.initState();
  }

 bool isLastMessageRight(int index) {
    if (index > 0 &&
            listMessages != null &&
            listMessages[index - 1]['idFrom'] != id ||
        index == 0) {
      return true;
    } else {
      return false;
    }
  }

  bool isLastMessageLeft(int index) {
    if (index > 0 &&
        listMessages != null &&
        listMessages[index - 1]['idFrom'] == id ||
        index == 0) {
      return true;
    } else {
      return false;
    }
  }

  readLocal() async {
    sharedPreferences = await SharedPreferences.getInstance();
    id = sharedPreferences.getString('id') ?? '';
    if (id.hashCode <= receiverId.hashCode) {
      chatId = '$id-$receiverId';
    }
    Firestore.instance
        .collection('users')
        .document(id)
        .updateData({'chattingWith': receiverId});
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Stack(
        children: [
          Column(
            children: [
              // create list of messages
              createListMessages(),
              (isDisplaySticker ? createSticker() : Container()),
              createInput(),
            ],
          ),
          createLoading()
        ],
      ),
      onWillPop: onBackPress,
    );
  }

  createLoading() {
    return Positioned(child: isLoading ? circularProgress() : Container());
  }

  Future<bool> onBackPress() {
    if (isDisplaySticker) {
      setState(() {
        isDisplaySticker = false;
      });
    } else {
      Navigator.pop(context);
    }
    return Future.value(false);
  }

  createSticker() {
    return Container(
      child: ListView(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton(
                  onPressed: () => onSendMessage('mimi1', 2),
                  child: Image.asset(
                    'images/mimi1.gif',
                    width: 50,
                    height: 50,
                  )),
              TextButton(
                  onPressed: () => onSendMessage('mimi2', 2),
                  child: Image.asset(
                    'images/mimi2.gif',
                    width: 50,
                    height: 50,
                  )),
              TextButton(
                  onPressed: () => onSendMessage('mimi3', 2),
                  child: Image.asset(
                    'images/mimi3.gif',
                    width: 50,
                    height: 50,
                  )),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton(
                  onPressed: () => onSendMessage('mimi4', 2),
                  child: Image.asset(
                    'images/mimi4.gif',
                    width: 50,
                    height: 50,
                  )),
              TextButton(
                  onPressed: () => onSendMessage('mimi5', 2),
                  child: Image.asset(
                    'images/mimi5.gif',
                    width: 50,
                    height: 50,
                  )),
              TextButton(
                  onPressed: () => onSendMessage('mimi6', 2),
                  child: Image.asset(
                    'images/mimi6.gif',
                    width: 50,
                    height: 50,
                  )),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton(
                  onPressed: () => onSendMessage('mimi7', 2),
                  child: Image.asset(
                    'images/mimi7.gif',
                    width: 50,
                    height: 50,
                  )),
              TextButton(
                  onPressed: () => onSendMessage('mimi9', 2),
                  child: Image.asset(
                    'images/mimi9.gif',
                    width: 50,
                    height: 50,
                  )),
              TextButton(
                  onPressed: () => onSendMessage('mimi8', 2),
                  child: Image.asset(
                    'images/mimi8.gif',
                    width: 50,
                    height: 50,
                  )),
            ],
          ),
        ],
      ),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey, width: 0.5)),
        color: Colors.white,
      ),
      padding: EdgeInsets.all(0.5),
      height: 180,
    );
  }

  void onSendMessage(String contentMsg, int type) {
    //if type = it's text message
    // if type = 1 its imaegFile
    // if type = 2 its empji sticker

    print(
      "${
          {
            'idFrom': id,
            "idTo": receiverId,
            "timestamp": DateTime.now().millisecondsSinceEpoch.toString(),
            'content': contentMsg,
            'type': type
          }
      }"
    );
    if (contentMsg != '') {
      textEditingController.clear();
      var docRef = Firestore.instance
          .collection('messages')
          .document(chatId)
          .collection(chatId)
          .document(DateTime.now().millisecondsSinceEpoch.toString());
      Firestore.instance.runTransaction((transaction) async {
        await transaction.set(docRef, {
          'idFrom': id,
          "idTo": receiverId,
          "timestamp": DateTime.now().millisecondsSinceEpoch.toString(),
          'content': contentMsg,
          'type': type
        });
      });
      if(scrollController.hasClients){
        scrollController.animateTo(0.0,
            duration: Duration(microseconds: 300), curve: Curves.easeOut);
      }


    } else {
      Fluttertoast.showToast(msg: 'Empty Message. can not be send.');
    }
  }

  createInput() {
    return Container(
      child: Row(
        children: [
          // pick image icon button
          Material(
            child: Container(
              child: IconButton(
                icon: Icon(Icons.image),
                color: Colors.lightBlueAccent,
                onPressed: getImage,
              ),
            ),
            color: Colors.white,
          ),
          // emoji button
          Material(
            child: Container(
              child: IconButton(
                icon: Icon(Icons.face),
                color: Colors.lightBlueAccent,
                onPressed: () {
                  getSticker();
                },
              ),
            ),
            color: Colors.white,
          ),

          Flexible(
            child: Container(
              child: TextField(
                style: TextStyle(color: Colors.lightBlueAccent),
                controller: textEditingController,
                decoration: InputDecoration(
                  hintText: "Write here...",
                  hintStyle: TextStyle(color: Colors.grey),
                ),
                focusNode: focusNode,
              ),
            ),
          ),

          // send message icon button
          Material(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 8),
              child: IconButton(
                icon: Icon(Icons.send),
                color: Colors.lightBlueAccent,
                onPressed: () {
                  onSendMessage(textEditingController.text, 0);
                },
              ),
              color: Colors.white,
            ),
          )
        ],
      ),
      width: double.infinity,
      height: 50,
      decoration: BoxDecoration(
          border: Border(top: BorderSide(color: Colors.grey, width: 0.5)),
          color: Colors.white),
    );
  }

  createListMessages() {
    return Flexible(
      child: chatId == ''
          ? Center(
              child: CircularProgressIndicator(
                valueColor:
                    AlwaysStoppedAnimation<Color>(Colors.lightBlueAccent),
              ),
            )
          : StreamBuilder(
              stream: Firestore.instance
                  .collection('messages')
                  .document(chatId)
                  .collection(chatId)
                  .orderBy('timestamp', descending: true)
                  .limit(20)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                    child: CircularProgressIndicator(
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Colors.lightBlueAccent),
                    ),
                  );
                } else {
                  listMessages = snapshot.data.documents;
                  return ListView.builder(
                    itemCount: snapshot.data.documents.length,
                    controller: scrollController,
                    reverse: true,
                    padding: EdgeInsets.all(10),
                    itemBuilder: (context, index) {
                    return createItem(index, snapshot.data.documents[index]);
                    },
                  );
                }
              },
            ),
    );
  }

  createItem(int index, DocumentSnapshot documentSnapshot) {
    // my message right side
    if (documentSnapshot['idFrom'] == id) {
      return Row(
        children: [
          documentSnapshot['type'] == 0
              ? Container(
            padding: EdgeInsets.all(10),
                  width: 200,
                  margin: EdgeInsets.only(
                      bottom: isLastMessageRight(index) ? 20 : 10, right: 10),
                  decoration: BoxDecoration(
                    color: Colors.lightBlueAccent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(documentSnapshot['content']),
                ) // text
              : documentSnapshot['type'] == 1
                  ? Container(
                      child: FlatButton(
                        child: Material(
                          child: CachedNetworkImage(
                            placeholder: (context, url) => Container(
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.lightBlueAccent),
                              ),
                              height: 200,
                              width: 200,
                              padding: EdgeInsets.all(70),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.all(
                                  Radius.circular(8),
                                ),
                              ),
                            ),
                            errorWidget: (context, url, error) => Material(
                              child: Image.asset(
                                  'images/img_not_available.jpeg',
                                  width: 200,
                                  height: 200,
                                  fit: BoxFit.cover),
                              borderRadius: BorderRadius.all(
                                Radius.circular(8),
                              ),
                              clipBehavior: Clip.hardEdge,
                            ),
                            imageUrl: documentSnapshot['content'],
                            width: 200,
                            height: 200,
                            fit: BoxFit.cover,
                          ),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  FullPhoto(url: documentSnapshot['content']),
                            ),
                          );
                        },
                      ),
                    ) // image message
                  // sticker message
                  : Container(
                      child: Image.asset(
                        'images/${documentSnapshot['content']}.gif',
                        width: 100,
                        height: 100,
                      ),
                      margin: EdgeInsets.only(
                          bottom: isLastMessageRight(index) ? 20 : 10,
                          right: 10),
                    )
        ],
        mainAxisAlignment: MainAxisAlignment.end,
      );
    }
    // receiver message left side
    else {
      return Container(
        child: Column(children: [
          Row(
            children: [
              // display receiver iamge
              isLastMessageLeft(index) ? Material(
                child: CachedNetworkImage(
                  placeholder: (context, url) => Container(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.lightBlueAccent),
                    ),
                    height: 35,
                    width: 35,
                    padding: EdgeInsets.all(10),

                  ),

                  imageUrl: receiverAvatar,
                  width: 35,
                  height: 35,
                  fit: BoxFit.cover,

                ),
                borderRadius: BorderRadius.all(Radius.circular(18)),
                clipBehavior: Clip.hardEdge,
                // display message
              ) : Container(width: 35,)
            ],
          ),
          // mgs time
          isLastMessageLeft(index) ? Container(
            child: Text(
                DateFormat("dd MMMM, yyyy - hh:mm:aa")
                    .format(DateTime.fromMillisecondsSinceEpoch(int.parse(documentSnapshot['timestamp'] ?? '0',),),),

              style: TextStyle(color: Colors.grey,fontSize: 12),



            ),
            margin: EdgeInsets.only(left: 50,top:50),
          ) : Container()
        ],),
      );
    }
  }

  getSticker() {
    focusNode.unfocus();
    setState(() {
      isDisplaySticker = !isDisplaySticker;
    });
  }

  Future getImage() async {
    //  open gallery
    imageFile = await ImagePicker.pickImage(source: ImageSource.gallery);
    if (imageFile != null) {
      isLoading = true;
    }
    uploadImageFile();
  }

  uploadImageFile() async {
    // make image name unique
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    StorageReference storageReference =
        FirebaseStorage.instance.ref().child('Chat Images').child(fileName);
    StorageUploadTask storageUploadTask = storageReference.putFile(imageFile);
    StorageTaskSnapshot storageTaskSnapshot =
        await storageUploadTask.onComplete;
    storageTaskSnapshot.ref.getDownloadURL().then((downloadUrl) {
      imageUlr = downloadUrl;
      setState(() {
        isLoading = false;
        onSendMessage(imageUlr, 1);
      });
    }, onError: (error) {
      setState(() {
        Fluttertoast.showToast(msg: "Error $error");
      });
    });
  }
}
