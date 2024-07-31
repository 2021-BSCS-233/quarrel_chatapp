import 'package:flutter/cupertino.dart';
import 'package:quarrel/services/firebase_services.dart';
import 'package:quarrel/widgets/input_field.dart';
import 'package:flutter/material.dart';
import 'package:quarrel/main.dart';
import 'package:get/get.dart';

TextEditingController logInEmailController = TextEditingController();
TextEditingController logInPassController = TextEditingController();
var showOverlayLogIn = false.obs;
var showMessageLogIn = false.obs;

class Login extends StatelessWidget {
  const Login({super.key});

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
                  SizedBox(
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
                    fieldLabel: 'Email',
                    controller: logInEmailController,
                    fieldRadius: 2,
                    horizontalMargin: 0,
                    verticalMargin: 2,
                    fieldHeight: 50,
                    contentTopPadding: 13,
                    suffixIcon: Icons.all_inclusive,
                  ),
                  InputField(
                    fieldLabel: 'Password',
                    controller: logInPassController,
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
                      showOverlayLogIn.value = true;
                      var userData = await sendLogIn(
                          logInEmailController.text.trim(),
                          logInPassController.text.trim());
                      if (userData != 0) {
                        await saveUserOnDevice(logInEmailController.text.trim(),
                            logInPassController.text.trim());
                        showOverlayLogIn.value = false;
                        userData[0]['id'] = userData[1].user.uid;
                        Get.off(Home(
                          currentUserData: userData[0],
                        ));
                      } else {
                        showOverlayLogIn.value = true;
                        showMessageLogIn.value = true;
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
              visible: showOverlayLogIn.value || showMessageLogIn.value,
              child: GestureDetector(
                onTap: showMessageLogIn.value
                    ? () {
                        showOverlayLogIn.value = false;
                        showMessageLogIn.value = false;
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
                visible: showMessageLogIn.value,
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
                        SizedBox(height: 5),
                        Text('Email or Password is Wrong',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 15)),
                        SizedBox(height: 35),
                        InkWell(
                          onTap: () {
                            showMessageLogIn.value = false;
                            showOverlayLogIn.value = false;
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

sendLogIn(email, pass) async {
  if (RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email) &&
      RegExp(r'.{8,}').hasMatch(pass)) {
    print('sending log in');
    var response = await logInUser(email, pass);
    if (response?[0] != false) {
      return response;
    } else {
      return 0;
    }
  } else {
    print('login denied');
    return 0;
  }
}
