import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quarrel/pages/edit_profile_page.dart';
import 'package:quarrel/pages/settings_page.dart';
import 'package:quarrel/services/page_controllers.dart';
import 'package:quarrel/widgets/status_icons.dart';

class Profile extends StatelessWidget {
  final MainController mainController = Get.find<MainController>();

  Profile({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Obx(() => Column(
              children: [
                Stack(
                  children: [
                    Column(
                      children: [
                        Container(
                          width: double.infinity,
                          height: 150,
                          color: Colors.yellow
                              .shade700, //make it adapt to the major color of profile
                        ),
                        Container(
                          width: double.infinity,
                          height: 50,
                          color: Colors.transparent,
                        )
                      ],
                    ),
                    Positioned(
                      bottom: 0,
                      left: 20,
                      child: Stack(
                        children: [
                          Container(
                            height: 90,
                            width: 90,
                            decoration: BoxDecoration(
                                color: Colors.transparent,
                                shape: BoxShape.circle,
                                border: Border.all(width: 6)),
                            child: CircleAvatar(
                              backgroundImage: mainController
                                          .currentUserData['profile_picture'] !=
                                      ''
                                  ? CachedNetworkImageProvider(mainController
                                      .currentUserData['profile_picture'])
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
                              iconType: mainController
                                  .currentUserData['display_status'],
                              iconSize: 24,
                              iconBorder: 4,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                        right: 15,
                        top: 40,
                        child: InkWell(
                          onTap: () {
                            Get.to(Settings());
                          },
                          child: Container(
                              height: 35,
                              width: 35,
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.black54),
                              child: const Icon(
                                Icons.settings,
                                size: 28,
                              )),
                        ))
                  ],
                ),
                Container(
                  margin:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 18),
                  alignment: Alignment.centerLeft,
                  width: double.infinity,
                  height: 168,
                  decoration: BoxDecoration(
                      color: Color(0xFF121218),
                      borderRadius: BorderRadius.all(Radius.circular(15))),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        mainController.updateM.value == 1
                            ? mainController.currentUserData['display_name']
                            : mainController.currentUserData['display_name'],
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(
                        height: 3,
                      ),
                      Text(
                        mainController.currentUserData['username'],
                        style: const TextStyle(fontSize: 14),
                      ),
                      const SizedBox(
                        height: 3,
                      ),
                      Text(
                        mainController.currentUserData['pronouns'],
                        style:
                            const TextStyle(fontSize: 15, color: Colors.grey),
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      Container(
                        width: double.infinity,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            InkWell(
                              onTap: () {
                                mainController.toggleMenu(
                                    ['null', 'null', 'null', 'null']);
                              },
                              child: Container(
                                  height: 38,
                                  width: 140,
                                  padding: EdgeInsets.symmetric(horizontal: 10),
                                  decoration: BoxDecoration(
                                      color: Colors.blueAccent.shade400,
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(20))),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      const Icon(
                                        CupertinoIcons.chat_bubble_fill,
                                        size: 20,
                                      ),
                                      Text(
                                        'editStatus'.tr,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      )
                                    ],
                                  )),
                            ),
                            InkWell(
                              onTap: () {
                                print('Editing Profile');
                                Get.to(EditProfile());
                              },
                              child: Container(
                                height: 38,
                                width: 140,
                                padding: EdgeInsets.symmetric(horizontal: 10),
                                decoration: BoxDecoration(
                                    color: Colors.blueAccent.shade400,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(20))),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    const Icon(
                                      Icons.edit,
                                      size: 20,
                                    ),
                                    Text(
                                      'editProfile'.tr,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                  padding: EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  alignment: Alignment.centerLeft,
                  width: double.infinity,
                  // height: 200,
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
                        mainController.currentUserData['about_me'],
                        style: TextStyle(
                            fontSize: 15, color: Colors.grey.shade300),
                      )
                    ],
                  ),
                ),
              ],
            )),
      ),
    );
  }
}
