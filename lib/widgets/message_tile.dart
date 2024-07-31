import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

class MessageTileFull extends StatelessWidget {
  final Map messageData;
  final Map sendingUser;
  final Function toggleMenu;
  final Function toggleProfile;

  MessageTileFull(
      {super.key, required this.messageData,
      required this.sendingUser,
      required this.toggleMenu,
      required this.toggleProfile});

  @override
  Widget build(BuildContext context) {
    var time = messageData['time_stamp'].toDate();
    var timeNow = DateTime.now();
    var formattedDateTime = '';
    if (timeNow.year == time.year &&
        timeNow.month == time.month &&
        timeNow.day == time.day) {
      DateFormat formatter = DateFormat('HH:mm a');
      formattedDateTime = 'Today at ${formatter.format(time)}';
    } else {
      DateFormat formatter = DateFormat('HH:mm a dd/MM/yyyy');
      formattedDateTime = formatter.format(time);
    }

    return Container(
      margin: EdgeInsets.only(left: 18, top: 16, right: 18, bottom: 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          InkWell(
            onTap: () {
              toggleProfile();
              print('profile');
            },
            child: CircleAvatar(
              backgroundImage: sendingUser['profile_picture'] != ''
                  ? CachedNetworkImageProvider(sendingUser['profile_picture'])
                  : AssetImage('assets/images/default.png') as ImageProvider,
              radius: 20,
              backgroundColor: Color(0x20F2F2F2),
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            child: InkWell(
              onLongPress: () {
                toggleMenu();
              },
              splashColor: Colors.black,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      InkWell(
                        onTap: () {
                          print('name');
                        },
                        child: Text(
                          sendingUser['display_name'],
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFFEEEEEE)),
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Text(
                        formattedDateTime,
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                  RichText(
                    text: TextSpan(
                      text: messageData['message'],
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFFDEDEE2)),
                      children: messageData['edited']
                          ? [
                              TextSpan(
                                  text: ' (edited)',
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade500)),
                            ]
                          : null,
                    ),
                  )
                  // Text(
                  //   messageData['message'],
                  //   style: TextStyle(
                  //     fontSize: 15,
                  //   ),
                  // )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

class MessageTileCompact extends StatelessWidget {
  final Map messageData;
  final Map sendingUser;
  final Function toggleMenu;

  MessageTileCompact(
      {super.key, required this.messageData,
      required this.toggleMenu,
      required this.sendingUser});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: 20, right: 20, top: 0, bottom: 1),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Container(
            alignment: Alignment.centerRight,
            height: 15,
            width: 40,
          ),
          SizedBox(
            width: 8,
          ),
          Expanded(
            child: InkWell(
              onLongPress: () {
                toggleMenu();
              },
              // enableFeedback: false,
              splashColor: Colors.black,
              child: RichText(
                text: TextSpan(
                  text: messageData['message'],
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFFDEDEE2)),
                  children: messageData['edited']
                      ? [
                          TextSpan(
                              text: ' (edited)',
                              style: TextStyle(
                                  fontSize: 12, color: Colors.grey.shade400)),
                        ]
                      : null,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

//old formats
// return ListTile(
//   onLongPress: () {
//     print('working');
//     toggleMenu();
//   },
//   titleAlignment: ListTileTitleAlignment.top,
//   leading: InkWell(
//     onTap: () {
//       toggleProfile();
//       print('profile');
//     },
//     child: CircleAvatar(
//       backgroundImage: AssetImage(profile_pic),
//       radius: 21,
//       backgroundColor: Colors.transparent,
//     ),
//   ),
//   title: Row(
//     children: [
//       InkWell(
//         onTap: () {
//           print('name');
//         },
//         child: Text(
//           display,
//           style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
//         ),
//       ),
//       SizedBox(
//         width: 10,
//       ),
//       Text(
//         chat_time,
//         style: TextStyle(fontSize: 12, color: Colors.grey),
//       ),
//     ],
//   ),
//   subtitle: Text(chat_message,style: TextStyle(color: color),),
// );

// return Padding(
//   padding: EdgeInsets.symmetric(vertical: 0),
//   child: ListTile(
//     onLongPress: () {
//       print('working');
//       toggleMenu();
//     },
//     visualDensity: VisualDensity.compact,
//     dense: true,
//     titleAlignment: ListTileTitleAlignment.center,
//     contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 20),
//     leading: Container(height: 1, width: 40, color: Colors.red,),
//     title: Text(chat_message,style: TextStyle(color: color, fontSize: 14,),),
//   ),
// );
