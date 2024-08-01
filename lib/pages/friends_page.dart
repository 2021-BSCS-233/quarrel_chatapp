import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quarrel/pages/chat_page.dart';
import 'package:quarrel/pages/requests_page.dart';
import 'package:quarrel/services/controllers.dart';
import 'package:quarrel/services/firebase_services.dart';

class Friends extends StatelessWidget {
  final MainController mainController = Get.find<MainController>();
  final FriendsController friendsController = Get.find<FriendsController>();

  Friends({super.key}) {
    friendsController.initial = true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Friends',
          style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xD0FFFFFF),
              fontSize: 22),
        ),
        actions: [
          InkWell(
            onTap: () {
              Get.to(Requests());
            },
            child: Container(
              height: 40,
              width: 120,
              decoration: BoxDecoration(
                  color: Colors.blueAccent.shade700,
                  borderRadius: BorderRadius.all(Radius.circular(25))),
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
            width: 10,
          )
        ],
      ),
      body: FutureBuilder<Widget>(
        future: friendsUI(),
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
    );
  }

  Future<Widget> friendsUI() async {
    friendsController.initial
        ? await friendsController
            .getInitialData(mainController.currentUserData['id'])
        : null;

    return Obx(() => friendsController.updateF.value ==
                friendsController.updateF.value &&
            friendsController.friendsData.isEmpty
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('You do not have any friends'),
                Text('Start adding some friends to chat with')
              ],
            ),
          )
        : Container(
            padding: EdgeInsets.only(left: 10),
            child: ListView.builder(
                itemCount: friendsController.friendsData.length,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  return Container(
                    margin: const EdgeInsets.only(top: 15),
                    decoration: BoxDecoration(
                      color: Color(0xFF121218),
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                    ),
                    child: ListTile(
                      leading: InkWell(
                        onTap: () {
                          mainController.toggleProfile(
                              friendsController.friendsData[index]['id']);
                        },
                        child: CircleAvatar(
                          backgroundImage: friendsController.friendsData[index]
                                      ['profile_picture'] !=
                                  ''
                              ? CachedNetworkImageProvider(friendsController
                                  .friendsData[index]['profile_picture'])
                              : const AssetImage('assets/images/default.png')
                                  as ImageProvider,
                          radius: 20,
                          backgroundColor: Colors.grey.shade900,
                        ),
                      ),
                      title: Text(
                        friendsController.friendsData[index]['display_name'],
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      trailing: Container(
                        width: 70,
                        child: Row(
                          children: [
                            InkWell(
                              enableFeedback: true,
                              child: Icon(CupertinoIcons.chat_bubble_text_fill),
                              onTap: () {
                                // Get.to(Chat(
                                //   chatId: friendsData[index]['chat_id'],
                                //   otherUsersData: friendsData[index],
                                //   currentUserData: currentUserData,
                                //   chatType: 'dm',
                                // ));
                              },
                            ),
                            SizedBox(
                              width: 20,
                            ),
                            InkWell(
                              enableFeedback: true,
                              child: Icon(
                                Icons.person_remove,
                                color: Colors.red,
                              ),
                              onTap: () {
                                removeFriend(
                                    mainController.currentUserData['id'],
                                    friendsController.friendsData[index]['id']);
                              },
                            )
                          ],
                        ),
                      ),
                    ),
                  );
                }),
          ));
  }
}
