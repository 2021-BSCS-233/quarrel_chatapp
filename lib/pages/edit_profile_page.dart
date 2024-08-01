import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quarrel/services/controllers.dart';
import 'package:quarrel/widgets/status_icons.dart';
import 'package:quarrel/services/firebase_services.dart';

// var _selectedColor = Color(0xFFFFC42C).obs;
class EditProfile extends StatelessWidget {
  final MainController mainController = Get.find<MainController>();
  final EditProfileController editProfileController =
      Get.put(EditProfileController());

  EditProfile({
    super.key,
  }) {
    editProfileController.displayController.text =
        mainController.currentUserData['display_name'];
    editProfileController.pronounceController.text =
        mainController.currentUserData['pronounce'];
    editProfileController.aboutMeController.text =
        mainController.currentUserData['about_me'];
    editProfileController.image = null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF121218),
      appBar: AppBar(
        title: Text(
          'Edit Profile',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        actions: [
          InkWell(
            onTap: () async {
              await updateProfile(
                  mainController.currentUserData['id'],
                  editProfileController.displayController.text.trim() != ''
                      ? editProfileController.displayController.text.trim()
                      : mainController.currentUserData['display_name'],
                  editProfileController.pronounceController.text.trim() != ''
                      ? editProfileController.pronounceController.text.trim()
                      : mainController.currentUserData['pronounce'],
                  editProfileController.aboutMeController.text.trim() != ''
                      ? editProfileController.aboutMeController.text.trim()
                      : mainController.currentUserData['about_me'],
                  editProfileController.image);
              Get.back();
            },
            child: Container(
              height: 50,
              width: 80,
              child: Center(
                child: Text(
                  'Save',
                  style: TextStyle(
                      color: Colors.blueAccent,
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children: [
                Column(
                  children: [
                    Container(
                      width: double.infinity,
                      height: 150,
                      color: Colors.yellow
                          .shade700,
                    ),
                    Container(
                      width: double.infinity,
                      height: 60,
                      color: Colors.transparent,
                    )
                  ],
                ),
                Positioned(
                  bottom: 10,
                  left: 20,
                  child: InkWell(
                    onTap: () async {
                      editProfileController.image = await ImagePicker()
                          .pickImage(source: ImageSource.gallery);
                      editProfileController.updateP.value += 1;
                    },
                    child: Stack(
                      children: [
                        Container(
                          height: 90,
                          width: 90,
                          decoration: BoxDecoration(
                              color: Colors.transparent,
                              shape: BoxShape.circle,
                              border: Border.all(
                                  width: 6, color: Color(0xFF121218))),
                          child: Obx(() => CircleAvatar(
                                backgroundImage: editProfileController
                                                .updateP.value ==
                                            editProfileController
                                                .updateP.value &&
                                        editProfileController.image != null
                                    ? FileImage(
                                        File(editProfileController.image.path))
                                    : mainController.currentUserData[
                                                'profile_picture'] !=
                                            ''
                                        ? CachedNetworkImageProvider(
                                            mainController.currentUserData[
                                                'profile_picture'])
                                        : const AssetImage(
                                                'assets/images/default.png')
                                            as ImageProvider,
                                // radius: 10,
                                backgroundColor: Colors.grey.shade900,
                              )),
                        ),
                        Positioned(
                          bottom: 3,
                          right: 3,
                          child: StatusIcon(
                            icon_type: mainController
                                .currentUserData['display_status'],
                            icon_size: 24,
                            icon_border: 4,
                          ),
                        ),
                        Positioned(
                            right: 3,
                            top: 3,
                            child: Container(
                              height: 24,
                              width: 24,
                              child: Icon(
                                Icons.edit,
                                size: 14,
                                color: Colors.grey.shade400,
                              ),
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Color(0xFF121218)),
                            )),
                      ],
                    ),
                  ),
                ),
                // Positioned(
                //     right: 15,
                //     top: 40,
                //     child: InkWell(
                //       onTap: () async {
                //         final result = await FlexColorPicker.showColorPicker(
                //           context: context,
                //           color: _selectedColor, // Set initial color
                //         );
                //         if (result != null) {
                //           _selectedColor.value = result.color;
                //           // widget.onColorPicked(result.color.toHex());
                //         }
                //       },
                //       child: Container(
                //           height: 35,
                //           width: 35,
                //           decoration: BoxDecoration(
                //             shape: BoxShape.circle,
                //             color: Colors.black54
                //           ),
                //           child: Icon(Icons.settings, size: 28,)),
                //     ))
              ],
            ),
            Container(
              margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
              padding: EdgeInsets.symmetric(horizontal: 14, vertical: 18),
              alignment: Alignment.centerLeft,
              width: double.infinity,
              decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.all(Radius.circular(15))),
              child: Container(
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('DISPLAY NAME',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade400,
                            fontSize: 12)),
                    TextFormField(
                      controller: editProfileController.displayController,
                      decoration: InputDecoration(
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                        floatingLabelBehavior: FloatingLabelBehavior.never,
                        border: OutlineInputBorder(),
                        labelText:
                            mainController.currentUserData['display_name'],
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Text('PRONOUNS',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade400,
                            fontSize: 12)),
                    TextFormField(
                      maxLength: 40,
                      controller: editProfileController.pronounceController,
                      decoration: InputDecoration(
                          contentPadding:
                              EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                          floatingLabelBehavior: FloatingLabelBehavior.never,
                          border: OutlineInputBorder(),
                          labelText:
                              mainController.currentUserData['pronounce']),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Text('ABOUT ME',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade400,
                            fontSize: 12)),
                    TextFormField(
                      controller: editProfileController.aboutMeController,
                      maxLines: 7,
                      maxLength: 190,
                      decoration: InputDecoration(
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                        floatingLabelBehavior: FloatingLabelBehavior.never,
                        border: OutlineInputBorder(),
                        label: Text(mainController.currentUserData['about_me']),
                        // labelStyle: TextStyle(overflow: TextOverflow.ellipsis)
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
