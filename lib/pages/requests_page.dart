import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quarrel/widgets/input_field.dart';
import 'package:quarrel/services/firebase_services.dart';

var updateI = 0.obs;
var updateO = 0.obs;
var initial = true;
List incomingRequestsData = [];
List outgoingRequestsData = [];
var fieldCheck = false.obs;
TextEditingController requestController = TextEditingController();

void changing() {
  fieldCheck.value = (requestController.text != '' ? true : false);
}

class Requests extends StatelessWidget {
  final Map currentUserData;

  Requests({required this.currentUserData});

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
    initial ? await getInitialData(currentUserData['id']) : null;
    return TabBarView(
      children: [
        Container(
          padding: EdgeInsets.only(left: 10),
          child: Obx(() => updateI.value == updateI.value &&
                  incomingRequestsData.isEmpty
              ? Center(
                  child: Text('You don\'t have incoming requests'),
                )
              : ListView.builder(
                  itemCount: incomingRequestsData.length,
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
                          backgroundImage: incomingRequestsData[index]['user']
                                      ['profile_picture'] !=
                                  ''
                              ? CachedNetworkImageProvider(
                                  incomingRequestsData[index]['user']
                                      ['profile_picture'])
                              : const AssetImage('assets/images/default.png')
                                  as ImageProvider,
                          radius: 17,
                          backgroundColor: Color(0x20F2F2F2),
                        ),
                        title: Text(
                          incomingRequestsData[index]['user']['display_name'],
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        subtitle: Text(
                            incomingRequestsData[index]['user']['username']),
                        trailing: Container(
                          width: 100,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              InkWell(
                                child: const SizedBox(
                                    width: 35,
                                    height: 40,
                                    child: Icon(Icons.check, color: Colors.green,)),
                                onTap: () async {
                                  await requestAction(
                                      incomingRequestsData[index]['id'],
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
                                    child: Icon(Icons.close, color: Colors.red,)),
                                onTap: () {
                                  requestAction(
                                      incomingRequestsData[index]['id'],
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
                      controller: requestController,
                      prefixIcon: CupertinoIcons.person_add,
                      onChange: changing,
                      contentTopPadding: 10,
                    ),
                  ),
                  Obx(() => Visibility(
                        visible: fieldCheck.value,
                        child: Container(
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.blueAccent.shade700),
                          width: 40,
                          height: 40,
                          child: TextButton(
                            onPressed: () {
                              fieldCheck.value = false;
                              sendRequest(currentUserData['id'],
                                  requestController.text.trim());
                              requestController.text = '';
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
                    child: updateO.value == updateO.value &&
                            outgoingRequestsData.isEmpty
                        ? Center(
                            child: Text('You haven\'t sent any requests'),
                          )
                        : ListView.builder(
                            itemCount: outgoingRequestsData.length,
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
                                    backgroundImage: outgoingRequestsData[index]
                                                ['user']['profile_picture'] !=
                                            ''
                                        ? CachedNetworkImageProvider(
                                            outgoingRequestsData[index]['user']
                                                ['profile_picture'])
                                        : const AssetImage(
                                                'assets/images/default.png')
                                            as ImageProvider,
                                    radius: 17,
                                    backgroundColor: Color(0x20F2F2F2),
                                  ),
                                  title: Text(
                                    outgoingRequestsData[index]['user']
                                        ['display_name'],
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16),
                                  ),
                                  subtitle: Text(outgoingRequestsData[index]
                                      ['user']['username']),
                                  trailing: InkWell(
                                    child: Container(
                                        width: 40,
                                        height: 40,
                                        child: Icon(Icons.close, color: Colors.red,)),
                                    onTap: () {
                                      requestAction(
                                          outgoingRequestsData[index]['id'],
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
  if(updateType == 'added' && index < 0){
    incomingRequestsData.insert(0, updateData);
  } else if(updateType == 'removed'){
    incomingRequestsData.removeAt(index);
  }
  updateI.value += 1;
}

updateOutgoingRequests(updateData, updateType) {
  var index =
      outgoingRequestsData.indexWhere((map) => map['id'] == updateData['id']);
  if(updateType == 'added' && index < 0){
    outgoingRequestsData.insert(0, updateData);
  } else if(updateType == 'removed'){
    outgoingRequestsData.removeAt(index);
  }
  updateO.value += 1;
}
