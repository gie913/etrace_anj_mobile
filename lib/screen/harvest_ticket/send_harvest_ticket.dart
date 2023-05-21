import 'package:e_trace_app/base/api/api_endpoint.dart';
import 'package:e_trace_app/model/user.dart';
import 'package:e_trace_app/screen/harvest_ticket/target_user_repository.dart';
import 'package:flutter/material.dart';
import 'package:fluttericon/font_awesome5_icons.dart';

class SendHarvestTicket extends StatefulWidget {
  @override
  _SendHarvestTicketState createState() => _SendHarvestTicketState();
}

class _SendHarvestTicketState extends State<SendHarvestTicket> {
  TextEditingController typeFarmerController = TextEditingController();
  String? valFarmer;
  ScrollController? scrollController;

  List<User> _searchTargetUserResult = [];

  List<User> _targetUserList = [];

  @override
  void initState() {
    getFarmerList();
    super.initState();
  }

  getFarmerList() async {
    TargetUserRepository(APIEndpoint.BASE_URL)
        .doGetTargetUser(onSuccess, onError);
  }

  void onSuccess(List<User> dataUser) {
    setState(() {
      _targetUserList = dataUser;
    });
  }

  void onError() {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Center(child: Text("Pencarian Pengguna Tujuan"))),
      body: Container(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                child: Card(
                  child: ListTile(
                    leading: Icon(Icons.search),
                    title: TextField(
                      controller: typeFarmerController,
                      decoration: InputDecoration(
                          hintText: 'Search', border: InputBorder.none),
                      onChanged: onSearchTextChanged,
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.cancel),
                      onPressed: () {
                        typeFarmerController.clear();
                        onSearchTextChanged('');
                      },
                    ),
                  ),
                ),
              ),
            ),
            Flexible(
              child: Container(
                child: _searchTargetUserResult.length != 0 ||
                        typeFarmerController.text.isNotEmpty
                    ? ListView.builder(
                        controller: scrollController,
                        physics: AlwaysScrollableScrollPhysics(),
                        itemCount: _searchTargetUserResult.length,
                        itemBuilder: (context, index) => Container(
                          margin: EdgeInsets.only(bottom: 4),
                          child: Card(
                            child: Container(
                              padding: EdgeInsets.only(top: 10, bottom: 10),
                              child: ListTile(
                                leading: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Icon(
                                    FontAwesome5.user_alt,
                                    color: Colors.orange,
                                  ),
                                ),
                                title: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(_searchTargetUserResult[index].name!),
                                    Text(
                                        _searchTargetUserResult[index]
                                            .companyName!,
                                        overflow: TextOverflow.ellipsis),
                                  ],
                                ),
                                subtitle: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(_searchTargetUserResult[index]
                                        .address!),
                                    Text(_searchTargetUserResult[index]
                                        .gender
                                        .toString())
                                  ],
                                ),
                                trailing: OutlinedButton(
                                  onPressed: () {
                                    Navigator.pop(context,
                                        _searchTargetUserResult[index]);
                                  },
                                  child: Icon(Icons.add, color: Colors.white),
                                ),
                              ),
                            ),
                          ),
                        ),
                      )
                    : _targetUserList.length != 0
                        ? ListView.builder(
                            controller: scrollController,
                            physics: AlwaysScrollableScrollPhysics(),
                            itemCount: _targetUserList.length,
                            itemBuilder: (context, index) => Container(
                              margin: EdgeInsets.only(bottom: 4),
                              child: Card(
                                child: Container(
                                  padding: EdgeInsets.only(top: 10, bottom: 10),
                                  child: ListTile(
                                    leading: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Icon(FontAwesome5.user_alt,
                                          color: Colors.orange),
                                    ),
                                    title: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text("${_targetUserList[index].name}"),
                                        Text(
                                            "${_targetUserList[index].companyName}",
                                            overflow: TextOverflow.ellipsis),
                                      ],
                                    ),
                                    subtitle: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                            "${_targetUserList[index].address}"),
                                        Text(
                                            "${_targetUserList[index].gender.toString()}")
                                      ],
                                    ),
                                    trailing: OutlinedButton(
                                      onPressed: () {
                                        Navigator.pop(
                                            context, _targetUserList[index]);
                                      },
                                      child: Icon(
                                        Icons.add,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          )
                        : Center(
                            child: SizedBox(
                              height: 30.0,
                              width: 30.0,
                              child: CircularProgressIndicator(
                                value: null,
                                strokeWidth: 3.0,
                              ),
                            ),
                          ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  onSearchTextChanged(String text) async {
    _searchTargetUserResult.clear();
    if (text.isEmpty) {
      setState(() {});
      return;
    }
    _targetUserList.forEach((userDetail) {
      if (userDetail.name!.toLowerCase().contains(text.toLowerCase()) ||
          userDetail.username!.contains(text.toLowerCase()))
        _searchTargetUserResult.add(userDetail);
    });
    setState(() {});
  }
}
