import 'package:e_trace_app/base/ui/style.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'help_constants.dart';

class HelpScreen extends StatefulWidget {
  @override
  _HelpScreenState createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Panduan"),
      ),
      body: SingleChildScrollView(
        child: Card(
          child: Column(
            children: [
              Card(
                child: ExpandablePanel(
                  header: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "Apa itu Tiket Panen?",
                      style: text16Bold,
                    ),
                  ),
                  expanded: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      HARVESTING_TICKET_DESC, textAlign: TextAlign.justify,
                    ),
                  ),
                ),
              ),
              Card(
                child: ExpandablePanel(
                  header: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "Apa itu Titik Kumpul?",
                      style: text16Bold,
                    ),
                  ),
                  expanded: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      COLLECTION_POINT_DESC, textAlign: TextAlign.justify,
                    ),
                  ),
                ),
              ),
              Card(
                child: ExpandablePanel(
                  header: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "Apa itu Surat Pengantar TBS?",
                      style: text16Bold,
                    ),
                  ),
                  expanded: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      DELIVERY_ORDER_DESC, textAlign: TextAlign.justify,
                    ),
                  ),
                ),
              ),
              Card(
                child: ExpandablePanel(
                  header: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "Membuat Tiket Panen",
                      style: text16Bold,
                    ),
                  ),
                  expanded: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "1. Pilih menu Tiket Panen",
                        ),
                        Image.asset("assets/harvest-button.png", width: 200),
                        Text(
                          "2. Pilih tanda tambah di kanan atas halaman tiket panen",
                        ),
                        Image.asset("assets/harvest-add.png", width: 200),
                        Text(
                          "3. Isi kode areal, dengan pilih tanda plus pada form Areal",
                        ),
                        Image.asset("assets/harvest-form.png", width: 200),
                        Text(
                          "4. Masukkan nama petani/kode areal/desa dalam kolom pencarian",
                        ),
                        Text(
                          "5. Pilih tanda tambah untuk petani yang terpilih",
                        ),
                        Image.asset("assets/areal-select.png", width: 200),
                        Text(
                          "6. Masukkan jumlah janjang dan estimasi berat (opsional)",
                        ),
                        Text(
                          "7. Tekan Simpan",
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Card(
                child: ExpandablePanel(
                  header: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "Membuat Titik Kumpul",
                      style: text16Bold,
                    ),
                  ),
                  expanded: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "1. Pilih menu Titik Kumpul",
                        ),
                        Image.asset("assets/collect-button.png", width: 200),
                        Text(
                          "2. Pilih tanda tambah di kanan atas halaman titik kumpul",
                        ),
                        Text(
                          "3. Halaman form titik kumpul",
                        ),
                        Image.asset("assets/collect-form.png", width: 200),
                        Text(
                          "3. Masukkan tiket panen pada tab tiket panen",
                        ),
                        Image.asset("assets/harvest-list.png", width: 200),
                        Text(
                          "4. Pilih Tambahkan tiket panen",
                        ),
                        Text(
                          "5. Pilih metode menambahkan tiket panen",
                        ),
                        Image.asset("assets/order-dialog.png", width: 200),
                        Text(
                          "6. Setelah selesai memasukkan tiket panen",
                        ),
                        Text(
                          "7. Tekan Simpan",
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Card(
                child: ExpandablePanel(
                  header: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "Membuat Surat Pengantar TBS",
                      style: text16Bold,
                    ),
                  ),
                  expanded: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "1. Pilih menu Surat Pengantar TBS",
                        ),
                        Image.asset("assets/order-button.png", width: 200),
                        Text(
                          "2. Pilih tanda tambah di kanan atas halaman Surat Pengantar TBS",
                        ),
                        Image.asset("assets/order-add.png", width: 200),
                        Text(
                          "3. Isi supplier, dengan pilih tanda plus pada form supplier",
                        ),
                        Image.asset("assets/order-form.png", width: 200),
                        Text(
                          "4. Masukkan nama supplier/kode supplier dalam kolom pencarian",
                        ),
                        Image.asset("assets/supplier-select.png", width: 200),
                        Text(
                          "5. Pilih tanda tambah untuk supplier yang terpilih",
                        ),
                        Text(
                          "6. Masukkan nama supir",
                        ),
                        Text(
                          "6. Masukkan plat nomor kendaraan pengangkut",
                        ),
                        Text(
                          "7. Masukkan tiket panen pada tab tiket panen",
                        ),
                        Text(
                          "8. Pilih Tambahkan tiket panen/buat baru tiket panen",
                        ),
                        Text(
                          "9. Pilih metode menambahkan tiket panen",
                        ),
                        Image.asset("assets/collect-dialog.png", width: 200),
                        Text(
                          "10. Setelah selesai memasukkan tiket panen",
                        ),
                        Text(
                          "11. Tekan Simpan",
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
