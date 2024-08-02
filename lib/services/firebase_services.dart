import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:quarrel/services/page_controllers.dart';
import 'package:shared_preferences/shared_preferences.dart';

final CollectionReference users =
    FirebaseFirestore.instance.collection('users');
final CollectionReference requests =
    FirebaseFirestore.instance.collection('requests');

Future<List?> signInUser(
    String username, String displayName, String email, String pass) async {
  try {
    var userCredential = await FirebaseAuth.instance
        .createUserWithEmailAndPassword(email: email, password: pass);
    var userInstance = users.doc(userCredential.user?.uid);
    await userInstance.set({
      'username': username,
      'email': email,
      'display_name': displayName != '' ? displayName : username,
      'profile_picture': '',
      'status': 'Online',
      'display_status': 'Online',
      'pronouns': '',
      'about_me': '',
      'friends': []
    });
    var userData = await userInstance.get();
    return [userData.data(), userCredential];
  } on FirebaseAuthException catch (e) {
    if (e.code == 'weak-password') {
      return [false, 'Please enter a stronger password'];
    } else if (e.code == 'email-already-in-use') {
      return [false, 'Email already in use'];
    } else {
      print("An error occurred: ${e.message}");
      return [
        false,
        'An error occurred while registering your user, Pls try again later'
      ];
    }
  } catch (e) {
    print("An error occurred: $e");
    return [false, 'An unknown error occurred, Pls try again later'];
  }
}

Future<List?> logInUser(String email, String pass) async {
  try {
    var userCredential = await FirebaseAuth.instance
        .signInWithEmailAndPassword(email: email, password: pass);
    var userInstance = users.doc(userCredential.user?.uid);
    userInstance.update({'status': 'Online'});
    var userData = await userInstance.get();
    return [userData.data(), userCredential];
  } on FirebaseAuthException catch (e) {
    if (e.code == 'user-not-found') {
      print("Email not found. Please check and try again.");
      return [false, 'No account registered with provided email'];
    } else {
      print("An error occurred: ${e.message}");
      return [false, 'An error occurred while logging in, Pls try again later'];
    }
  } catch (e) {
    print("An error occurred: $e");
    return [false, 'An unknown error occurred, Pls try again later'];
  }
}

saveUserOnDevice(email, pass) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString('email', email);
  await prefs.setString('password', pass);
}

autoLogin() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  var email = prefs.getString('email');
  var pass = prefs.getString('password');
  if (email != null && pass != null) {
    try {
      var userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: pass);
      var userInstance = users.doc(userCredential.user?.uid);
      userInstance.update({'status': 'Online'});
      var userData = await userInstance.get();
      return [true, userData.data(), userCredential];
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        print("Email not found. Please check and try again.");
        return [false, 'No account registered with provided email'];
      } else {
        print("An error occurred: ${e.message}");
        return [
          false,
          'An error occurred while logging in, Pls try again later'
        ];
      }
    } catch (e) {
      print("An error occurred: $e");
      return [false, 'An unknown error occurred, Pls try again later'];
    }
  } else {
    return [false, 'No login data found'];
  }
}

profileListener(currentUserId) {
  MainController mainController = Get.find<MainController>();
  FirebaseFirestore.instance
      .collection('users')
      .doc(currentUserId)
      .snapshots()
      .listen((event) {
    var userData = event.data();
    userData?['id'] = event.id;
    mainController.updateCurrentUserData(userData);
  });
}

updateProfile(currentUserId, displayName, pronounce, aboutMe, image) {
  var updateData = {
    'display_name': displayName,
    'pronounce': pronounce,
    'about_me': aboutMe
  };
  if (image != null) {
    var storageRef = FirebaseStorage.instance.ref().child(
        'profile_pictures/$currentUserId-${DateTime.now().millisecondsSinceEpoch}.jpg');
    var task = storageRef.putFile(File(image.path));
    task.whenComplete(() async {
      var downloadUrl = await task.snapshot.ref.getDownloadURL();
      updateData['profile_picture'] = downloadUrl;
      users.doc(currentUserId).update(updateData);
    }).catchError((error) {
      print('Image Upload failed: $error');
      users.doc(currentUserId).update(updateData);
      return error;
    });
  } else {
    users.doc(currentUserId).update(updateData);
  }
}

updateStatusDisplay(userId, displayStatus) async {
  try {
    await users.doc(userId).update({'display_status': displayStatus});
    return true;
  } catch (e) {
    return false;
  }
}

getInitialFriends(currentUserId) async {
  var friendInstances = await FirebaseFirestore.instance
      .collection('users')
      .orderBy('display_name')
      .where('friends', arrayContains: currentUserId)
      .get();
  var friends = [];
  for (var doc in friendInstances.docs) {
    Map friendUserData = doc.data();
    friendUserData['id'] = doc.id;
    friends.add(friendUserData);
  }
  return friends;
}

friendsListener(currentUserId) async {
  FriendsController friendsController = Get.find<FriendsController>();
  return FirebaseFirestore.instance
      .collection('users')
      .orderBy('display_name')
      .where('friends', arrayContains: currentUserId)
      .snapshots()
      .map((snapshot) => snapshot.docChanges)
      .listen((event) {
    for (var change in event) {
      var updateData = change.doc.data();
      updateData?['id'] = change.doc.id;
      if (change.type == DocumentChangeType.modified) {
        friendsController.updateFriends(updateData, 'modified');
      } else if (change.type == DocumentChangeType.added) {
        friendsController.updateFriends(updateData, 'added');
      } else if (change.type == DocumentChangeType.removed) {
        friendsController.updateFriends(updateData, 'removed');
      }
    }
  });
}

getUserProfile(userId) async {
  return await FirebaseFirestore.instance.collection('users').doc(userId).get();
}

removeFriend(currentUserId, friendId) {
  users.doc(currentUserId).update({
    'friends': FieldValue.arrayRemove([friendId])
  });
  users.doc(friendId).update({
    'friends': FieldValue.arrayRemove([currentUserId])
  });
}

getInitialRequest(currentUserId) async {
  var incomingInstances = await FirebaseFirestore.instance
      .collection('requests')
      .orderBy('time_stamp', descending: true)
      .where('receiver_id', isEqualTo: currentUserId)
      .get();
  var incoming = [];
  for (var doc in incomingInstances.docs) {
    var requestData = doc.data();
    requestData['id'] = doc.id;
    dynamic user = await users.doc(doc['sender_id']).get();
    if (user.data() != null) {
      var temp = user.data();
      temp['id'] = user.id;
      requestData['user'] = temp;
    }
    incoming.add(requestData);
  }
  var outgoingInstances = await FirebaseFirestore.instance
      .collection('requests')
      .orderBy('time_stamp', descending: true)
      .where('sender_id', isEqualTo: currentUserId)
      .get();
  var outgoing = [];
  for (var doc in outgoingInstances.docs) {
    var requestData = doc.data();
    requestData['id'] = doc.id;
    dynamic user = await users.doc(doc['receiver_id']).get();
    if (user.data() != null) {
      var temp = user.data();
      temp['id'] = user.id;
      requestData['user'] = temp;
    }
    outgoing.add(requestData);
  }
  return [incoming, outgoing];
}

requestsListeners(currentUserId) {
  RequestsController requestsController = Get.find<RequestsController>();
  FirebaseFirestore.instance
      .collection('requests')
      .orderBy('time_stamp', descending: true)
      .where('receiver_id', isEqualTo: currentUserId)
      .snapshots()
      .map((snapshot) => snapshot.docChanges)
      .listen((event) async {
    for (var change in event) {
      var requestData = change.doc.data();
      requestData?['id'] = change.doc.id;
      if (change.type == DocumentChangeType.added) {
        dynamic user = await users.doc(requestData?['sender_id']).get();
        if (user.data() != null) {
          var temp = user.data();
          temp['id'] = user.id;
          requestData?['user'] = temp;
        }
        requestsController.updateIncomingRequests(requestData, 'added');
      } else if (change.type == DocumentChangeType.removed) {
        requestsController.updateIncomingRequests(requestData, 'removed');
      }
    }
  });
  FirebaseFirestore.instance
      .collection('requests')
      .orderBy('time_stamp', descending: true)
      .where('sender_id', isEqualTo: currentUserId)
      .snapshots()
      .map((snapshot) => snapshot.docChanges)
      .listen((event) async {
    for (var change in event) {
      var requestData = change.doc.data();
      requestData?['id'] = change.doc.id;
      if (change.type == DocumentChangeType.added) {
        dynamic user = await users.doc(requestData?['receiver_id']).get();
        if (user.data() != null) {
          var temp = user.data();
          temp['id'] = user.id;
          requestData?['user'] = temp;
        }
        requestsController.updateOutgoingRequests(requestData, 'added');
      } else if (change.type == DocumentChangeType.removed) {
        requestsController.updateOutgoingRequests(requestData, 'removed');
      }
    }
  });
}

sendRequest(currentUserId, receiverName) async {
  var ref = FirebaseFirestore.instance.collection('requests');
  var receiverRef =
      await users.where('username', isEqualTo: receiverName).get();
  if (receiverRef.docs.isNotEmpty) {
    var check1 = await ref
        .where('sender_id', isEqualTo: currentUserId)
        .where('receiver_id', isEqualTo: receiverRef.docs[0].id)
        .get();
    var check2 = await ref
        .where('sender_id', isEqualTo: currentUserId)
        .where('receiver_id', isEqualTo: receiverRef.docs[0].id)
        .get();
    if (check1.docs.isEmpty && check2.docs.isEmpty) {
      ref.add({
        'sender_id': currentUserId,
        'receiver_id': receiverRef.docs[0].id,
        'time_stamp': DateTime.now(),
      });
    }
  }
}

requestAction(requestId, action) async {
  try {
    var ref = FirebaseFirestore.instance.collection('requests').doc(requestId);
    var requestData = (await ref.get()).data();
    if (action == 'accept') {
      users.doc(requestData?['receiver_id']).update({
        'friends': FieldValue.arrayUnion([requestData?['sender_id']])
      });
      users.doc(requestData?['sender_id']).update({
        'friends': FieldValue.arrayUnion([requestData?['receiver_id']])
      });
      FirebaseFirestore.instance.collection('chats').add({
        'chat_type': 'dm',
        'latest_message': '',
        'time_stamp': DateTime.now(),
        'users': [requestData?['receiver_id'], requestData?['sender_id']]
      });
      ref.delete();
    } else if (action == 'deny') {
      ref.delete();
    }
  } catch (e) {
    print('error $e');
  }
}

getInitialChats(currentUserId) async {
  var chatInstances = await FirebaseFirestore.instance
      .collection('chats')
      .orderBy('time_stamp', descending: true)
      .where('users', arrayContains: currentUserId)
      .get();
  var chats = [];
  for (var doc in chatInstances.docs) {
    Map chatData = doc.data();
    chatData['id'] = doc.id;
    chatData['users'].removeWhere((element) => element == currentUserId);
    if (chatData['chat_type'] == 'dm') {
      dynamic user = await users.doc(chatData['users'][0]).get();
      if (user.data() != null) {
        var temp = user.data();
        temp['id'] = user.id;
        chatData['receiver_data'] = temp;
      }
      chats.add(chatData);
    }
  }
  return chats;
}

chatsListener(currentUserId, updateChats) async {
  return FirebaseFirestore.instance
      .collection('chats')
      .orderBy('time_stamp', descending: true)
      .where('users', arrayContains: currentUserId)
      .snapshots()
      .map((snapshot) => snapshot.docChanges)
      .listen((event) async {
    for (var change in event) {
      var updateData = change.doc.data();
      updateData?['id'] = change.doc.id;
      if (change.type == DocumentChangeType.modified) {
        updateChats(updateData, 'modified');
      } else if (change.type == DocumentChangeType.added) {
        updateData?['users'].removeWhere((element) => element == currentUserId);
        if (updateData?['chat_type'] == 'dm') {
          dynamic user = await users.doc(updateData?['users'][0]).get();
          if (user.data() != null) {
            var temp = user.data();
            temp['id'] = user.id;
            updateData?['receiver_data'] = temp;
          }
        }
        updateChats(updateData, 'added');
      }
    }
  });
}

getInitialMessages(chatId) async {
  var messageInstances = await FirebaseFirestore.instance
      .collection('chats')
      .doc(chatId)
      .collection('messages')
      .orderBy('time_stamp', descending: true)
      .get();
  var messages = [];
  for (var message in messageInstances.docs) {
    var temp = message.data();
    temp['id'] = message.id;
    messages.add(temp);
  }
  return messages;
}

messagesListener(chatId) async {
  ChatController chatController = Get.find<ChatController>();
  FirebaseFirestore.instance
      .collection('chats')
      .doc(chatId)
      .collection('messages')
      .orderBy('time_stamp', descending: true)
      .snapshots()
      .map((snapshot) => snapshot.docChanges)
      .listen((event) async {
    for (var change in event) {
      var updateData = change.doc.data();
      updateData?['id'] = change.doc.id;
      if (change.type == DocumentChangeType.added) {
        chatController.updateMessages(updateData, 'added');
      } else if (change.type == DocumentChangeType.modified) {
        chatController.updateMessages(updateData, 'modified');
      } else if (change.type == DocumentChangeType.removed) {
        chatController.updateMessages(updateData, 'removed');
      }
    }
  });
}

sendMessage(chatId, message, clientUserId) async {
  var chatRef = FirebaseFirestore.instance.collection('chats').doc(chatId);
  var time = DateTime.now();
  chatRef.collection('messages').add({
    'sender_id': clientUserId,
    'time_stamp': time,
    'message': message,
    'edited': false,
    'attachments': []
  });
  chatRef.update({'latest_message': message, 'time_stamp': time});
}

editMessage(chatId, messageId, message) {
  FirebaseFirestore.instance
      .collection('chats')
      .doc(chatId)
      .collection('messages')
      .doc(messageId)
      .update({
    'message': message,
    'edited': true,
  });
}

deleteMessage(chatId, messageId) {
  FirebaseFirestore.instance
      .collection('chats')
      .doc(chatId)
      .collection('messages')
      .doc(messageId)
      .delete();
}
