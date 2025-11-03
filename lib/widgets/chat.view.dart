import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_chat/firebase_chat.dart';
import 'package:flutter/material.dart';
import 'package:draw_page/draw_page.dart';
import 'package:fuodz/constants/app_colors.dart';
import 'package:fuodz/requests/chat.request.dart';
import 'package:image_picker/image_picker.dart';
import 'package:localize_and_translate/localize_and_translate.dart';

import '../services/app.service.dart';
final picker = ImagePicker();
File newPhoto;
class ChatBody extends BaseChat {
  ChatBody({
    @required ChatEntity entity,
  }) : super(entity);

  @override
  _ChatBodyState createState() => _ChatBodyState();
}

class _ChatBodyState extends BaseChatState<ChatBody> {
  @override
  Color get primaryColor => AppColor.primaryColor;

  @override
  Color get secondaryColor => AppColor.primaryColorDark;

  @override
  Widget get loadingWidget => Center(
    child: Padding(
      padding: const EdgeInsets.all(30.0),
      child: CircularProgressIndicator(),
    ),
  );

  @override
  Widget get emptyWidget => Center(
    child: Padding(
      padding: const EdgeInsets.all(40.0),
      child: Text(
        "Welcome".tr(),
      ),
    ),
  );

  @override
  Widget errorWidget(string) {
    return Center(
      child: Text(
        "Something wrong".tr(),
      ),
    );
  }

  @override
  Widget inputBuilder(BuildContext context, ChatInputState state) {
    return SafeArea(
      bottom: true,
      top: false,
      child: Container(
        color: Colors.white,
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            Expanded(
              child: Container(
                padding: EdgeInsets.all(10),
                child: TextField(
                  onSubmitted: (text) {
                    if (text.isNotEmpty) sendChatMessage(text);
                  },
                  autofocus: false,
                  maxLines: null,
                  keyboardType: TextInputType.text,
                  style: TextStyle(fontSize: 20.0, color: Colors.black),
                  controller: textEditingController,
                  onChanged: inputChanged,
                  decoration: InputDecoration.collapsed(
                    hintText: "Type here".tr(),
                    hintStyle: TextStyle(color: Colors.grey),
                  ),
                ),
              ),
            ),
            if (state is InputEmptyState) //doesnt support web yet
              Material(
                child: new Container(
                  child: new IconButton(
                    icon: new Icon(Icons.add_a_photo),
                    onPressed: () => getImage(),
                    color: primaryColor,
                    disabledColor: Colors.grey,
                  ),
                ),
                color: Colors.white,
              ),


            // Send message button
            Material(
              child: new Container(
                margin: new EdgeInsets.only(right: 4.0),
                child: new IconButton(
                  icon: new Icon(Icons.send),
                  onPressed: state is ReadyToSendState
                      ? () => sendChatMessage(textEditingController.text)
                      : null,
                  color: primaryColor,
                  disabledColor: Colors.grey,
                ),
              ),
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Future editAndUpload(Uint8List data) async {
    Uint8List edited = await Navigator.of(context).push<Uint8List>(MaterialPageRoute(builder: (BuildContext context) {
      return DrawPage(imageData: data, loadingWidget: loadingWidget);
    }));
    sendImage(edited);
  }

  @override
  Future getImage() async{
    File images;


    images = await  imagepaker();
    if (images != null && images.length == 1) {

      // }
    }

    if (images != null) {

      await sendImage(images);
    }
  }

  //


  //




//    final ImagePicker _picker = ImagePicker();
//                      final List< XFile> photo =  await _picker.pickImage(
//                                                   source: ImageSource.gallery);

//                      if (photo == null) {
//                             return;
//                          }
//                          else{

//                            final bytes = await photo.readAsBytes();
//  return bytes;
//                          }


  Future<File> imagepaker() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      newPhoto = File(pickedFile.path);
      //

      return newPhoto;
    } else {
      newPhoto = null;
      return newPhoto;
    }}
  ChatRequest chatRequest = ChatRequest();
  sendChatMessage(String message) async {
    super.sendMessage();
    //notify the involved party
    final chatEntity = widget.entity;
    final otherPeerKey = chatEntity.peers.keys.firstWhere(
          (peerKey) => chatEntity.mainUser.documentId != peerKey,
    );
    final otherPeer = chatEntity.peers[otherPeerKey];

    final apiResponse = await chatRequest.sendNotification(
      title: "New Message from".tr() + " ${chatEntity.mainUser.name}",
      body: message,
      topic: otherPeer.documentId,
      path: chatEntity.path,
      user: chatEntity.mainUser,
      otherUser: otherPeer,
    );

    print("Result ==> ${apiResponse.body}");
  }
}
