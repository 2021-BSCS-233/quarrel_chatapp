import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quarrel/pages/requests_page.dart';
import 'package:quarrel/widgets/dm_chat_tile.dart';
import 'package:quarrel/widgets/status_icons.dart';
import 'package:quarrel/services/page_controllers.dart';

class Chats extends StatelessWidget {
  final MainController mainController = Get.find<MainController>();
  final ChatsController chatsController = Get.put(ChatsController());
  final FriendsController friendsController = Get.put(FriendsController());

  Chats({super.key}) {
    chatsController.initial = true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'messages'.tr,
          style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xD0FFFFFF),
              fontSize: 22),
        ),
        actions: [
          InkWell(
            enableFeedback: true,
            onTap: () {
              Get.to(Requests());
            },
            child: SizedBox(
              height: 40,
              width: 120,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.person_add),
                  const SizedBox(
                    width: 10,
                  ),
                  Text('addFriend'.tr),
                ],
              ),
            ),
          ),
          const SizedBox(
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
            return const Material(
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
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Future<Widget> chatsUI() async {
    chatsController.initial
        ? await chatsController
            .getInitialData(mainController.currentUserData['id'])
        : null;
    friendsController.initial
        ? await friendsController
            .getInitialData(mainController.currentUserData['id'])
        : null;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        children: [
          Obx(
            () => SizedBox(
                width: double.infinity,
                height: friendsController.friendsData.isEmpty ? 0 : 90,
                child: friendsController.updateF.value ==
                            friendsController.updateF.value &&
                        friendsController.friendsData.isEmpty
                    ? const SizedBox()
                    : ListView.builder(
                        itemCount: friendsController.friendsData.length < 20
                            ? friendsController.friendsData.length
                            : 20,
                        shrinkWrap: true,
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (context, index) {
                          return Container(
                            margin: const EdgeInsets.all(5),
                            height: 80,
                            width: 80,
                            decoration: BoxDecoration(
                                color: Color(0xAA18181F),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(15))),
                            child: Center(
                              child: InkWell(
                                onTap: () {
                                  mainController.toggleProfile(friendsController
                                      .friendsData[index]['id']);
                                },
                                child: Stack(
                                  children: [
                                    SizedBox(
                                      height: 50,
                                      width: 50,
                                      child: CircleAvatar(
                                        backgroundImage: friendsController
                                                        .friendsData[index]
                                                    ['profile_picture'] !=
                                                ''
                                            ? CachedNetworkImageProvider(
                                                friendsController
                                                        .friendsData[index]
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
                                        iconType: friendsController
                                                        .friendsData[index]
                                                    ['status'] ==
                                                'Online'
                                            ? friendsController
                                                    .friendsData[index]
                                                ['display_status']
                                            : friendsController
                                                .friendsData[index]['status'],
                                        iconSize: 17,
                                        iconBorder: 3.5,
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
                child: chatsController.updateCs.value ==
                            chatsController.updateCs.value &&
                        chatsController.chatsData.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'chatsEmpty'.tr,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(
                              height: 90,
                            )
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: chatsController.chatsData.length,
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          return chatsController.chatsData[index]
                                      ['chat_type'] ==
                                  'dm'
                              ? DmChatTile(
                                  chatData: chatsController.chatsData[index])
                              : SizedBox(
                                  height: 50,
                                  width: 100,
                                  child: Center(
                                    child: Text(
                                        'add support for ${chatsController.chatsData[index]['chat_type']}'),
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
