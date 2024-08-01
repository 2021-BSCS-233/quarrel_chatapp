import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:quarrel/services/firebase_services.dart';

class MainController extends GetxController {
  Map currentUserData;
  var updateM = 0.obs;
  var showMenu = false.obs;
  var showProfile = false.obs;
  var selectedIndex = 0.obs;
  var selectedUsername = '';
  var selectedUserId = '';
  var selectedUserPic = '';
  var selectedChatType = '';

  MainController({required this.currentUserData});

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

  void updateCurrentUserData(newData) {
    currentUserData = newData;
    updateM.value += 1;
  }
}

class SigninController extends GetxController {
  TextEditingController signInUsernameController = TextEditingController();
  TextEditingController signInDisplayController = TextEditingController();
  TextEditingController signInEmailController = TextEditingController();
  TextEditingController signInPassController = TextEditingController();

  var showOverlaySignIn = false.obs;
  var showMessageSignIn = false.obs;
  double messageHeightSignIn = 250;
  String failMessage = '';

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
}

class LoginController extends GetxController {
  TextEditingController logInEmailController = TextEditingController();
  TextEditingController logInPassController = TextEditingController();
  var showOverlayLogIn = false.obs;
  var showMessageLogIn = false.obs;

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
}

class FriendsController extends GetxController {
  bool initial = true;
  var updateF = 0.obs;
  var friendsListenerRef;
  List friendsData = [];

  getInitialData(currentUserId) async {
    friendsListenerRef = await friendsListener(
      currentUserId,
    );
    friendsData = await getInitialFriends(currentUserId);
    initial = false;
  }

  updateFriends(updateData, updateType) {
    var index = friendsData.indexWhere((map) => map['id'] == updateData['id']);
    if (updateType == 'modified') {
      friendsData[index] = updateData;
    } else if (updateType == 'added' && index < 0) {
      friendsData.insert(0, updateData);
    } else if (updateType == 'removed') {
      friendsData.removeAt(index);
    }
    updateF.value += 1;
  }
}

class ChatsController extends GetxController {
  var updateCs = 0.obs;
  bool initial = true;
  var chatsListenerRef;
  List chatsData = [];

  getInitialData(currentUserId) async {
    chatsListenerRef = await chatsListener(currentUserId, updateChats);
    chatsData = await getInitialChats(currentUserId);
    initial = false;
  }

  updateChats(updateData, updateType) {
    var index = chatsData.indexWhere((map) => map['id'] == updateData['id']);
    if (updateType == 'modified') {
      chatsData[index]['latest_message'] = updateData['latest_message'];
      chatsData[index]['time_stamp'] = updateData['time_stamp'];
    } else if (updateType == 'added' && index < 0) {
      chatsData.insert(0, updateData);
    }
    // update.value += 1;
  }
}

class ChatController extends GetxController {
  var chatContent = [];
  var messagesListenerRef;
  var userMap = {};
  var lastSender = '';
  var initial = true;
  var messageSelected = 0;
  var showMenu = false.obs;
  var updateC = 0.obs;
  var showProfile = false.obs;
  var fieldCheck = false.obs;
  TextEditingController chatFieldController = TextEditingController();

  getMessages(chatId) async {
    messagesListenerRef = await messagesListener(chatId);
    chatContent = await getInitialMessages(chatId);
    initial = false;
  }

  updateMessages(updateData, updateType) {
    var index = chatContent.indexWhere((map) => map['id'] == updateData['id']);
    if (updateType == 'added' && index < 0) {
      chatContent.insert(0, updateData);
    } else if (updateType == 'modified') {
      chatContent[index]['message'] = updateData['message'];
      chatContent[index]['edited'] = true;
    } else if (updateType == 'removed') {
      chatContent.removeAt(index);
    }
    updateC.value += 1;
  }
}

class RequestsController extends GetxController {
  var updateI = 0.obs;
  var updateO = 0.obs;
  var initial = true;
  List incomingRequestsData = [];
  List outgoingRequestsData = [];
  var fieldCheck = false.obs;
  TextEditingController requestsFieldController = TextEditingController();

  void changing() {
    fieldCheck.value = (requestsFieldController.text != '' ? true : false);
  }

  getInitialData(currentUserId) async {
    requestsListeners(currentUserId);
    var result = await getInitialRequest(currentUserId);
    incomingRequestsData = result[0];
    outgoingRequestsData = result[1];
    initial = false;
  }

  updateIncomingRequests(updateData, updateType) {
    var index =
        incomingRequestsData.indexWhere((map) => map['id'] == updateData['id']);
    if (updateType == 'added' && index < 0) {
      incomingRequestsData.insert(0, updateData);
    } else if (updateType == 'removed') {
      incomingRequestsData.removeAt(index);
    }
    updateI.value += 1;
  }

  updateOutgoingRequests(updateData, updateType) {
    var index =
        outgoingRequestsData.indexWhere((map) => map['id'] == updateData['id']);
    if (updateType == 'added' && index < 0) {
      outgoingRequestsData.insert(0, updateData);
    } else if (updateType == 'removed') {
      outgoingRequestsData.removeAt(index);
    }
    updateO.value += 1;
  }
}

class EditProfileController extends GetxController {
  TextEditingController displayController = TextEditingController();
  TextEditingController pronounceController = TextEditingController();
  TextEditingController aboutMeController = TextEditingController();
  var image;
  var updateP = 0.obs;
}
