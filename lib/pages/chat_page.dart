import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:core';
import 'package:quarrel/widgets/message_tile.dart';
import 'package:quarrel/widgets/popup_menus.dart';
import 'package:quarrel/widgets/input_field.dart';
import 'package:quarrel/widgets/status_icons.dart';
import 'package:quarrel/services/firebase_services.dart';

var chatContent = [];
var messagesListenerRef;
var userMap = {};
var lastSender = '';
var initial = true;
var messageSelected = 0;
var showMenu = false.obs;
var update = 0.obs;
var showProfile = false.obs;
var fieldCheck = false.obs;
TextEditingController chatController = TextEditingController();

class Chat extends StatelessWidget {
  final String chatId;
  final Map currentUserData;
  final List otherUsersData;
  final String chatType;

  Chat(
      {super.key,
      required this.chatId,
      required this.otherUsersData,
      required this.currentUserData,
      required this.chatType}) {
    initial = true;
    userMap[currentUserData['id']] = currentUserData;
    for (var user in otherUsersData) {
      userMap[user['id']] = user;
    }
  }

  void toggleMenu(int index) {
    if (index != -1) {
      messageSelected = index;
    }
    showMenu.value = true;
  }

  void toggleProfile(int index) {
    if (index != -1) {
      messageSelected = index;
    }
    showProfile.value = !showProfile.value;
  }

  void changing() {
    fieldCheck.value = (chatController.text != '' ? true : false);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            title: Row(
              children: [
                Stack(
                  children: [
                    CircleAvatar(
                      backgroundImage:
                          otherUsersData[0]['profile_picture'] != ''
                              ? CachedNetworkImageProvider(
                                  otherUsersData[0]['profile_picture'])
                              : AssetImage('assets/images/default.png')
                                  as ImageProvider,
                      radius: 17,
                      backgroundColor: Colors.transparent,
                    ),
                    Positioned(
                      bottom: -2,
                      right: -2,
                      child: StatusIcon(
                        icon_type: otherUsersData[0]['status'] == 'Online'
                            ? otherUsersData[0]['display_status']
                            : otherUsersData[0]['status'],
                        icon_size: 16.0,
                        icon_border: 3,
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  width: 10,
                ),
                Text(
                  otherUsersData[0]['display_name'],
                  style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFEEEEEE)),
                )
              ],
            ),
          ),
          body: Container(
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                FutureBuilder<Widget>(
                  future: messagesUI(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return snapshot.data!;
                    } else if (snapshot.hasError) {
                      print(snapshot.error);
                      return Material(
                          color: Colors.transparent,
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text("We could not access our services"),
                                Text("Check your connection or try again later")
                              ],
                            ),
                          ));
                    }
                    return Center(child: CircularProgressIndicator());
                  },
                ),
                SizedBox(
                  height: 20,
                ),
                Row(
                  children: [
                    SizedBox(
                      width: 40,
                      child: TextButton(
                        onPressed: () {
                          print(fieldCheck.value);
                        },
                        child: Icon(
                          Icons.add,
                          size: 30,
                        ),
                        style: ButtonStyle(
                          padding: MaterialStateProperty.all<EdgeInsets>(
                            EdgeInsets.all(0),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: InputField(
                        fieldRadius: 20,
                        fieldLabel:
                            'Message @${otherUsersData[0]['display_name']}',
                        controller: chatController,
                        suffixIcon: Icons.all_inclusive,
                        fieldColor: Color(0xFF151515),
                        onChange: changing,
                        maxLines: 4,
                      ),
                    ),
                    Obx(() => Visibility(
                          visible: fieldCheck.value,
                          child: Container(
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.blueAccent.shade700),
                            width: 40,
                            height: 40,
                            child: TextButton(
                              child: Icon(
                                Icons.send,
                                size: 25,
                              ),
                              onPressed: () {
                                fieldCheck.value = false;
                                sendMessage(chatId, chatController.text,
                                    currentUserData['id']);
                                chatController.clear();
                              },
                              style: ButtonStyle(
                                padding: MaterialStateProperty.all<EdgeInsets>(
                                  EdgeInsets.all(0),
                                ),
                              ),
                            ),
                          ),
                        ))
                  ],
                )
              ],
            ),
          ),
        ),
        Obx(() => Visibility(
              visible: showMenu.value || showProfile.value,
              child: GestureDetector(
                onTap: () {
                  showMenu.value = false;
                  showProfile.value = false;
                },
                child: Container(
                  color: Color(0xCA1D1D1F),
                  height: MediaQuery.of(context).size.height,
                  width: double.infinity,
                ),
              ),
            )),
        Obx(() => AnimatedPositioned(
              duration: Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              bottom:
                  showMenu.value ? 0.0 : -MediaQuery.of(context).size.height,
              left: 0.0,
              right: 0.0,
              child: chatContent.length > 1
                  ? MessagePopup(
                      messageSelected: chatContent[messageSelected],
                      chatId: chatId,
                      currentUserData: currentUserData,
                    )
                  : Container(),
            )),
        Obx(() => AnimatedPositioned(
              duration: Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              bottom:
                  showProfile.value ? 0.0 : -MediaQuery.of(context).size.height,
              left: 0.0,
              right: 0.0,
              child: chatContent.isNotEmpty
                  ? ProfilePopup(
                      selectedUser: chatContent[messageSelected]['sender_id'])
                  : Container(),
            )),
      ],
    );
  }

  Future<Widget> messagesUI() async {
    initial ? await getMessages(chatId) : null;
    return Obx(
      () => update.value == update.value && chatContent.length < 1
          ? Center(child: Text('No Chats Found, Start Chatting'))
          : Expanded(
              child: ListView.builder(
                itemCount: chatContent.length,
                shrinkWrap: true,
                reverse: true,
                itemBuilder: (context, index) {
                  try {
                    if (chatContent[index]['sender_id'] !=
                        chatContent[index + 1]['sender_id']) {
                      return MessageTileFull(
                        messageData: chatContent[index],
                        sendingUser: userMap[chatContent[index]['sender_id']],
                        toggleMenu: () {
                          toggleMenu(index);
                        },
                        toggleProfile: () {
                          toggleProfile(index);
                        },
                      );
                    } else {
                      bool select = true;
                      try {
                        var time1 = chatContent[index]['time_stamp'].toDate();
                        var time2 =
                            chatContent[index + 1]['time_stamp'].toDate();
                        var difference = time1.difference(time2);
                        if (difference.inMinutes < 15) {
                          select = true;
                        } else {
                          select = false;
                        }
                      } catch (e) {
                        select = true;
                      }
                      if (select) {
                        return MessageTileCompact(
                            messageData: chatContent[index],
                            sendingUser:
                                userMap[chatContent[index]['sender_id']],
                            toggleMenu: () {
                              toggleMenu(index);
                            });
                      } else {
                        return MessageTileFull(
                          messageData: chatContent[index],
                          sendingUser: userMap[chatContent[index]['sender_id']],
                          toggleMenu: () {
                            toggleMenu(index);
                          },
                          toggleProfile: () {
                            toggleProfile(index);
                          },
                        );
                      }
                    }
                  } catch (e) {
                    return MessageTileFull(
                      messageData: chatContent[index],
                      sendingUser: userMap[chatContent[index]['sender_id']],
                      toggleMenu: () {
                        toggleMenu(index);
                      },
                      toggleProfile: () {
                        toggleProfile(index);
                      },
                    );
                  }
                },
              ),
            ),
    );
  }
}

getMessages(chatId) async {
  messagesListenerRef = await messagesListener(chatId);
  chatContent = await getInitialMessages(chatId);
  initial = false;
}

updateMessages(updateData, updateType) {
  var index = chatContent.indexWhere((map) => map['id'] == updateData['id']);
  if (updateType == 'added' && index < 0) {
    chatContent.insert(0, updateData);
  } else if (updateType == 'modified') {
    chatContent[index]['message'] = updateData['message'];
    chatContent[index]['edited'] = true;
  } else if (updateType == 'removed') {
    chatContent.removeAt(index);
  }
  update.value += 1;
}
