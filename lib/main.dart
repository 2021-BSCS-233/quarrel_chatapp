import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:quarrel/pages/signin_page.dart';
import 'package:quarrel/pages/chats_page.dart';
import 'package:quarrel/pages/friends_page.dart';
import 'package:quarrel/pages/profile_page.dart';
import 'package:quarrel/services/firebase_services.dart';
import 'package:quarrel/widgets/popup_menus.dart';
import 'package:quarrel/widgets/status_icons.dart';
import 'package:quarrel/firebase_options.dart';
import 'package:quarrel/services/controllers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(GetMaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData.dark().copyWith(
      textTheme: ThemeData.dark().textTheme.copyWith(
            bodyLarge: const TextStyle(fontFamily: 'gg_sans'),
            bodyMedium: const TextStyle(fontFamily: 'gg_sans'),
            bodySmall: const TextStyle(fontFamily: 'gg_sans'),
          ),
      appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black,
          titleTextStyle: TextStyle(fontFamily: 'gg_sans'),
          toolbarTextStyle: TextStyle(fontFamily: 'gg_sans')),
      scaffoldBackgroundColor: Colors.black,
    ),
    // localizationsDelegates: [
    //   GlobalMaterialLocalizations.delegate,
    //   GlobalWidgetsLocalizations.delegate,
    //   GlobalCupertinoLocalizations.delegate,
    // ],
    // supportedLocales: [
    //   Locale('en'), // English
    //   Locale('es'), // Spanish
    // ],
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    locale: Locale('en'),
    home: Loading(),
  ));
}

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
        return const Center(child: CircularProgressIndicator());
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
        userData: userData[1],
      );
    } else {
      print('failed due to error:${userData[1]}');
      return Signin();
    }
  }
}

class Home extends StatelessWidget {
  final Map userData;
  late final MainController mainController;

  Home({
    super.key,
    required this.userData,
  }) {
    mainController = Get.put(MainController(currentUserData: userData));
    profileListener(userData['id']);
  }

  @override
  Widget build(BuildContext context) {
    List pages = [
      Chats(),
      // const Notifications(),
      Friends(),
      Profile()
    ];

    return Stack(
      children: [
        Column(
          children: [
            Obx(() => Expanded(child: pages[mainController.selectedIndex.value])),
            Obx(() => BottomNavigationBar(
                  currentIndex: mainController.selectedIndex.value,
                  onTap: (index) {
                    mainController.selectedIndex.value = index;
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
                              height: mainController.updateM.value == 1 ? 26 : 26,
                              width: 32,
                              child: Stack(
                                children: [
                                  CircleAvatar(
                                    backgroundImage: mainController.currentUserData[
                                                'profile_picture'] !=
                                            ''
                                        ? CachedNetworkImageProvider(
                                        mainController.currentUserData[
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
                                      icon_type: mainController.currentUserData[
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
              visible:
                  mainController.showMenu.value || mainController.showProfile.value,
              child: GestureDetector(
                onTap: () {
                  mainController.selectedUserId = '';
                  mainController.showMenu.value = false;
                  mainController.showProfile.value = false;
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
              bottom: mainController.showMenu.value
                  ? 0.0
                  : -MediaQuery.of(context).size.height,
              left: 0.0,
              right: 0.0,
              child: mainController.selectedIndex.value == 0
                  ? UserGroupPopup(
                      tileContent: [
                        mainController.selectedUserId,
                        mainController.selectedUsername,
                        mainController.selectedUserPic,
                        mainController.selectedChatType
                      ],
                    )
                  : mainController.selectedIndex.value == 2
                      ? StatusPopup(currentUserData: mainController.currentUserData)
                      : Container(),
            )),
        Obx(() => AnimatedPositioned(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              bottom: mainController.showProfile.value
                  ? 0.0
                  : -MediaQuery.of(context).size.height,
              left: 0.0,
              right: 0.0,
              child: mainController.selectedUserId == ''
                  ? Container()
                  : ProfilePopup(selectedUser: mainController.selectedUserId),
            ))
      ],
    );
  }
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
