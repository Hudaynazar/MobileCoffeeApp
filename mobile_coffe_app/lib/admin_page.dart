import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile_coffe_app/kasa.dart';
import 'package:mobile_coffe_app/login_page.dart';
import 'package:mobile_coffe_app/masa.dart';
import 'package:mobile_coffe_app/personel.dart';
import 'package:mobile_coffe_app/products.dart';

class AdminPage extends StatelessWidget {
  const AdminPage({super.key});

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('dd.MM.yyyy').format(now);

    return WillPopScope(
      onWillPop: () async {
        // Geri tuşuna basıldığında hiçbir işlem yapma
        return false;
      },
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: SafeArea(
          child: Scaffold(
            appBar: AppBar(
              // Red color matching the button
              title: Column(
                children: [
                  //Tarih
                  Text(
                    formattedDate,
                    style: const TextStyle(
                      color: Color.fromARGB(255, 231, 126, 126),
                      fontSize: 25,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
              //tarihi ortalama
              centerTitle: true,
            ),
            //Tuslar
            body: Column(
              children: [
                const SizedBox(height: 15),
                Expanded(
                  child: Column(
                    children: [
                      Expanded(
                        child: ListView(
                          children: [
                            //Admin Sayfadaki Resim
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Column(
                                children: [
                                  Image.asset(
                                    'assets/image/admin.png',
                                    height: 200,
                                    fit: BoxFit.cover,
                                  ),
                                  const SizedBox(height: 10),
                                ],
                              ),
                            ),
                            //Depo butonu
                            buildCard(
                              icon: Icons.add_business,
                              title: "DEPO",
                              onPressed: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const ProductsPage()),
                                );
                              },
                            ),
                            const SizedBox(height: 8),
                            //Personel islem butonu
                            buildCard(
                              icon: Icons.account_circle,
                              title: "PERSONEL İŞLEM",
                              onPressed: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const UserPage()),
                                );
                              },
                            ),
                            const SizedBox(height: 8),
                            //Masa Islem butonu
                            buildCard(
                              icon: Icons.table_restaurant,
                              title: "MASA İŞLEM",
                              onPressed: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const MasaPage()),
                                );
                              },
                            ),
                            const SizedBox(height: 8),
                            //Kasa islem butonu
                            buildCard(
                              icon: Icons.comment_bank,
                              title: "KASA ISLEM",
                              onPressed: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const KasaPage()),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(50.0),
                        //Cikis butonu
                        child: buildCard(
                          icon: Icons.exit_to_app,
                          title: "ÇIKIŞ",
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const LoginPage()),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

//Butonlarin Sekli ve Rengi ayarlayan metod
  Widget buildCard({
    required IconData icon,
    required String title,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      child: Card(
        color: const Color(0xFFFFE5E5),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, size: 40, color: const Color(0xFF333333)),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Color(0xFF333333),
                    ),
                  ),
                ),
              ),
              const Icon(Icons.arrow_forward_ios,
                  size: 24, color: Color(0xFF333333)),
            ],
          ),
        ),
      ),
    );
  }
}
