import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:quarrel/main.dart';
import 'package:get/get.dart';
import 'package:quarrel/pages/login_page.dart';
import 'package:quarrel/widgets/input_field.dart';
import 'package:quarrel/services/controllers.dart';
import 'package:quarrel/services/firebase_services.dart';

class Signin extends StatelessWidget {
  final SigninController signinController = Get.put(SigninController());

  Signin({super.key});

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
                    controller: signinController.signInUsernameController,
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
                    controller: signinController.signInDisplayController,
                    fieldRadius: 2,
                    horizontalMargin: 0,
                    verticalMargin: 2,
                    fieldHeight: 50,
                    contentTopPadding: 13,
                    suffixIcon: Icons.all_inclusive,
                  ),
                  InputField(
                    fieldLabel: 'Email',
                    controller: signinController.signInEmailController,
                    fieldRadius: 2,
                    horizontalMargin: 0,
                    verticalMargin: 2,
                    fieldHeight: 50,
                    contentTopPadding: 13,
                    suffixIcon: Icons.all_inclusive,
                  ),
                  InputField(
                    fieldLabel: 'Password',
                    controller: signinController.signInPassController,
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
                      signinController.showOverlaySignIn.value = true;
                      var userData = await signinController.sendSignIn(
                          signinController.signInUsernameController.text.trim(),
                          signinController.signInDisplayController.text.trim(),
                          signinController.signInEmailController.text.trim(),
                          signinController.signInPassController.text.trim());
                      if (userData != 0) {
                        await saveUserOnDevice(
                            signinController.signInEmailController.text.trim(),
                            signinController.signInPassController.text.trim());
                        signinController.showOverlaySignIn.value = false;
                        userData[0]['id'] = userData[1].user.uid;
                        Get.off(Home(
                          userData: userData[0],
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
              visible: signinController.showOverlaySignIn.value ||
                  signinController.showMessageSignIn.value,
              child: GestureDetector(
                onTap: signinController.showMessageSignIn.value
                    ? () {
                        signinController.showMessageSignIn.value = false;
                        signinController.showOverlaySignIn.value = false;
                        signinController.messageHeightSignIn = 250;
                        signinController.failMessage = '';
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
                visible: signinController.showMessageSignIn.value,
                child: Center(
                  child: Container(
                    padding: EdgeInsets.all(20),
                    height: signinController.messageHeightSignIn,
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
                        Text(signinController.failMessage,
                            // textAlign: TextAlign.center,
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 15)),
                        SizedBox(height: 35),
                        InkWell(
                          onTap: () {
                            signinController.showMessageSignIn.value = false;
                            signinController.showOverlaySignIn.value = false;
                            signinController.messageHeightSignIn = 250;
                            signinController.failMessage = '';
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
