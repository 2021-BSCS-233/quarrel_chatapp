import 'package:quarrel/pages/signin_page.dart';
import "package:flutter/material.dart";
import 'package:get/get.dart';
import 'package:quarrel/services/language_controller.dart';
import 'package:quarrel/services/page_controllers.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Settings extends StatelessWidget {
  final MainController mainController = Get.find<MainController>();
  final SettingsController editSettingsController =
      Get.put(SettingsController());
  final LocalizationController localizationController =
      Get.find<LocalizationController>();

  Settings({super.key}) {
    editSettingsController.usernameController.text =
        mainController.currentUserData['username'];
    editSettingsController.emailController.text =
        mainController.currentUserData['email'];
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text(
                        'accountSetting'.tr,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 22),
                      ),
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    Text('usernameU'.tr,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade400,
                            fontSize: 12)),
                    TextFormField(
                      controller: editSettingsController.usernameController,
                      decoration: InputDecoration(
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                        floatingLabelBehavior: FloatingLabelBehavior.never,
                        border: OutlineInputBorder(),
                        labelText:
                            mainController.currentUserData['display_name'],
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Text('emailU'.tr,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade400,
                            fontSize: 12)),
                    TextFormField(
                      controller: editSettingsController.emailController,
                      decoration: InputDecoration(
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                        floatingLabelBehavior: FloatingLabelBehavior.never,
                        border: OutlineInputBorder(),
                        labelText: mainController.currentUserData['email'],
                      ),
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        InkWell(
                          onTap: () {
                            editSettingsController.toggleMenu();
                          },
                          child: Container(
                            height: 45,
                            width: 140,
                            decoration: BoxDecoration(
                                color: Colors.blueAccent.shade700,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10))),
                            child: Center(
                              child: Text(
                                'changePass'.tr,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 15),
                              ),
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            // update
                          },
                          child: Container(
                            height: 45,
                            width: 140,
                            decoration: BoxDecoration(
                                color: Colors.blueAccent.shade700,
                                borderRadius: const BorderRadius.all(
                                    Radius.circular(10))),
                            child: Center(
                              child: Text(
                                'save'.tr,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 15),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                Text('language'.tr,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade400,
                        fontSize: 14)),
                DropdownButton(
                    value: localizationController.prefs.getString('locale') ??
                        'en',
                    items: const [
                      DropdownMenuItem(
                        value: 'en',
                        child: Text('English'),
                      ),
                      DropdownMenuItem(
                        value: 'es',
                        child: Text('Spanish'),
                      )
                    ],
                    onChanged: (value) {
                      localizationController.setLocal(value);
                    }),
                const SizedBox(
                  height: 20,
                ),
                InkWell(
                  onTap: () async {
                    final SharedPreferences prefs =
                        await SharedPreferences.getInstance();
                    await prefs.remove('email');
                    await prefs.remove('password');
                    Get.offAll(Signin());
                  },
                  child: Container(
                    height: 45,
                    width: 140,
                    decoration: const BoxDecoration(
                        color: Colors.redAccent,
                        borderRadius: BorderRadius.all(Radius.circular(10))),
                    child: Center(
                      child: Text(
                        'logout'.tr,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Obx(() => Visibility(
              visible: editSettingsController.showMenu.value,
              child: GestureDetector(
                onTap: () {
                  editSettingsController.toggleMenu();
                },
                child: Container(
                  color: Color(0xC01D1D1F),
                  height: MediaQuery.of(context).size.height,
                  width: double.infinity,
                ),
              ),
            )),
        Obx(() => Material(
              color: Colors.transparent,
              child: Visibility(
                visible: editSettingsController.showMenu.value,
                child: SingleChildScrollView(
                  child: Center(
                    child: Container(
                      height: 400,
                      width: 300,
                      decoration: BoxDecoration(
                          color: Color(0xFF121218),
                          borderRadius: BorderRadius.all(Radius.circular(15))),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('oldPassU'.tr,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey.shade400,
                                  fontSize: 12)),
                          TextFormField(
                            controller:
                                editSettingsController.passwordController,
                            decoration: const InputDecoration(
                              contentPadding: EdgeInsets.symmetric(
                                  vertical: 5, horizontal: 10),
                              floatingLabelBehavior:
                                  FloatingLabelBehavior.never,
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(
                            height: 40,
                          ),
                          Text('oldPassU'.tr,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey.shade400,
                                  fontSize: 12)),
                          TextFormField(
                            controller:
                                editSettingsController.passwordController,
                            decoration: const InputDecoration(
                              contentPadding: EdgeInsets.symmetric(
                                  vertical: 5, horizontal: 10),
                              floatingLabelBehavior:
                                  FloatingLabelBehavior.never,
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            )),
      ],
    );
  }
}
