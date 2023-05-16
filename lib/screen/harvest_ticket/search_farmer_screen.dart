import 'package:e_trace_app/base/ui/style.dart';
import 'package:e_trace_app/database_local/database_farmer.dart';
import 'package:e_trace_app/model/farmers.dart';
import 'package:flutter/material.dart';
import 'package:e_trace_app/widget/loading_widget.dart';

import 'package:e_trace_app/base/strings/constants.dart';
import 'package:fluttericon/rpg_awesome_icons.dart';

class SearchFarmerScreen extends StatefulWidget {
  @override
  _SearchFarmerScreenState createState() => _SearchFarmerScreenState();
}

class _SearchFarmerScreenState extends State<SearchFarmerScreen> {
  TextEditingController typeFarmerController = TextEditingController();
  String valFarmer;
  bool isLoading;
  ScrollController scrollController;

  List<Farmers> _searchFarmerResult = [];

  List<Farmers> _farmersDetails = [];

  @override
  void initState() {
    getFarmerList();
    super.initState();
  }

  getFarmerList() async {
    isLoading = true;
    DatabaseFarmer().getFarmerList(onSuccess, onError);
  }

  void onSuccess(Farmers farmer) {
    setState(() {
      isLoading = false;
      if(farmer.address == null) {
        farmer.address = "";
      }
      _farmersDetails.add(farmer);
    });
  }

  void onError() {
    isLoading = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Center(child: Text("Pencarian Areal"))),
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
                      controller: typeFarmerController,
                      decoration: InputDecoration(
                          hintText: SEARCH, border: InputBorder.none),
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
            isLoading
                ? loadingWidget()
                : _farmersDetails.isNotEmpty
                    ? Flexible(
                        child: Container(
                          child: _searchFarmerResult.length != 0 ||
                                  typeFarmerController.text.isNotEmpty
                              ? ListView.builder(
                                  controller: scrollController,
                                  physics: AlwaysScrollableScrollPhysics(),
                                  itemCount: _searchFarmerResult.length,
                                  itemBuilder: (context, index) => Container(
                                        margin: EdgeInsets.only(bottom: 4),
                                        child: Card(
                                          child: Container(
                                            padding: EdgeInsets.only(
                                                top: 10, bottom: 10),
                                            child: ListTile(
                                              leading: Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Icon(
                                                    RpgAwesome.palm_tree,
                                                    size: 40,
                                                    color: Colors.orange),
                                              ),
                                              title: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    _searchFarmerResult[index]
                                                        .ascendFarmerCode,
                                                    style: text14Bold,
                                                  ),
                                                  Text(
                                                      _searchFarmerResult[index]
                                                          .fullname),
                                                ],
                                              ),
                                              subtitle: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(_searchFarmerResult[index]
                                                      .address == null ? "" : _searchFarmerResult[index]
                                                      .address),
                                                  Text(_searchFarmerResult[index]
                                                      .yop == null ? "" : _searchFarmerResult[index]
                                                      .yop)
                                                ],
                                              ),
                                              trailing: OutlinedButton(
                                                  onPressed: () {
                                                    Navigator.pop(
                                                        context,
                                                        _searchFarmerResult[
                                                            index]);
                                                  },
                                                  child: Icon(Icons.add, color:Colors.white),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ))
                              : _farmersDetails.length != 0
                                  ? ListView.builder(
                                      controller: scrollController,
                                      physics: AlwaysScrollableScrollPhysics(),
                                      itemCount: _farmersDetails.length,
                                      itemBuilder: (context, index) =>
                                          Container(
                                        margin: EdgeInsets.only(bottom: 4),
                                        child: Card(
                                          child: Container(
                                            padding: EdgeInsets.only(
                                                top: 10, bottom: 10),
                                            child: ListTile(
                                              leading: Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Icon(
                                                    RpgAwesome.palm_tree,
                                                    size: 40,
                                                    color: Colors.orange),
                                              ),
                                              title: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    _farmersDetails[index]
                                                        .ascendFarmerCode,
                                                    style: text14Bold,
                                                  ),
                                                  Text(_farmersDetails[index]
                                                      .fullname),
                                                ],
                                              ),
                                              subtitle: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(_farmersDetails[index]
                                                      .address == null ? "" : _farmersDetails[index]
                                                      .address),
                                                  Text(_farmersDetails[index]
                                                      .yop == null ? "" : _farmersDetails[index]
                                                      .yop)
                                                ],
                                              ),
                                              trailing: OutlinedButton(
                                                  onPressed: () {
                                                    Navigator.pop(context,
                                                        _farmersDetails[index]);
                                                  },
                                                  child: Icon(Icons.add, color: Colors.white,),
                                                  ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    )
                                  : Flexible(
                                    child: Center( 
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(RpgAwesome.palm_tree,
                                                color: Colors.orange, size: 60),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 20.0),
                                              child: Text("Belum ada Areal"),
                                            ),
                                          ],
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
                              Icon(RpgAwesome.palm_tree,
                                  color: Colors.orange, size: 60),
                              Padding(
                                padding: const EdgeInsets.only(top: 20.0),
                                child: Text("Belum ada Areal"),
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

  onSearchTextChanged(String text) async {
    _searchFarmerResult.clear();
    if (text.isEmpty) {
      setState(() {});
      return;
    }
    _farmersDetails.forEach((farmerDetail) {
        if (farmerDetail.ascendFarmerCode
            .toLowerCase()
            .contains(text.toLowerCase()) ||
            farmerDetail.fullname.toLowerCase().contains(text.toLowerCase()) ||
            farmerDetail.address.toLowerCase().contains(text.toLowerCase()) )
          _searchFarmerResult.add(farmerDetail);
    });
    setState(() {});
  }
}
