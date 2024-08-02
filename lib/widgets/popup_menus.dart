import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:quarrel/services/page_controllers.dart';
import 'package:quarrel/services/firebase_services.dart';
import 'package:quarrel/widgets/status_icons.dart';
import 'package:quarrel/widgets/option_tile.dart';

class UserGroupPopup extends StatelessWidget {
  final List tileContent;

  const UserGroupPopup({super.key, required this.tileContent});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.56,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Container(
          height: double.infinity,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundImage: tileContent[2] != ''
                          ? CachedNetworkImageProvider(tileContent[2])
                          : const AssetImage('assets/images/default.png')
                              as ImageProvider,
                      radius: 25,
                      backgroundColor: Colors.transparent,
                    ),
                    title: Text(
                      '@${tileContent[1]}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    onTap: () {},
                  ),
                ),
                OptionTile(
                    action: () {
                      print(
                          'Profile action on ${tileContent[0]}, chat type ${tileContent[3]}');
                    },
                    action_icon: Icons.person,
                    action_name: 'Profile'),
                OptionTile(
                    action: () {
                      print(
                          'Close Action on ${tileContent[0]}, chat type ${tileContent[3]}');
                    },
                    action_icon: Icons.remove_circle_outline,
                    action_name: 'Close DM'),
                OptionTile(
                    action: () {
                      print(
                          'MAR action on ${tileContent[0]}, chat type ${tileContent[3]}');
                    },
                    action_icon: CupertinoIcons.eye,
                    action_name: 'Mark As Read'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class MessagePopup extends StatelessWidget {
  final String chatId;
  final MainController mainController = Get.find<MainController>();
  final ChatController chatController = Get.find<ChatController>();

  MessagePopup({super.key, required this.chatId});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.56,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Container(
          height: double.infinity,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(
                    height: 10,
                  ),
                  chatController.chatContent[chatController.messageSelected]
                              ['sender_id'] ==
                          mainController.currentUserData['id']
                      ? OptionTile(
                          action: () {
                            chatController.editChatMessage();
                          },
                          action_icon: Icons.edit,
                          action_name: 'Edit Message')
                      : const SizedBox(),
                  OptionTile(
                      action: () async {
                        await Clipboard.setData(ClipboardData(
                            text: chatController
                                    .chatContent[chatController.messageSelected]
                                ['message']));
                      },
                      action_icon: Icons.copy,
                      action_name: 'Copy Text'),
                  chatController.chatContent[chatController.messageSelected]
                              ['sender_id'] ==
                          mainController.currentUserData['id']
                      ? OptionTile(
                          action: () {
                            chatController.deleteChatMessage();
                          },
                          action_icon: CupertinoIcons.delete,
                          action_name: 'Delete Message')
                      : const SizedBox(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

var userProfileData = {};

class ProfilePopup extends StatelessWidget {
  final String selectedUser;

  const ProfilePopup({super.key, required this.selectedUser});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Widget>(
      future: _buildContent(context),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return snapshot.data!;
        } else if (snapshot.hasError) {
          return Text("${snapshot.error}");
        }
        return Container();
        // height: MediaQuery.of(context).size.height * 0.65,
        // child: CircularProgressIndicator());
      },
    );
  }

  Future<Widget> _buildContent(BuildContext context) async {
    userProfileData = (await getUserProfile(selectedUser)).data();
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.65,
      width: double.infinity,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SingleChildScrollView(
          child: Container(
            height: MediaQuery.of(context).size.height,
            decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.all(Radius.circular(25))),
            child: Column(
              children: [
                Stack(
                  children: [
                    Column(
                      children: [
                        Container(
                          width: double.infinity,
                          height: 100,
                          decoration: BoxDecoration(
                              color: Colors.yellow.shade700,
                              //make it adapt to the major color of profile
                              borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(25),
                                  topRight: Radius.circular(25))),
                        ),
                        Container(
                          width: double.infinity,
                          height: 50,
                          color: Colors.transparent,
                        )
                      ],
                    ),
                    Positioned(
                      bottom: 10,
                      left: 20,
                      child: Stack(
                        children: [
                          Container(
                            height: 80,
                            width: 80,
                            decoration: BoxDecoration(
                                color: Colors.transparent,
                                shape: BoxShape.circle,
                                border:
                                    Border.all(width: 6, color: Colors.black)),
                            child: CircleAvatar(
                              backgroundImage:
                                  userProfileData['profile_picture'] != ''
                                      ? CachedNetworkImageProvider(
                                          userProfileData['profile_picture'])
                                      : const AssetImage(
                                              'assets/images/default.png')
                                          as ImageProvider,
                              // radius: 10,
                              backgroundColor: Colors.grey.shade900,
                            ),
                          ),
                          Positioned(
                            bottom: 3,
                            right: 3,
                            child: StatusIcon(
                              iconType: userProfileData['status'] == 'Online'
                                  ? userProfileData['display_status']
                                  : userProfileData['status'] ?? 'Offline',
                              iconSize: 24,
                              iconBorder: 4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Container(
                  margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                  padding: EdgeInsets.symmetric(horizontal: 14, vertical: 18),
                  alignment: Alignment.centerLeft,
                  width: double.infinity,
                  height: 130,
                  decoration: BoxDecoration(
                      color: Color(0xFF121218),
                      borderRadius: BorderRadius.all(Radius.circular(15))),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userProfileData['display_name'] ?? 'User Error',
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(
                        height: 3,
                      ),
                      Text(
                        userProfileData['username'] ??
                            'Failed to load user data',
                        style: TextStyle(fontSize: 14),
                      ),
                      const SizedBox(
                        height: 3,
                      ),
                      Text(
                        userProfileData['pronouns'] ?? 'Try again later',
                        style: TextStyle(fontSize: 15, color: Colors.grey),
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                  padding: EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  alignment: Alignment.centerLeft,
                  width: double.infinity,
                  height: 200,
                  decoration: BoxDecoration(
                      color: Color(0xFF121218),
                      borderRadius: BorderRadius.all(Radius.circular(15))),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'aboutMe'.tr,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.grey),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Text(
                        userProfileData['about_me'] ?? '',
                        style: TextStyle(
                            fontSize: 15, color: Colors.grey.shade300),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

var selectedValue = 1.obs;

class StatusPopup extends StatelessWidget {
  final Map currentUserData;

  StatusPopup({super.key, required this.currentUserData}) {
    if (currentUserData['display_status'] == 'DND') {
      selectedValue.value = 2;
    } else if (currentUserData['display_status'] == 'Asleep') {
      selectedValue.value = 3;
    } else if (currentUserData['display_status'] == 'Offline') {
      selectedValue.value = 4;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.5,
      width: double.infinity,
      child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Center(
            child: Container(
              padding: EdgeInsets.all(20),
              height: double.infinity,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
              ),
              child: Column(
                children: [
                  Text(
                    'changeStatus'.tr,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'onlineStatus'.tr,
                      style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(
                      vertical: 10,
                    ),
                    // height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                        color: Color(0xFF121218),
                        borderRadius: BorderRadius.all(Radius.circular(15))),
                    child: Obx(() => Column(
                          children: [
                            ListTile(
                              leading: StatusIcon(iconType: 'Online'),
                              title: Text('online'.tr),
                              trailing: Radio(
                                  value: 1,
                                  groupValue: selectedValue.value,
                                  onChanged: (value) async {
                                    var temp = selectedValue.value;
                                    selectedValue.value = value as int;
                                    var result = await updateStatusDisplay(
                                        currentUserData['id'], 'Online');
                                    if (!result) {
                                      selectedValue.value = temp;
                                    }
                                  }),
                            ),
                            ListTile(
                              leading: StatusIcon(iconType: 'DND'),
                              title: Text('dnd'.tr),
                              trailing: Radio(
                                  value: 2,
                                  groupValue: selectedValue.value,
                                  onChanged: (value) async {
                                    var temp = selectedValue.value;
                                    selectedValue.value = value as int;
                                    var result = await updateStatusDisplay(
                                        currentUserData['id'], 'DND');
                                    if (!result) {
                                      selectedValue.value = temp;
                                    }
                                  }),
                            ),
                            ListTile(
                              leading: StatusIcon(iconType: 'Asleep'),
                              title: Text('idle'.tr),
                              trailing: Radio(
                                  value: 3,
                                  groupValue: selectedValue.value,
                                  onChanged: (value) async {
                                    var temp = selectedValue.value;
                                    selectedValue.value = value as int;
                                    var result = await updateStatusDisplay(
                                        currentUserData['id'], 'Asleep');
                                    if (!result) {
                                      selectedValue.value = temp;
                                    }
                                  }),
                            ),
                            ListTile(
                              leading: StatusIcon(iconType: 'Offline'),
                              title: Text('hidden'.tr),
                              trailing: Radio(
                                  value: 4,
                                  groupValue: selectedValue.value,
                                  onChanged: (value) async {
                                    var temp = selectedValue.value;
                                    selectedValue.value = value as int;
                                    var result = await updateStatusDisplay(
                                        currentUserData['id'], 'Offline');
                                    if (!result) {
                                      selectedValue.value = temp;
                                    }
                                  }),
                            )
                          ],
                        )),
                  )
                ],
              ),
            ),
          )),
    );
  }
}
