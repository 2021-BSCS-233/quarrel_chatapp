import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quarrel/services/controllers.dart';
import 'package:quarrel/widgets/input_field.dart';
import 'package:quarrel/services/firebase_services.dart';



class Requests extends StatelessWidget {
  final MainController mainController = Get.find<MainController>();
  final RequestsController requestsController = Get.put(RequestsController());

  Requests({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Requests',
            style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xD0FFFFFF),
                fontSize: 22),
          ),
          bottom: TabBar(
            tabs: [Tab(text: 'Incoming'), Tab(text: 'Outgoing')],
            indicatorColor: Colors.transparent,
            unselectedLabelColor: Colors.grey,
            labelColor: Colors.white,
            dividerColor: Colors.transparent,
          ),
        ),
        body: FutureBuilder<Widget>(
          future: requestsData(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return snapshot.data!;
            } else if (snapshot.hasError) {
              print(snapshot.error);
              return Material(
                color: Colors.transparent,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("We could not access our services"),
                      Text("Check your connection or try again later")
                    ],
                  ),
                ),
              );
            }
            return Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }

  Future<Widget> requestsData() async {
    requestsController.initial ? await requestsController.getInitialData(mainController.currentUserData['id']) : null;
    return TabBarView(
      children: [
        Container(
          padding: EdgeInsets.only(left: 10),
          child: Obx(() => requestsController.updateI.value == requestsController.updateI.value &&
              requestsController.incomingRequestsData.isEmpty
              ? Center(
                  child: Text('You don\'t have incoming requests'),
                )
              : ListView.builder(
                  itemCount: requestsController.incomingRequestsData.length,
                  itemBuilder: (context, index) {
                    return Container(
                      margin: const EdgeInsets.only(top: 15),
                      decoration: BoxDecoration(
                        color: Color(0xFF121218),
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      ),
                      child: ListTile(
                        dense: true,
                        leading: CircleAvatar(
                          backgroundImage: requestsController.incomingRequestsData[index]['user']
                                      ['profile_picture'] !=
                                  ''
                              ? CachedNetworkImageProvider(
                              requestsController.incomingRequestsData[index]['user']
                                      ['profile_picture'])
                              : const AssetImage('assets/images/default.png')
                                  as ImageProvider,
                          radius: 17,
                          backgroundColor: Color(0x20F2F2F2),
                        ),
                        title: Text(
                          requestsController.incomingRequestsData[index]['user']['display_name'],
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        subtitle: Text(
                            requestsController.incomingRequestsData[index]['user']['username']),
                        trailing: Container(
                          width: 100,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              InkWell(
                                child: const SizedBox(
                                    width: 35,
                                    height: 40,
                                    child: Icon(
                                      Icons.check,
                                      color: Colors.green,
                                    )),
                                onTap: () async {
                                  await requestAction(
                                      requestsController.incomingRequestsData[index]['id'],
                                      'accept');
                                },
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              InkWell(
                                child: Container(
                                    width: 35,
                                    height: 40,
                                    child: Icon(
                                      Icons.close,
                                      color: Colors.red,
                                    )),
                                onTap: () {
                                  requestAction(
                                      requestsController.incomingRequestsData[index]['id'],
                                      'deny');
                                },
                              )
                            ],
                          ),
                        ),
                      ),
                    );
                  })),
        ),
        Container(
          padding: EdgeInsets.only(left: 10),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: InputField(
                      fieldLabel: 'Add Friend',
                      controller: requestsController.requestsFieldController,
                      prefixIcon: CupertinoIcons.person_add,
                      onChange: requestsController.changing,
                      contentTopPadding: 10,
                    ),
                  ),
                  Obx(() => Visibility(
                        visible: requestsController.fieldCheck.value,
                        child: Container(
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.blueAccent.shade700),
                          width: 40,
                          height: 40,
                          child: TextButton(
                            onPressed: () {
                              requestsController.fieldCheck.value = false;
                              sendRequest(mainController.currentUserData['id'],
                                  requestsController.requestsFieldController.text.trim());
                              requestsController.requestsFieldController.text = '';
                            },
                            style: ButtonStyle(
                              padding: MaterialStateProperty.all<EdgeInsets>(
                                const EdgeInsets.all(0),
                              ),
                            ),
                            child: const Icon(
                              Icons.send,
                              size: 25,
                            ),
                          ),
                        ),
                      ))
                ],
              ),
              Obx(() => Expanded(
                    child: requestsController.updateO.value == requestsController.updateO.value &&
                        requestsController.outgoingRequestsData.isEmpty
                        ? Center(
                            child: Text('You haven\'t sent any requests'),
                          )
                        : ListView.builder(
                            itemCount: requestsController.outgoingRequestsData.length,
                            shrinkWrap: true,
                            itemBuilder: (context, index) {
                              return Container(
                                margin: const EdgeInsets.only(top: 15),
                                decoration: BoxDecoration(
                                  color: Color(0xFF121218),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(20)),
                                ),
                                child: ListTile(
                                  dense: true,
                                  leading: CircleAvatar(
                                    backgroundImage: requestsController.outgoingRequestsData[index]
                                                ['user']['profile_picture'] !=
                                            ''
                                        ? CachedNetworkImageProvider(
                                        requestsController.outgoingRequestsData[index]['user']
                                                ['profile_picture'])
                                        : const AssetImage(
                                                'assets/images/default.png')
                                            as ImageProvider,
                                    radius: 17,
                                    backgroundColor: Color(0x20F2F2F2),
                                  ),
                                  title: Text(
                                    requestsController.outgoingRequestsData[index]['user']
                                        ['display_name'],
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16),
                                  ),
                                  subtitle: Text(requestsController.outgoingRequestsData[index]
                                      ['user']['username']),
                                  trailing: InkWell(
                                    child: Container(
                                        width: 40,
                                        height: 40,
                                        child: Icon(
                                          Icons.close,
                                          color: Colors.red,
                                        )),
                                    onTap: () {
                                      requestAction(
                                          requestsController.outgoingRequestsData[index]['id'],
                                          'deny');
                                    },
                                  ),
                                ),
                              );
                            }),
                  )),
            ],
          ),
        ),
      ],
    );
  }
}
