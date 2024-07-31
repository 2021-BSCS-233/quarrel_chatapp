import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:quarrel/services/firebase_services.dart';
import 'package:quarrel/widgets/status_icons.dart';
import 'package:quarrel/widgets/option_tile.dart';

class UserGroupPopup extends StatelessWidget {
  final List tileContent;

  const UserGroupPopup({super.key, required this.tileContent});

  @override
  Widget build(BuildContext context) {
    return Container(
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
                          : AssetImage('assets/images/default.png')
                              as ImageProvider,
                      radius: 25,
                      backgroundColor: Colors.transparent,
                    ),
                    title: Text(
                      '@${tileContent[1]}',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    onTap: () {},
                  ),
                ),
                OptionTile(
                    action: () {
                      print(
                          'Prolfie action on ${tileContent[0]}, chat type ${tileContent[3]}');
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
  final Map messageSelected;
  final String chatId;
  final Map currentUserData;

  const MessagePopup(
      {super.key,
      required this.messageSelected,
      required this.currentUserData,
      required this.chatId});

  @override
  Widget build(BuildContext context) {
    return Container(
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
                  SizedBox(
                    height: 10,
                  ),
                  OptionTile(
                      action: () {
                        print('Edit action on ${messageSelected['id']}');
                      },
                      action_icon: Icons.edit,
                      action_name: 'Edit Message'),
                  OptionTile(
                      action: () async {
                        await Clipboard.setData(
                            ClipboardData(text: messageSelected['message']));
                      },
                      action_icon: Icons.copy,
                      action_name: 'Copy Text'),
                  messageSelected['sender_id'] == currentUserData['id']
                      ? OptionTile(
                          action: () {
                            deleteMessage(chatId, messageSelected['id']);
                          },
                          action_icon: CupertinoIcons.delete,
                          action_name: 'Delete Message')
                      : const SizedBox(
                          height: 0,
                          width: 0,
                        ),
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
                              borderRadius: BorderRadius.only(
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
                                      : AssetImage('assets/images/default.png')
                                          as ImageProvider,
                              // radius: 10,
                              backgroundColor: Colors.grey.shade900,
                            ),
                          ),
                          Positioned(
                            bottom: 3,
                            right: 3,
                            child: StatusIcon(
                              icon_type: userProfileData['status'] == 'Online'
                                  ? userProfileData['display_status']
                                  : userProfileData['status'] ?? 'Offline',
                              icon_size: 24,
                              icon_border: 4,
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
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(
                        height: 3,
                      ),
                      Text(
                        userProfileData['username'] ??
                            'Failed to load user data',
                        style: TextStyle(fontSize: 14),
                      ),
                      SizedBox(
                        height: 3,
                      ),
                      Text(
                        userProfileData['pronounce'] ?? 'Try again later',
                        style: TextStyle(fontSize: 15, color: Colors.grey),
                      ),
                      SizedBox(
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
                        'About Me',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.grey),
                      ),
                      SizedBox(
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

  StatusPopup(
      {super.key, required this.currentUserData}) {
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
    return Container(
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
                    'Change Online Status',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Online Status',
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(
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
                              leading: StatusIcon(icon_type: 'Online'),
                              title: Text('Online'),
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
                              leading: StatusIcon(icon_type: 'DND'),
                              title: Text('Do Not Disturb'),
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
                              leading: StatusIcon(icon_type: 'Asleep'),
                              title: Text('Idel'),
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
                              leading: StatusIcon(icon_type: 'Offline'),
                              title: Text('Hidden'),
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
