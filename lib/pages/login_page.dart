import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:quarrel/main.dart';
import 'package:get/get.dart';
import 'package:quarrel/widgets/input_field.dart';
import 'package:quarrel/services/page_controllers.dart';
import 'package:quarrel/services/firebase_services.dart';

class Login extends StatelessWidget {
  final LoginController loginController = Get.put(LoginController());

  Login({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            title: Text(
              'Log In',
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
                  const SizedBox(
                    height: 30,
                  ),
                  Text(
                    'Welcome back!',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 25,
                    ),
                  ),
                  Text('We\'re excited to see you again!'),
                  const SizedBox(
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
                    fieldLabel: 'Email',
                    controller: loginController.logInEmailController,
                    fieldRadius: 2,
                    horizontalMargin: 0,
                    verticalMargin: 2,
                    fieldHeight: 50,
                    contentTopPadding: 13,
                    suffixIcon: Icons.all_inclusive,
                  ),
                  InputField(
                    fieldLabel: 'Password',
                    controller: loginController.logInPassController,
                    fieldRadius: 2,
                    horizontalMargin: 0,
                    verticalMargin: 2,
                    fieldHeight: 50,
                    contentTopPadding: 13,
                    suffixIcon: CupertinoIcons.eye,
                  ),
                  const SizedBox(
                    height: 40,
                  ),
                  InkWell(
                    onTap: () async {
                      loginController.showOverlayLogIn.value = true;
                      var userData = await loginController.sendLogIn(
                          loginController.logInEmailController.text.trim(),
                          loginController.logInPassController.text.trim());
                      if (userData != 0) {
                        await saveUserOnDevice(
                            loginController.logInEmailController.text.trim(),
                            loginController.logInPassController.text.trim());
                        loginController.showOverlayLogIn.value = false;
                        userData[0]['id'] = userData[1].user.uid;
                        Get.off(Home(
                          userData: userData[0],
                        ));
                      } else {
                        loginController.showOverlayLogIn.value = true;
                        loginController.showMessageLogIn.value = true;
                      }
                    },
                    child: Container(
                      height: 40,
                      width: double.infinity,
                      child: Center(child: Text('Log In')),
                      decoration: BoxDecoration(
                          color: Colors.blueAccent.shade700,
                          borderRadius: BorderRadius.all(Radius.circular(5))),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
        Obx(() => Visibility(
              visible: loginController.showOverlayLogIn.value ||
                  loginController.showMessageLogIn.value,
              child: GestureDetector(
                onTap: loginController.showMessageLogIn.value
                    ? () {
                        loginController.showOverlayLogIn.value = false;
                        loginController.showMessageLogIn.value = false;
                      }
                    : () {},
                child: Container(
                  color: Color(0xC01D1D1F),
                  height: MediaQuery.of(context).size.height,
                  width: double.infinity,
                  child: const Center(child: CircularProgressIndicator()),
                ),
              ),
            )),
        Obx(() => Material(
              color: Colors.transparent,
              child: Visibility(
                visible: loginController.showMessageLogIn.value,
                child: Center(
                  child: Container(
                    padding: EdgeInsets.all(20),
                    height: 200,
                    width: 300,
                    decoration: BoxDecoration(
                        color: Color(0xFF121218),
                        borderRadius: BorderRadius.all(Radius.circular(15))),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('LogIn Failed',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 18)),
                        const SizedBox(height: 5),
                        Text('Email or Password is Wrong',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 15)),
                        const SizedBox(height: 35),
                        InkWell(
                          onTap: () {
                            loginController.showMessageLogIn.value = false;
                            loginController.showOverlayLogIn.value = false;
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
                                borderRadius: const BorderRadius.all(
                                    Radius.circular(10))),
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
