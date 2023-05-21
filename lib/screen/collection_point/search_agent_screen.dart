import 'package:e_trace_app/base/strings/constants.dart';
import 'package:e_trace_app/database_local/database_agent.dart';
import 'package:e_trace_app/model/agents.dart';
import 'package:flutter/material.dart';
import 'package:fluttericon/font_awesome5_icons.dart';

class SearchAgentScreen extends StatefulWidget {
  @override
  _SearchAgentScreenState createState() => _SearchAgentScreenState();
}

class _SearchAgentScreenState extends State<SearchAgentScreen> {
  TextEditingController typeSupplierController = TextEditingController();
  ScrollController? scrollController;
  List<Agents> _searchAgentsResult = [];
  List<Agents> _listAgentDetails = [];

  @override
  void initState() {
    getAgentList();
    super.initState();
  }

  getAgentList() {
    DatabaseAgent dbAgents = DatabaseAgent();
    dbAgents.getAgentList().then((value) => _listAgentDetails = value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Center(child: Text(TITLE_SEARCH_AGENT))),
      body: Container(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Card(
                child: Container(
                  child: ListTile(
                    leading: Icon(Icons.search),
                    title: TextField(
                      controller: typeSupplierController,
                      decoration: InputDecoration(
                          hintText: SEARCH, border: InputBorder.none),
                      onChanged: onSearchTextChanged,
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.cancel),
                      onPressed: () {
                        typeSupplierController.clear();
                        onSearchTextChanged('');
                      },
                    ),
                  ),
                ),
              ),
            ),
            _listAgentDetails.isNotEmpty
                ? Flexible(
                    child: Container(
                      child: _listAgentDetails.length != 0 ||
                              typeSupplierController.text.isNotEmpty
                          ? ListView.builder(
                              controller: scrollController,
                              physics: AlwaysScrollableScrollPhysics(),
                              itemCount: _listAgentDetails.length,
                              itemBuilder: (context, index) => Card(
                                child: Container(
                                  padding:
                                      EdgeInsets.only(top: 8.0, bottom: 8.0),
                                  child: ListTile(
                                    leading: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Icon(FontAwesome5.user_tag,
                                          color: Colors.blue),
                                    ),
                                    title: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(_listAgentDetails[index]
                                            .ascendAgentCode
                                            .toString()),
                                        Text(_listAgentDetails[index].name!),
                                      ],
                                    ),
                                    subtitle: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(_listAgentDetails[index].address!),
                                      ],
                                    ),
                                    trailing: InkWell(
                                      onTap: () async {
                                        Navigator.pop(
                                            context, _listAgentDetails[index]);
                                      },
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.only(right: 14.0),
                                        child: Icon(Icons.add),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            )
                          : _searchAgentsResult.isNotEmpty
                              ? ListView.builder(
                                  controller: scrollController,
                                  physics: AlwaysScrollableScrollPhysics(),
                                  itemCount: _searchAgentsResult.length,
                                  itemBuilder: (context, index) => Card(
                                    child: Container(
                                      padding: EdgeInsets.only(
                                          top: 8.0, bottom: 8.0),
                                      child: ListTile(
                                        leading: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Icon(
                                            FontAwesome5.user_tag,
                                            color: Colors.blue,
                                          ),
                                        ),
                                        title: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(_searchAgentsResult[index]
                                                .ascendAgentCode
                                                .toString()),
                                            Text(_searchAgentsResult[index]
                                                .name!),
                                          ],
                                        ),
                                        subtitle: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(_searchAgentsResult[index]
                                                .address!),
                                          ],
                                        ),
                                        trailing: InkWell(
                                            onTap: () async {
                                              Navigator.pop(context,
                                                  _searchAgentsResult[index]);
                                            },
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  right: 14.0),
                                              child: Icon(Icons.add),
                                            )),
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
                  )
                : Flexible(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(FontAwesome5.user_tag),
                          Padding(
                            padding: const EdgeInsets.only(top: 20.0),
                            child: Text("Agent Belum Ada"),
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

  onSearchTextChanged(String text) {
    _searchAgentsResult.clear();
    _listAgentDetails.forEach((supplierDetail) {
      if (supplierDetail.name!.toLowerCase().contains(text.toLowerCase()) ||
          supplierDetail.ascendAgentCode
              .toString()
              .toLowerCase()
              .contains(text.toLowerCase())) {
        setState(() {
          _searchAgentsResult.add(supplierDetail);
        });
      }
    });
  }
}
