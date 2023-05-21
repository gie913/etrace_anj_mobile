import 'package:e_trace_app/base/strings/constants.dart';
import 'package:e_trace_app/base/ui/style.dart';
import 'package:e_trace_app/database_local/database_supplier.dart';
import 'package:e_trace_app/model/suppliers.dart';
import 'package:e_trace_app/widget/loading_widget.dart';
import 'package:flutter/material.dart';
import 'package:fluttericon/font_awesome5_icons.dart';

class SearchSupplierScreen extends StatefulWidget {
  @override
  _SearchSupplierScreenState createState() => _SearchSupplierScreenState();
}

class _SearchSupplierScreenState extends State<SearchSupplierScreen> {
  TextEditingController typeSupplierController = TextEditingController();
  String? valSupplier;
  ScrollController? scrollController;
  List<Suppliers> _searchSupplierResult = [];
  List<Suppliers> _supplierDetails = [];
  bool? isLoading;

  @override
  void initState() {
    getSupplierList();
    super.initState();
  }

  getSupplierList() async {
    isLoading = true;
    DatabaseSupplier().getSupplierList(onSuccess, onError);
  }

  void onSuccess(Suppliers supplier) {
    isLoading = false;
    setState(() {
      _supplierDetails.add(supplier);
    });
  }

  void onError() {
    isLoading = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Center(child: Text("Pencarian Supplier"))),
      body: Container(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(8.0),
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
            isLoading!
                ? loadingWidget()
                : _supplierDetails.isNotEmpty
                    ? Flexible(
                        child: Container(
                          child: _searchSupplierResult.length != 0 ||
                                  typeSupplierController.text.isNotEmpty
                              ? ListView.builder(
                                  controller: scrollController,
                                  physics: AlwaysScrollableScrollPhysics(),
                                  itemCount: _searchSupplierResult.length,
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
                                            Text(
                                              _searchSupplierResult[index]
                                                  .ascendSupplierCode
                                                  .toString(),
                                              style: text14Bold,
                                            ),
                                            Text(
                                              _searchSupplierResult[index]
                                                  .name!,
                                              style: text14,
                                            ),
                                          ],
                                        ),
                                        subtitle: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(_searchSupplierResult[index]
                                                .address!),
                                          ],
                                        ),
                                        trailing: OutlinedButton(
                                          onPressed: () async {
                                            Navigator.pop(context,
                                                _searchSupplierResult[index]);
                                          },
                                          child: Icon(
                                            Icons.add,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                              : _supplierDetails.length != 0
                                  ? ListView.builder(
                                      controller: scrollController,
                                      physics: AlwaysScrollableScrollPhysics(),
                                      itemCount: _supplierDetails.length,
                                      itemBuilder: (context, index) => Card(
                                        child: Container(
                                          padding: EdgeInsets.only(
                                              top: 8.0, bottom: 8.0),
                                          child: ListTile(
                                            leading: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
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
                                                Text(
                                                  _supplierDetails[index]
                                                      .ascendSupplierCode
                                                      .toString(),
                                                  style: text14Bold,
                                                ),
                                                Text(
                                                  _supplierDetails[index].name!,
                                                  style: text14,
                                                ),
                                              ],
                                            ),
                                            subtitle: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(_supplierDetails[index]
                                                    .address!),
                                              ],
                                            ),
                                            trailing: OutlinedButton(
                                              onPressed: () {
                                                Navigator.pop(context,
                                                    _supplierDetails[index]);
                                              },
                                              child: Icon(
                                                Icons.add,
                                                color: Colors.white,
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
                      )
                    : Flexible(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                FontAwesome5.user_tag,
                                color: Colors.blue,
                                size: 60,
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 20.0),
                                child: Text("Supplier Belum Ada"),
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
    _searchSupplierResult.clear();
    if (text.isEmpty) {
      setState(() {});
      return;
    }
    _supplierDetails.forEach((supplierDetail) {
      if (supplierDetail.name!.toLowerCase().contains(text.toLowerCase()) ||
          supplierDetail.ascendSupplierCode!
              .toLowerCase()
              .contains(text.toLowerCase()))
        _searchSupplierResult.add(supplierDetail);
    });
    setState(() {});
  }
}
