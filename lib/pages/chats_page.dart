import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quarrel/pages/requests_page.dart';
import 'package:quarrel/widgets/dm_chat_tile.dart';
import 'package:quarrel/widgets/status_icons.dart';
import 'package:quarrel/services/firebase_services.dart';

var update = 0.obs;
bool initial = true;
var chatsListenerRef;
var friendsListenerRef;
List chatsData = [];
List friendsData = [];
var currentUserDataGlobalChats;

class Chats extends StatelessWidget {
  final Map currentUserData;
  final Function toggleMenu;
  final Function toggleProfile;

  Chats(
      {super.key,
      required this.toggleMenu,
      required this.currentUserData,
      required this.toggleProfile}) {
    currentUserDataGlobalChats = currentUserData;
    initial = true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Messages',
          style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xD0FFFFFF),
              fontSize: 22),
        ),
        actions: [
          InkWell(
            enableFeedback: true,
            onTap: () {
              Get.to(Requests(
                currentUserData: currentUserData,
              ));
            },
            child: SizedBox(
              height: 40,
              width: 120,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.person_add),
                  SizedBox(
                    width: 10,
                  ),
                  Text('Add Friend'),
                ],
              ),
            ),
          ),
          SizedBox(
            width: 25,
          )
        ],
      ),
      body: FutureBuilder<Widget>(
        future: chatsUI(),
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
                      Text("Check your connection or try again later"),
                    ],
                  ),
                ));
          }
          return Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Future<Widget> chatsUI() async {
    initial ? await getInitialData(currentUserData['id']) : null;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        children: [
          Obx(
            () => SizedBox(
                width: double.infinity,
                height: friendsData.isEmpty ? 0 : 90,
                child: update.value == update.value && friendsData.isEmpty
                    ? const SizedBox()
                    : ListView.builder(
                        itemCount: friendsData.length,
                        shrinkWrap: true,
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (context, index) {
                          return Container(
                            margin: EdgeInsets.all(5),
                            height: 80,
                            width: 80,
                            decoration: BoxDecoration(
                                color: Color(0xAA18181F),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(15))),
                            child: Center(
                              child: InkWell(
                                onTap: () {
                                  toggleProfile(friendsData[index]['id']);
                                },
                                child: Stack(
                                  children: [
                                    Container(
                                      height: 50,
                                      width: 50,
                                      child: CircleAvatar(
                                        backgroundImage: friendsData[index]
                                                    ['profile_picture'] !=
                                                ''
                                            ? CachedNetworkImageProvider(
                                                friendsData[index]
                                                    ['profile_picture'])
                                            : const AssetImage(
                                                    'assets/images/default.png')
                                                as ImageProvider,
                                        backgroundColor: Colors.grey.shade900,
                                      ),
                                    ),
                                    Positioned(
                                      bottom: -2,
                                      right: -2,
                                      child: StatusIcon(
                                        icon_type: friendsData[index]
                                                    ['status'] ==
                                                'Online'
                                            ? friendsData[index]
                                                ['display_status']
                                            : friendsData[index]['status'],
                                        icon_size: 17,
                                        icon_border: 3.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        })),
          ),
          Obx(
            () => Expanded(
                child: update.value == update.value && chatsData.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('You Do Not Have Any Friends'),
                            Text('Add Friends to Chat With'),
                            SizedBox(
                              height: 90,
                            )
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: chatsData.length,
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          return chatsData[index]['chat_type'] == 'dm'
                              ? DmChatTile(
                                  currentUserData: currentUserData,
                                  chatData: chatsData[index],
                                  logPressMenu: toggleMenu)
                              : Container(
                                  height: 50,
                                  width: 100,
                                  child: Center(
                                    child: Text(
                                        'add support for ${chatsData[index]['chat_type']}'),
                                  ),
                                );
                        },
                      )),
          ),
        ],
      ),
    );
  }
}

getInitialData(currentUserId) async {
  chatsListenerRef = await chatsListener(currentUserId);
  friendsListenerRef = await friendsListener(currentUserId);
  var response = await getInitialChats(currentUserId);
  chatsData = response;
  response = await getInitialFriends(currentUserId);
  friendsData = response;
  initial = false;
}

updateChats(updateData, updateType) {
  var index = chatsData.indexWhere((map) => map['id'] == updateData['id']);
  if (updateType == 'modified') {
    chatsData[index]['latest_message'] = updateData['latest_message'];
    chatsData[index]['time_stamp'] = updateData['time_stamp'];
  } else if (updateType == 'added' && index < 0) {
    chatsData.insert(0, updateData);
  }
  update.value += 1;
}

updateFriendTiles(updateData, updateType) {
  var index = friendsData.indexWhere((map) => map['id'] == updateData['id']);
  if (updateType == 'modified') {
    friendsData[index] = updateData;
  } else if (updateType == 'added' && index < 0) {
    friendsData.insert(0, updateData);
  } else if (updateType == 'removed') {
    friendsData.removeAt(index);
  }
  update.value += 1;
}
