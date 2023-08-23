import 'dart:developer';

import 'package:e_trace_app/base/strings/constants.dart';
import 'package:e_trace_app/database_local/database_farmer.dart';
import 'package:e_trace_app/widget/loading_widget.dart';
import 'package:flutter/material.dart';
import 'package:fluttericon/rpg_awesome_icons.dart';

class SearchFarmerKecamatanScreen extends StatefulWidget {
  const SearchFarmerKecamatanScreen({Key key}) : super(key: key);

  @override
  State<SearchFarmerKecamatanScreen> createState() =>
      _SearchFarmerKecamatanScreenState();
}

class _SearchFarmerKecamatanScreenState
    extends State<SearchFarmerKecamatanScreen> {
  final controller = TextEditingController();

  List<String> listKecamatan = [];
  List<String> listKecamatanSearch = [];
  String selectedDusun = '';

  bool isLoading = false;

  @override
  void initState() {
    getDataKecamatan();
    super.initState();
  }

  Future<void> getDataKecamatan() async {
    setState(() => isLoading = true);

    final r = await DatabaseFarmer().selectFarmer();

    for (final item in r) {
      if (!listKecamatan.contains(item['subdistrict']) &&
          item['subdistrict'] != null) {
        listKecamatan.add(item['subdistrict']);
      }
    }

    listKecamatan.add('lainnya');

    listKecamatanSearch = listKecamatan;

    await Future.delayed(const Duration(seconds: 1));

    setState(() => isLoading = false);

    log('cek kecamatan : $listKecamatan');
  }

  onSearchTextChanged(String text) async {
    setState(() {
      final listKecamatanSearchTemp = <String>[];

      if (text.isEmpty) {
        listKecamatanSearch = listKecamatan;
      }

      for (var i = 0; i < listKecamatan.length; i++) {
        if (listKecamatan[i].toLowerCase().contains(text.toLowerCase())) {
          listKecamatanSearchTemp.add(listKecamatan[i]);
        }
      }

      listKecamatanSearch = listKecamatanSearchTemp;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Center(child: Text("Pencarian Kecamatan"))),
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
                : listKecamatanSearch.isNotEmpty
                    ? Expanded(
                        child: ListView.builder(
                          itemCount: listKecamatanSearch.length,
                          itemBuilder: (context, index) {
                            return InkWell(
                              onTap: () {
                                Navigator.pop(
                                    context, listKecamatanSearch[index]);
                              },
                              child: Card(
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Text(listKecamatanSearch[index]),
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
                                child: Text("Tidak ada Data Kecamatan"),
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
