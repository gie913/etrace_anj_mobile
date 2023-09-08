import 'dart:developer';

import 'package:e_trace_app/base/strings/constants.dart';
import 'package:e_trace_app/database_local/database_farmer.dart';
import 'package:e_trace_app/model/farmers.dart';
import 'package:e_trace_app/widget/loading_widget.dart';
import 'package:flutter/material.dart';
import 'package:fluttericon/rpg_awesome_icons.dart';

class SearchFarmerDusunScreen extends StatefulWidget {
  const SearchFarmerDusunScreen({Key key, this.kecamatan}) : super(key: key);

  final String kecamatan;

  @override
  State<SearchFarmerDusunScreen> createState() =>
      _SearchFarmerDusunScreenState();
}

class _SearchFarmerDusunScreenState extends State<SearchFarmerDusunScreen> {
  final controller = TextEditingController();

  List<String> listDusun = [];
  List<String> listDusunSearch = [];
  String selectedDusun = '';

  bool isLoading = false;

  @override
  void initState() {
    getDataDusunFarmer();
    super.initState();
  }

  Future<void> getDataDusunFarmer() async {
    setState(() => isLoading = true);

    final r = await DatabaseFarmer().selectFarmer();
    var farmerByKecamatan = <Farmers>[];

    for (final item in r) {
      if (item['subdistrict']
              .toString()
              .trim()
              .replaceAll(RegExp(r'\s+'), ' ') ==
          widget.kecamatan) {
        farmerByKecamatan.add(Farmers.fromJson(item));
      }
    }

    for (final item in farmerByKecamatan) {
      if (!listDusun.contains(item.address)) {
        listDusun.add(item.address);
      }
    }

    listDusunSearch = listDusun;

    await Future.delayed(const Duration(seconds: 1));

    setState(() => isLoading = false);

    log('cek dusun : $listDusun');
  }

  onSearchTextChanged(String text) async {
    setState(() {
      final listDusunSearchTemp = <String>[];

      if (text.isEmpty) {
        listDusunSearch = listDusun;
      }

      for (var i = 0; i < listDusun.length; i++) {
        if (listDusun[i].toLowerCase().contains(text.toLowerCase())) {
          listDusunSearchTemp.add(listDusun[i]);
        }
      }

      listDusunSearch = listDusunSearchTemp;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Center(child: Text("Pencarian Dusun"))),
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
                      controller: controller,
                      decoration: InputDecoration(
                          hintText: SEARCH, border: InputBorder.none),
                      onChanged: onSearchTextChanged,
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.cancel),
                      onPressed: () {
                        controller.clear();
                        onSearchTextChanged('');
                      },
                    ),
                  ),
                ),
              ),
            ),
            isLoading
                ? loadingWidget()
                : listDusunSearch.isNotEmpty
                    ? Expanded(
                        child: ListView.builder(
                          itemCount: listDusunSearch.length,
                          itemBuilder: (context, index) {
                            return InkWell(
                              onTap: () {
                                Navigator.pop(context, listDusunSearch[index]);
                              },
                              child: Card(
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Text(listDusunSearch[index]),
                                ),
                                margin: EdgeInsets.fromLTRB(12, 0, 12, 12),
                              ),
                            );
                          },
                        ),
                      )
                    : Expanded(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(RpgAwesome.palm_tree,
                                  color: Colors.orange, size: 60),
                              Padding(
                                padding: const EdgeInsets.only(top: 20.0),
                                child: Text("Tidak ada Data Dusun"),
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
