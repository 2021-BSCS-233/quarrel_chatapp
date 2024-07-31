import 'package:cached_network_image/cached_network_image.dart';
import 'package:quarrel/widgets/status_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quarrel/pages/chat_page.dart';

class DmChatTile extends StatelessWidget {
  final Map currentUserData;
  final Map chatData;
  final Function logPressMenu;

  DmChatTile(
      {super.key,
      required this.logPressMenu,
      required this.chatData,
      required this.currentUserData});

  @override
  Widget build(BuildContext context) {
    var time1 = chatData['time_stamp'].toDate();
    var time2 = DateTime.now();
    var difference = time2.difference(time1);
    String timeDifference = '';
    if (difference.inMinutes < 1) {
      timeDifference = '<1m';
    } else if (difference.inHours < 1) {
      timeDifference = '${difference.inMinutes}m';
    } else if (difference.inDays < 1) {
      timeDifference = '${difference.inHours}h';
    } else if (difference.inDays < 30) {
      timeDifference = '${difference.inDays}d';
    } else if (difference.inDays < 365) {
      timeDifference = '${(difference.inDays / 30).floor()}mo';
    } else {
      timeDifference = '${(difference.inDays / 365).floor()}yr';
    }
    return Container(
      margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      child: ListTile(
        titleAlignment: ListTileTitleAlignment.top,
        onTap: () {
          Get.to(Chat(
            chatId: chatData['id'],
            otherUsersData: [chatData['receiver_data']],
            currentUserData: currentUserData,
            chatType: chatData['chat_type'],
          ));
        },
        onLongPress: () {
          print('Long Press');
          logPressMenu([
            chatData['id'],
            chatData['receiver_data']['username'] == null
                ? ''
                : chatData['receiver_data']['username'],
            chatData['receiver_data']['profile_picture'],
            chatData['chat_type']
          ]);
        },
        dense: true,
        contentPadding: EdgeInsets.zero,
        leading: Stack(
          children: [
            CircleAvatar(
              backgroundImage: chatData['receiver_data']['profile_picture'] !=
                      ''
                  ? CachedNetworkImageProvider(
                      chatData['receiver_data']['profile_picture'])
                  : AssetImage('assets/images/default.png') as ImageProvider,
              radius: 20,
              backgroundColor: Colors.grey.shade900,
            ),
            Positioned(
              bottom: -1,
              right: -1,
              child: StatusIcon(
                icon_type: chatData['receiver_data']['status'] == 'Online'
                    ? chatData['receiver_data']['display_status']
                    : chatData['receiver_data']['status'],
              ),
            ),
          ],
        ),
        title: Text(
          chatData['receiver_data']['display_name'],
          style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xD0FFFFFF)),
        ),
        subtitle: Text(
          chatData['latest_message'],
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
          style: TextStyle(fontSize: 14, color: Color(0xB0FFFFFF)),
        ),
        trailing: Text(timeDifference),
      ),
    );
  }
}
