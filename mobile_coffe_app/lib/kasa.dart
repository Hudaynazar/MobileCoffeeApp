import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile_coffe_app/admin_page.dart';
import 'package:mobile_coffe_app/database_helper.dart'; // DatabaseHelper sınıfını import eder

class KasaPage extends StatelessWidget {
  const KasaPage({super.key});

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now(); // Şu anki tarihi alır
    String formattedDate = DateFormat('dd.MM.yyyy').format(now); // Tarihi formatlar

    return WillPopScope(
      onWillPop: () async {
        // Geri tuşuna basıldığında AdminPage sayfasına yönlendir
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const AdminPage()),
        );
        // true döndürmek, işlemin tamamlandığını belirtir
        return false;
      },
      child: MaterialApp(
        debugShowCheckedModeBanner: false, // Debug banner'ını gizler
        home: SafeArea(
          child: Scaffold(
            appBar: AppBar(
              title: Column(
                children: [
                  Text(
                    formattedDate, // Formatlanmış tarihi gösterir
                    style: const TextStyle(
                      color: Color.fromARGB(255, 255, 149, 149),
                      fontSize: 25,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
              centerTitle: true,
            ),
            body: Column(
              children: [
                const SizedBox(height: 15), // Üstten boşluk bırakır
                Expanded(
                  child: Column(
                    children: [
                      Expanded(
                        child: ListView(
                          children: [
                            buildCard(
                              icon: Icons.settings_display,
                              title: "GÜNLÜK",
                              onPressed: () async {
                                DatabaseHelper dbHelper = DatabaseHelper();
                                double totalAmount =
                                    await dbHelper.getTotalAmount(); // Günlük toplam sipariş tutarını alır
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: const Text('Toplam Sipariş Tutarı'),
                                      content: Text(
                                          'Toplam siparişlerin tutarı: \$${totalAmount.toStringAsFixed(2)}'),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                          child: const Text('Tamam'),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                            ),
                            const SizedBox(height: 8), // Kartlar arasında boşluk bırakır
                            buildCard(
                              icon: Icons.calendar_month,
                              title: "AYLIK",
                              onPressed: () async {
                                DatabaseHelper dbHelper = DatabaseHelper();
                                double monthlyTotal =
                                    await dbHelper.getMonthlyTotal(); // Aylık toplam cirosunu alır
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: const Text('Aylık Ciro'),
                                      content: Text(
                                          'Aylık toplam: \$${monthlyTotal.toStringAsFixed(2)}'),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                          child: const Text('Tamam'),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                            ),
                            const SizedBox(height: 8), // Kartlar arasında boşluk bırakır
                            buildCard(
                              icon: Icons.check_outlined,
                              title: "FIS SAYISI",
                              onPressed: () async {
                                DatabaseHelper dbHelper = DatabaseHelper();
                                final orders = await dbHelper.getOrderList(); // Siparişlerin listesini alır
                                final Set<String> uniqueTables = {};

                                for (var order in orders) {
                                  final tableName = order['masaAdi'] as String;
                                  uniqueTables.add(tableName); // Benzersiz masa adlarını toplar
                                }
                                final int uniqueTableCount = uniqueTables.length; // Benzersiz masa sayısını hesaplar
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: const Text('Masa Sayısı'),
                                      content: Text(
                                          'Günlük Çıkarılan Fiş Sayısı: $uniqueTableCount'),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                          child: const Text('Tamam'),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                            ),
                            const SizedBox(height: 8), // Kartlar arasında boşluk bırakır
                            buildCard(
                              icon: Icons.pin_end,
                              title: "GÜN SONU",
                              onPressed: () {
                                _showEndOfDayDialog(context); // Gün Sonu Dialog'ını gösterir
                              },
                            )
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(50.0),
                        child: buildCard(
                          icon: Icons.exit_to_app,
                          title: "GERİ DÖN",
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const AdminPage()), // AdminPage'e yönlendirir
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

  void _showEndOfDayDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Bu Günlük Siparişler Silinsin Mi?'),
          content: const Text(
              'Gün sonu işlemi gerçekleştirecek ve tüm siparişleri silecektir. Devam etmek istiyor musunuz?'),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop(); // Dialog'u kapatır

                // Gün Sonu işlemini başlatır
                DatabaseHelper dbHelper = DatabaseHelper();
                double totalAmount =
                    await dbHelper.getTotalAmount(); // Günlük toplam tutarı alır
                double monthlyTotal =
                    await dbHelper.getMonthlyTotal(); // Aylık toplam cirosunu alır

                monthlyTotal += totalAmount; // Günlük tutarı aylık toplamına ekler

                DateTime now = DateTime.now();
                String currentMonth =
                    DateFormat('yyyy-MM').format(now); // Geçerli ayı formatlar

                List<Map<String, dynamic>> results =
                    await dbHelper.database.then((db) => db.query(
                          'aylikCiro',
                          where: 'ay = ?',
                          whereArgs: [currentMonth],
                        ));

                if (results.isNotEmpty) {
                  // Mevcut ay için veri varsa günceller
                  await dbHelper.database.then((db) => db.update(
                        'aylikCiro',
                        {'aylikPara': monthlyTotal},
                        where: 'ay = ?',
                        whereArgs: [currentMonth],
                      ));
                } else {
                  // Veri yoksa yeni kayıt ekler
                  await dbHelper.database.then((db) => db.insert(
                        'aylikCiro',
                        {
                          'ay': currentMonth,
                          'aylikPara': monthlyTotal
                        },
                      ));
                }

                // Tüm siparişleri siler
                await dbHelper.deleteAllOrders();

                // Gün Sonu işleminin başarılı olduğunu belirten bir diyalog gösterir
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Gün Sonu İşlemi'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                              'Tüm siparişler başarıyla silindi.'),
                          const SizedBox(
                              height: 16.0), // Daha iyi görünmesi için boşluk
                          Text(
                              'Toplam Tutar: \$${totalAmount.toStringAsFixed(2)}'),
                          Text(
                              'Aylık Toplam: \$${monthlyTotal.toStringAsFixed(2)}'),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text('Tamam'),
                        ),
                      ],
                    );
                  },
                );
              },
              child: const Text('Evet'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Dialog'u kapatır
              },
              child: const Text('Hayır'),
            ),
          ],
        );
      },
    );
  }

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
              Icon(icon, size: 40, color: const Color(0xFF333333)), // İkonu gösterir
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    title, // Kart başlığını gösterir
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Color(0xFF333333),
                    ),
                  ),
                ),
              ),
              const Icon(Icons.arrow_forward_ios,
                  size: 24, color: Color(0xFF333333)), // İleri ok ikonunu gösterir
            ],
          ),
        ),
      ),
    );
  }
}
