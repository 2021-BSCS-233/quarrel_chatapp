import 'package:flutter/cupertino.dart';
import 'package:quarrel/pages/login_page.dart';
import 'package:quarrel/services/firebase_services.dart';
import 'package:quarrel/widgets/input_field.dart';
import 'package:flutter/material.dart';
import 'package:quarrel/main.dart';
import 'package:get/get.dart';

TextEditingController signInUsernameController = TextEditingController();
TextEditingController signInDisplayController = TextEditingController();
TextEditingController signInEmailController = TextEditingController();
TextEditingController signInPassController = TextEditingController();

var showOverlaySignIn = false.obs;
var showMessageSignIn = false.obs;
double messageHeightSignIn = 250;
String failMessage = '';

class Signin extends StatelessWidget {
  void checkNameFormat(TextEditingController controller) {
    if (RegExp(r'^[a-zA-Z][a-zA-Z0-9_]*?$').hasMatch(controller.text)) {
      print('matches');
    } else {
      print('doesnt match');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            title: Text(
              'Create Account',
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),
            centerTitle: true,
          ),
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                // mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 30,
                  ),
                  Text(
                    'Welcome To Quarrel!',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 25,
                    ),
                  ),
                  Text('We\'re excited to see you join us!'),
                  SizedBox(
                    height: 40,
                  ),
                  Align(
                    child: Container(
                        margin: EdgeInsets.only(left: 5, bottom: 5),
                        child: Text(
                          'ACCOUNT INFORMATION',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 10),
                        )),
                    alignment: Alignment.centerLeft,
                  ),
                  InputField(
                    fieldLabel: 'Username',
                    controller: signInUsernameController,
                    fieldRadius: 2,
                    horizontalMargin: 0,
                    verticalMargin: 2,
                    fieldHeight: 50,
                    contentTopPadding: 13,
                    suffixIcon: Icons.all_inclusive,
                    maxLength: 20,
                    // on_change: () {
                    //   checkNameFormat(username_controller);
                    // },
                  ),
                  InputField(
                    fieldLabel: 'Display Name',
                    controller: signInDisplayController,
                    fieldRadius: 2,
                    horizontalMargin: 0,
                    verticalMargin: 2,
                    fieldHeight: 50,
                    contentTopPadding: 13,
                    suffixIcon: Icons.all_inclusive,
                  ),
                  InputField(
                    fieldLabel: 'Email',
                    controller: signInEmailController,
                    fieldRadius: 2,
                    horizontalMargin: 0,
                    verticalMargin: 2,
                    fieldHeight: 50,
                    contentTopPadding: 13,
                    suffixIcon: Icons.all_inclusive,
                  ),
                  InputField(
                    fieldLabel: 'Password',
                    controller: signInPassController,
                    fieldRadius: 2,
                    horizontalMargin: 0,
                    verticalMargin: 2,
                    fieldHeight: 50,
                    contentTopPadding: 13,
                    suffixIcon: CupertinoIcons.eye,
                  ),
                  SizedBox(
                    height: 40,
                  ),
                  InkWell(
                    onTap: () async {
                      showOverlaySignIn.value = true;
                      var userData = await sendSignIn(
                          signInUsernameController.text.trim(),
                          signInDisplayController.text.trim(),
                          signInEmailController.text.trim(),
                          signInPassController.text.trim());
                      if (userData != 0) {
                        await saveUserOnDevice(
                            signInEmailController.text.trim(),
                            signInPassController.text.trim());
                        showOverlaySignIn.value = false;
                        userData[0]['id'] = userData[1].user.uid;
                        Get.off(Home(
                          currentUserData: userData[0],
                        ));
                      } else {
                        print('SingIn failed');
                      }
                    },
                    child: Container(
                      height: 40,
                      width: double.infinity,
                      child: Center(child: Text('Sign In')),
                      decoration: BoxDecoration(
                          color: Colors.blueAccent.shade700,
                          borderRadius: BorderRadius.all(Radius.circular(5))),
                    ),
                  ),
                  InkWell(
                    enableFeedback: false,
                    onTap: () {
                      Get.to(Login());
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            'Already have an account? Log In',
                            style: TextStyle(color: Colors.blueAccent.shade200),
                          )),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Obx(() => Visibility(
              visible: showOverlaySignIn.value || showMessageSignIn.value,
              child: GestureDetector(
                onTap: showMessageSignIn.value
                    ? () {
                        showMessageSignIn.value = false;
                        showOverlaySignIn.value = false;
                        messageHeightSignIn = 250;
                        failMessage = '';
                      }
                    : () {},
                child: Container(
                  color: Color(0xC01D1D1F),
                  height: MediaQuery.of(context).size.height,
                  width: double.infinity,
                  child: Center(child: CircularProgressIndicator()),
                ),
              ),
            )),
        Obx(() => Material(
              color: Colors.transparent,
              child: Visibility(
                visible: showMessageSignIn.value,
                child: Center(
                  child: Container(
                    padding: EdgeInsets.all(20),
                    height: messageHeightSignIn,
                    width: 300,
                    decoration: BoxDecoration(
                        color: Color(0xFF121218),
                        borderRadius: BorderRadius.all(Radius.circular(15))),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('SignIn Failed',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 18)),
                        SizedBox(height: 5),
                        Text(failMessage,
                            // textAlign: TextAlign.center,
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 15)),
                        SizedBox(height: 35),
                        InkWell(
                          onTap: () {
                            showMessageSignIn.value = false;
                            showOverlaySignIn.value = false;
                            messageHeightSignIn = 250;
                            failMessage = '';
                          },
                          child: Container(
                            height: 50,
                            width: 130,
                            child: Center(
                              child: Text(
                                'Close',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 17),
                              ),
                            ),
                            decoration: BoxDecoration(
                                color: Colors.blueAccent.shade700,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10))),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            )),
      ],
    );
  }
}

sendSignIn(user, display, email, pass) async {
  if (RegExp(r'^[a-zA-Z][a-zA-Z0-9_]*?$').hasMatch(user) &&
      user.length >= 3 &&
      user.length <= 20 &&
      RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email) &&
      RegExp(r'.{8,}').hasMatch(pass)) {
    print('All accepted');
    var response = await signInUser(user, display, email, pass);
    if (response?[0] != false) {
      return response;
    } else {
      failMessage = '• ${response?[1]}';
      showOverlaySignIn.value = true;
      showMessageSignIn.value = true;
      return 0;
    }
  } else {
    if (user == '') {
      failMessage = '• Pls Enter a Username';
    } else if (user.length < 3 || user.length > 20) {
      failMessage = '• Length of Username Must Between 3 to 20';
    } else if (!(RegExp(r'^[a-zA-Z][a-zA-Z0-9_]+?$').hasMatch(user))) {
      failMessage =
          '• Username Must Start With An Alphabet And Can Only Container Letters, Numbers and \'_\'';
      messageHeightSignIn += 15;
    }
    if (!(RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email))) {
      failMessage = "$failMessage\n• Invalid Email Format";
      messageHeightSignIn += 10;
    }
    if (!(RegExp(r'.{8,}').hasMatch(pass))) {
      failMessage = "$failMessage\n• Password Must be At Least 8 Characters";
      messageHeightSignIn += 10;
    }
    showOverlaySignIn.value = true;
    showMessageSignIn.value = true;
    print('failed');
    return 0;
  }
}
