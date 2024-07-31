import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:quarrel/pages/signin_page.dart';
import 'package:quarrel/pages/chats_page.dart';

// import 'package:quarrel/pages/notification_page.dart';
import 'package:quarrel/pages/friends_page.dart';
import 'package:quarrel/pages/profile_page.dart';
import 'package:quarrel/services/firebase_services.dart';
import 'package:quarrel/widgets/popup_menus.dart';
import 'package:quarrel/widgets/status_icons.dart';
import 'package:quarrel/firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(GetMaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData.dark().copyWith(
      textTheme: ThemeData.dark().textTheme.copyWith(
            bodyLarge: TextStyle(fontFamily: 'gg_sans'),
            bodyMedium: TextStyle(fontFamily: 'gg_sans'),
            bodySmall: TextStyle(fontFamily: 'gg_sans'),
          ),
      appBarTheme: AppBarTheme(
          backgroundColor: Colors.black,
          titleTextStyle: TextStyle(fontFamily: 'gg_sans'),
          toolbarTextStyle: TextStyle(fontFamily: 'gg_sans')),
      scaffoldBackgroundColor: Colors.black,
    ),
    home: Loading(),
  ));
}

bool result = false;
bool initialMain = true;

class Loading extends StatelessWidget {
  const Loading({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Widget>(
      future: _buildContent(context),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return snapshot.data!;
        } else if (snapshot.hasError) {
          print("${snapshot.error}");
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
    );
  }

  Future<Widget> _buildContent(BuildContext context) async {
    var userData;
    initialMain ? (userData = await autoLogin()) : null;
    if (userData[0]) {
      print('log data available');
      userData[1]['id'] = userData[2].user.uid;
      return Home(
        currentUserData: userData[1],
      );
    } else {
      print('failed due to error:${userData[1]}');
      return Signin();
    }
  }
}

var currentUserDataGlobalMain;
var update = 0.obs;
var selectedIndex = 0.obs;
var selectedUsername = '';
var selectedUserId = '';
var selectedUserPic = '';
var selectedChatType = '';

var showMenu = false.obs;
var showProfile = false.obs;

class Home extends StatelessWidget {
  final Map currentUserData;

  Home({
    super.key,
    required this.currentUserData,
  }) {
    currentUserDataGlobalMain = currentUserData;
    profileListener(currentUserData['id']);
  }

  @override
  Widget build(BuildContext context) {
    List pages = [
      Chats(
        toggleMenu: toggleMenu,
        toggleProfile: toggleProfile,
        currentUserData: currentUserDataGlobalMain,
      ),
      // const Notifications(),
      Friends(
        currentUserData: currentUserDataGlobalMain,
        toggleProfile: toggleProfile,
      ),
      Profile(
        currentUserData: currentUserDataGlobalMain,
        toggleMenu: toggleMenu,
      )
    ];

    return Stack(
      children: [
        Column(
          children: [
            Obx(() => Expanded(child: pages[selectedIndex.value])),
            Obx(() => BottomNavigationBar(
                  currentIndex: selectedIndex.value,
                  onTap: (index) {
                    selectedIndex.value = index;
                  },
                  unselectedFontSize: 10,
                  selectedFontSize: 10,
                  selectedItemColor: Colors.white,
                  unselectedItemColor: Colors.grey,
                  type: BottomNavigationBarType.fixed,
                  items: [
                    BottomNavigationBarItem(
                        icon: Icon(CupertinoIcons.chat_bubble_2_fill),
                        label: 'Messages'),
                    // BottomNavigationBarItem(
                    //     icon: Icon(Icons.notifications),
                    //     label: 'Notifications'),
                    BottomNavigationBarItem(
                        icon: Icon(Icons.people), label: 'Friends'),
                    BottomNavigationBarItem(
                        icon: Obx(() => SizedBox(
                              height: update == 1 ? 26 : 26,
                              width: 32,
                              child: Stack(
                                children: [
                                  CircleAvatar(
                                    backgroundImage: currentUserDataGlobalMain[
                                                'profile_picture'] !=
                                            ''
                                        ? CachedNetworkImageProvider(
                                            currentUserDataGlobalMain[
                                                'profile_picture'])
                                        : const AssetImage(
                                                'assets/images/default.png')
                                            as ImageProvider,
                                    radius: 11.5,
                                    backgroundColor: Color(0x20F2F2F2),
                                  ),
                                  Positioned(
                                    bottom: -1,
                                    right: -1,
                                    child: StatusIcon(
                                      icon_type: currentUserDataGlobalMain[
                                          'display_status'],
                                      border_color: Color(0xFF222222),
                                    ),
                                  ),
                                ],
                              ),
                            )),
                        label: 'Profile'),
                  ],
                )),
          ],
        ),
        Obx(() => Visibility(
              visible: showMenu.value || showProfile.value,
              child: GestureDetector(
                onTap: () {
                  selectedUserId = '';
                  showMenu.value = false;
                  showProfile.value = false;
                },
                child: Container(
                  color: Color(0xC01D1D1F),
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
              child: selectedIndex.value == 0
                  ? UserGroupPopup(
                      tileContent: [
                        selectedUserId,
                        selectedUsername,
                        selectedUserPic,
                        selectedChatType
                      ],
                    )
                  : selectedIndex.value == 2
                      ? StatusPopup(currentUserData: currentUserDataGlobalMain)
                      : Container(),
            )),
        Obx(() => AnimatedPositioned(
              duration: Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              bottom:
                  showProfile.value ? 0.0 : -MediaQuery.of(context).size.height,
              left: 0.0,
              right: 0.0,
              child: selectedUserId == ''
                  ? Container()
                  : ProfilePopup(selectedUser: selectedUserId),
            ))
      ],
    );
  }
}

void updateCurrentUserDataGlobalMain(newData) {
  currentUserDataGlobalMain = newData;
  update.value += 1;
}

void toggleMenu(dataList) {
  selectedUserId = dataList[0];
  selectedUsername = dataList[1];
  selectedUserPic = dataList[2];
  selectedChatType = dataList[3];
  showMenu.value = !showMenu.value;
}

void toggleProfile(data) {
  selectedUserId = data;
  showProfile.value = !showProfile.value;
}

//future builder code cuz i keep forgetting
// @override
// Widget build(BuildContext context) {
//   return FutureBuilder<Widget>(
//     future: _buildContent(context),
//     builder: (context, snapshot) {
//       if (snapshot.hasData) {
//         return snapshot.data!;
//       } else if (snapshot.hasError) {
//         return Text("${snapshot.error}");
//       }
//       return CircularProgressIndicator();
//     },
//   );
// }
//
// Future<Widget> _buildContent(BuildContext context) async {
