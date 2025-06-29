import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile_coffe_app/menu.dart';
import 'database_helper.dart';
import 'login_page.dart';

class UserPage extends StatefulWidget {
  const UserPage({super.key});

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  List<Map<String, dynamic>> _masa = []; // Masaların listesi

  @override
  void initState() {
    super.initState();
    _getMasa(); // Sayfa başlatıldığında masaları yükle
  }

  // Masaları veritabanından çekme
  Future<void> _getMasa() async {
    final DatabaseHelper db = DatabaseHelper();
    final List<Map<String, dynamic>> masa = await db.getMasaList();
    setState(() {
      _masa = masa; // Masaları güncelle
    });
  }

  // Masa durumu ile ilgili bilgi gösteren diyalog
  Future<void> _showMasaDialog(Map<String, dynamic> masa) async {
    final bool isOccupied = await DatabaseHelper().isTableOccupied(masa['id']);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Masa Numarası:'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Masa Numarası: ${masa['id'] ?? 'Bilgi Yok'}'), // Masa numarası
              Text('Durum: ${isOccupied ? 'Dolu' : 'Boş'}'), // Masa durumu
            ],
          ),
          actions: [
            TextButton(
              child: const Text('Kapat'),
              onPressed: () {
                Navigator.of(context).pop(); // Diyaloğu kapat
              },
            ),
            TextButton(
              child: const Text('Menüye Git'),
              onPressed: () {
                Navigator.of(context).pop(); // Diyaloğu kapat
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MenuPage(masaId: masa['id']),
                  ),
                ); // Menü sayfasına git
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('dd.MM.yyyy').format(now); // Bugünün tarihini formatla

    return WillPopScope(
      onWillPop: () async {
        // Geri tuşuna basıldığında hiçbir işlem yapma
        return false;
      },
      child: SafeArea(
        child: Scaffold(
          body: Column(
            children: [
              Container(
                decoration: const BoxDecoration(
                  color: Color.fromARGB(255, 248, 135, 135),
                  borderRadius: BorderRadius.only(
                    bottomRight: Radius.circular(20),
                    bottomLeft: Radius.circular(20),
                  ),
                ),
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height / 9,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: Text(
                        formattedDate,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(top: 10),
                      child: Text(
                        "PERSONEL SAYFASI",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ListView.builder(
                    itemCount: (_masa.length / 15).ceil(), // Sayfaların sayısını hesapla
                    itemBuilder: (context, pageIndex) {
                      int startIndex = pageIndex * 15; // Her sayfanın başlangıç indeksi
                      int endIndex = startIndex + 15 > _masa.length
                          ? _masa.length // Son sayfanın end indeksi
                          : startIndex + 15;
                      List<Map<String, dynamic>> pageMasa =
                          _masa.sublist(startIndex, endIndex); // Sayfaya ait masaları al

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3, // 3 sütun
                            crossAxisSpacing: 15, // Sütunlar arası boşluk
                            mainAxisSpacing: 15, // Satırlar arası boşluk
                            mainAxisExtent: 100, // Yükseklik
                          ),
                          itemCount: pageMasa.length,
                          itemBuilder: (context, index) {
                            var masa = pageMasa[index];
                            return FutureBuilder<bool>(
                              future:
                                  DatabaseHelper().isTableOccupied(masa['id']),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return Container(
                                    padding: const EdgeInsets.all(5),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.5),
                                          spreadRadius: 1,
                                          blurRadius: 8,
                                        ),
                                      ],
                                    ),
                                    child: const Center(
                                        child: CircularProgressIndicator()),
                                  ); // Verinin yüklenmesini beklerken gösterilecek yükleme göstergesi
                                }
                                bool isOccupied = snapshot.data ?? false;
                                return GestureDetector(
                                  onTap: () => _showMasaDialog(masa),
                                  child: Container(
                                    padding: const EdgeInsets.all(5),
                                    decoration: BoxDecoration(
                                      color: isOccupied
                                          ? Colors.red.shade400 // Dolu ise kırmızı
                                          : Colors.green.shade400, // Boş ise yeşil
                                      borderRadius: BorderRadius.circular(10),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.5),
                                          spreadRadius: 1,
                                          blurRadius: 8,
                                        ),
                                      ],
                                    ),
                                    child: Center(
                                      child: Text(
                                        'Masa: ${masa['id']}',
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(16.0),
                alignment: Alignment.bottomCenter,
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const LoginPage()),
                      ); // Kullanıcıyı giriş sayfasına yönlendir
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 238, 171, 166),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'ÇIKIŞ',
                      style: TextStyle(
                        color: Color.fromARGB(255, 255, 255, 255),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
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
