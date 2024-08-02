import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:core';
import 'package:quarrel/widgets/message_tile.dart';
import 'package:quarrel/widgets/popup_menus.dart';
import 'package:quarrel/widgets/input_field.dart';
import 'package:quarrel/widgets/status_icons.dart';
import 'package:quarrel/services/page_controllers.dart';
import 'package:quarrel/services/firebase_services.dart';

class Chat extends StatelessWidget {
  final MainController mainController = Get.find<MainController>();
  late final ChatController chatController;
  final String chatId;
  final List otherUsersData;
  final String chatType;

  Chat(
      {super.key,
      required this.chatId,
      required this.otherUsersData,
      required this.chatType}) {
    chatController = Get.put(ChatController(chatId: chatId));
    chatController.initial = true;
    chatController.userMap[mainController.currentUserData['id']] =
        mainController.currentUserData;
    for (var user in otherUsersData) {
      chatController.userMap[user['id']] = user;
    }
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
                              : const AssetImage('assets/images/default.png')
                                  as ImageProvider,
                      radius: 17,
                      backgroundColor: Colors.transparent,
                    ),
                    Positioned(
                      bottom: -2,
                      right: -2,
                      child: StatusIcon(
                        iconType: otherUsersData[0]['status'] == 'Online'
                            ? otherUsersData[0]['display_status']
                            : otherUsersData[0]['status'],
                        iconSize: 16.0,
                        iconBorder: 3,
                      ),
                    ),
                  ],
                ),
                const SizedBox(
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
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 0),
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
                      return const Material(
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
                    return const Center(child: CircularProgressIndicator());
                  },
                ),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  children: [
                    SizedBox(
                      width: 40,
                      child: TextButton(
                        onPressed: () {
                          print(chatController.fieldCheck.value);
                        },
                        style: ButtonStyle(
                          padding: MaterialStateProperty.all<EdgeInsets>(
                            const EdgeInsets.all(0),
                          ),
                        ),
                        child: const Icon(
                          Icons.add,
                          size: 30,
                        ),
                      ),
                    ),
                    Expanded(
                      child: InputField(
                        fieldFocusNode: chatController.chatFocusNode,
                        fieldRadius: 20,
                        fieldLabel: 'messageTo'.trParams(
                            {'name': otherUsersData[0]['display_name']}),
                        controller: chatController.chatFieldController,
                        suffixIcon: Icons.all_inclusive,
                        fieldColor: Color(0xFF151515),
                        onChange: chatController.changing,
                        maxLines: 4,
                      ),
                    ),
                    Obx(() => Visibility(
                          visible: chatController.fieldCheck.value,
                          child: Container(
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.blueAccent.shade700),
                            width: 40,
                            height: 40,
                            child: TextButton(
                              onPressed: () {
                                chatController.fieldCheck.value = false;
                                chatController.editMode
                                    ? editMessage(
                                        chatId,
                                        chatController.chatContent[
                                                chatController.messageSelected]
                                            ['id'],
                                        chatController.chatFieldController.text)
                                    : sendMessage(
                                        chatId,
                                        chatController.chatFieldController.text,
                                        mainController.currentUserData['id']);
                                chatController.editMode
                                    ? chatController.chatFocusNode.unfocus()
                                    : null;
                                chatController.editMode = false;
                                chatController.chatFieldController.clear();
                              },
                              style: ButtonStyle(
                                padding: MaterialStateProperty.all<EdgeInsets>(
                                  const EdgeInsets.all(0),
                                ),
                              ),
                              child: const Icon(
                                Icons.send,
                                size: 25,
                              ),
                            ),
                          ),
                        )),
                    const SizedBox(
                      width: 10,
                    )
                  ],
                )
              ],
            ),
          ),
        ),
        Obx(() => Visibility(
              visible: chatController.showMenu.value ||
                  chatController.showProfile.value,
              child: GestureDetector(
                onTap: () {
                  chatController.showMenu.value = false;
                  chatController.showProfile.value = false;
                },
                child: Container(
                  color: Color(0xCA1D1D1F),
                  height: MediaQuery.of(context).size.height,
                  width: double.infinity,
                ),
              ),
            )),
        Obx(() => AnimatedPositioned(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              bottom: chatController.showMenu.value
                  ? 0.0
                  : -MediaQuery.of(context).size.height,
              left: 0.0,
              right: 0.0,
              child: chatController.chatContent.length > 1
                  ? MessagePopup(
                      chatId: chatId,
                    )
                  : Container(),
            )),
        Obx(() => AnimatedPositioned(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              bottom: chatController.showProfile.value
                  ? 0.0
                  : -MediaQuery.of(context).size.height,
              left: 0.0,
              right: 0.0,
              child: chatController.chatContent.isNotEmpty
                  ? ProfilePopup(
                      selectedUser: chatController
                              .chatContent[chatController.messageSelected]
                          ['sender_id'])
                  : Container(),
            )),
      ],
    );
  }

  Future<Widget> messagesUI() async {
    chatController.initial ? await chatController.getMessages(chatId) : null;
    return Obx(
      () => chatController.updateC.value == chatController.updateC.value &&
              chatController.chatContent.isEmpty
          ? Center(child: Text('chatEmpty'.tr))
          : Expanded(
              child: ListView.builder(
                itemCount: chatController.chatContent.length,
                shrinkWrap: true,
                reverse: true,
                itemBuilder: (context, index) {
                  try {
                    if (chatController.chatContent[index]['sender_id'] !=
                        chatController.chatContent[index + 1]['sender_id']) {
                      return MessageTileFull(
                        messageData: chatController.chatContent[index],
                        sendingUser: chatController.userMap[
                            chatController.chatContent[index]['sender_id']],
                        toggleMenu: () {
                          chatController.toggleMenu(index);
                        },
                        toggleProfile: () {
                          chatController.toggleProfile(index);
                        },
                      );
                    } else {
                      bool select = true;
                      try {
                        var time1 = chatController.chatContent[index]
                                ['time_stamp']
                            .toDate();
                        var time2 = chatController.chatContent[index + 1]
                                ['time_stamp']
                            .toDate();
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
                            messageData: chatController.chatContent[index],
                            sendingUser: chatController.userMap[
                                chatController.chatContent[index]['sender_id']],
                            toggleMenu: () {
                              chatController.toggleMenu(index);
                            });
                      } else {
                        return MessageTileFull(
                          messageData: chatController.chatContent[index],
                          sendingUser: chatController.userMap[
                              chatController.chatContent[index]['sender_id']],
                          toggleMenu: () {
                            chatController.toggleMenu(index);
                          },
                          toggleProfile: () {
                            chatController.toggleProfile(index);
                          },
                        );
                      }
                    }
                  } catch (e) {
                    return MessageTileFull(
                      messageData: chatController.chatContent[index],
                      sendingUser: chatController.userMap[
                          chatController.chatContent[index]['sender_id']],
                      toggleMenu: () {
                        chatController.toggleMenu(index);
                      },
                      toggleProfile: () {
                        chatController.toggleProfile(index);
                      },
                    );
                  }
                },
              ),
            ),
    );
  }
}
