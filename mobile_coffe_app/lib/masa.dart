import 'package:flutter/material.dart';
import 'package:mobile_coffe_app/admin_page.dart';
import 'package:mobile_coffe_app/database_helper.dart';

class MasaPage extends StatefulWidget {
  const MasaPage({super.key});

  @override
  _MasaPageState createState() => _MasaPageState();
}

class _MasaPageState extends State<MasaPage> {
  List<Map<String, dynamic>> _masa = []; // Masaları tutacak liste
  String masaName = 'Masa'; // Yeni masa adı için varsayılan değer

  @override
  void initState() {
    super.initState();
    _getMasa(); // Sayfa ilk yüklendiğinde masaları getirir
  }

  // Veritabanından masa listesini getirir ve state'i günceller
  Future<void> _getMasa() async {
    final DatabaseHelper db = DatabaseHelper();
    final List<Map<String, dynamic>> masa = await db.getMasaList();
    setState(() {
      _masa = masa; // Listeyi günceller
    });
  }

  // Yeni masa ekler ve listeyi günceller
  Future<void> _addMasa() async {
    final DatabaseHelper db = DatabaseHelper();
    await db.addMasa(masaName);
    _getMasa(); // Masalar güncellenir
  }

  // Var olan bir masanın ismini günceller ve listeyi günceller
  Future<void> _updateMasa(int id) async {
    final DatabaseHelper db = DatabaseHelper();
    await db.updateMasa(id, masaName);
    _getMasa(); // Masalar güncellenir
  }

  // Veritabanından masa siler ve listeyi günceller
  Future<void> _deleteMasa(int id) async {
    final DatabaseHelper db = DatabaseHelper();
    await db.deleteMasa(id);
    _getMasa(); // Masalar güncellenir
  }

  // Masayı düzenleme diyalog penceresini gösterir
  void _showEditMasaDialog(int id, String masaName) {
    this.masaName = masaName; // Mevcut masa adını günceller

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Masayi Düzenle'), // Diyalog başlığı
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 16), // İçerik alanındaki boşluk
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Diyalog penceresini kapatır
              },
              child: const Text('İptal'), // İptal butonu
            ),
            TextButton(
              onPressed: () {
                _deleteMasa(id); // Masayı siler
                Navigator.of(context).pop(); // Diyalog penceresini kapatır
              },
              child: const Text('Sil'), // Sil butonu
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
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
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Masalar'), // Uygulama çubuğundaki başlık
          actions: [
            IconButton(
              icon: const Icon(Icons.arrow_back), // Geri butonu
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const AdminPage()), // Admin sayfasına yönlendirir
                );
              },
            ),
          ],
        ),
        body: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0), // Üstten ve alttan 16 birim boşluk
              child: Column(
                children: [
                  SizedBox(height: 16), // İçerik alanındaki boşluk
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0), // Üstten ve alttan 16 birim boşluk
                child: _masa.isEmpty
                    ? const Center(child: Text('Masa bulunamadı')) // Masalar listesi boşsa uyarı mesajı
                    : ListView.builder(
                        itemCount: _masa.length, // Liste uzunluğu
                        itemBuilder: (context, index) {
                          final masa = _masa[index]; // Her bir masa verisi
                          return Column(
                            children: [
                              ListTile(
                                title: Text('Masa Numarasi: ${masa['id']}'), // Masa numarası gösterir
                                onTap: () => _showEditMasaDialog(
                                  masa['id'],
                                  masa['masaIsim'],
                                ), // Masayı düzenleme diyalog penceresini açar
                              ),
                              const Divider(
                                height: 1,
                                thickness: 1,
                                color: Colors.grey, // Liste elemanları arasında gri ayırıcı
                              ),
                            ],
                          );
                        },
                      ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Butonları eşit aralıklı hizalar
              children: [
                Padding(
                  padding: const EdgeInsets.all(5.0), // Butonun etrafında boşluk
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 248, 135, 135), // Butonun arka plan rengini ayarlar
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 20,
                      ), // Butonun iç boşluklarını ayarlar
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30), // Butonun köşelerini yuvarlatır
                      ),
                    ),
                    onPressed: _getMasa, // Masaları günceller
                    child: const Text(
                      'Masaları Güncelle', // Buton üzerindeki metin
                      style: TextStyle(
                          fontSize: 13,
                          color: Color.fromARGB(255, 243, 240, 240)), // Metin stili
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0), // Butonun etrafında boşluk
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 248, 135, 135), // Butonun arka plan rengini ayarlar
                        padding: const EdgeInsets.symmetric(
                          horizontal: 30,
                          vertical: 20,
                        ), // Butonun iç boşluklarını ayarlar
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30), // Butonun köşelerini yuvarlatır
                        ),
                      ),
                      onPressed: _addMasa, // Yeni masa ekler
                      child: const Text(
                        'Masa Ekle', // Buton üzerindeki metin
                        style: TextStyle(
                            fontSize: 13,
                            color: Color.fromARGB(255, 243, 240, 240)), // Metin stili
                      )),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
