import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_coffe_app/admin_page.dart';
import 'package:mobile_coffe_app/database_helper.dart';
import 'dart:io';

// Ürünler sayfasını yöneten widget
class ProductsPage extends StatefulWidget {
  const ProductsPage({super.key});

  @override
  _ProductsPageState createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  List<Map<String, dynamic>> _products = []; // Ürünlerin listesi
  final TextEditingController _productNameController = TextEditingController(); // Ürün adı girişi için kontrolör
  final TextEditingController _priceController = TextEditingController(); // Fiyat girişi için kontrolör
  final TextEditingController _qtyController = TextEditingController(); // Miktar girişi için kontrolör
  File? _image; // Ürün fotoğrafı

  final ImagePicker _picker = ImagePicker(); // Resim seçici nesnesi

  @override
  void initState() {
    super.initState();
    _getProducts(); // Sayfa açıldığında ürünleri yükle
  }

  // Veritabanından ürün listesini yükleme
  Future<void> _getProducts() async {
    final DatabaseHelper db = DatabaseHelper();
    final List<Map<String, dynamic>> products = await db.getProductList();
    setState(() {
      _products = products;
    });
  }

  // Galeriden resim seçme
  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path); // Seçilen resmi sakla
      });
    }
  }

  // Yeni ürün ekleme
  Future<void> _addProduct() async {
    if (_image == null) {
      // Fotoğraf seçilmemişse kullanıcıyı uyar
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Lütfen bir fotoğraf seçin.'),
      ));
      return;
    }

    final DatabaseHelper db = DatabaseHelper();
    await db.addProduct(
      _productNameController.text, // Ürün adı
      double.parse(_priceController.text), // Fiyat
      int.parse(_qtyController.text), // Miktar
      _image!.path, // Ürün fotoğrafı yolu
    );
    _productNameController.clear(); // Ürün adı alanını temizle
    _priceController.clear(); // Fiyat alanını temizle
    _qtyController.clear(); // Miktar alanını temizle
    _image = null; // Fotoğrafı sıfırla
    _getProducts(); // Ürün listesini yeniden yükle
  }

  // Mevcut bir ürünü güncelleme
  Future<void> _updateProduct(int id) async {
    if (_image == null) {
      // Fotoğraf seçilmemişse kullanıcıyı uyar
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Lütfen bir fotoğraf seçin.'),
      ));
      return;
    }

    final DatabaseHelper db = DatabaseHelper();
    await db.updateProduct(
      id,
      _productNameController.text, // Yeni ürün adı
      double.parse(_priceController.text), // Yeni fiyat
      int.parse(_qtyController.text), // Yeni miktar
      _image!.path, // Yeni ürün fotoğrafı yolu
    );
    _productNameController.clear(); // Ürün adı alanını temizle
    _priceController.clear(); // Fiyat alanını temizle
    _qtyController.clear(); // Miktar alanını temizle
    _image = null; // Fotoğrafı sıfırla
    _getProducts(); // Ürün listesini yeniden yükle
  }

  // Ürünü silme
  Future<void> _deleteProduct(int id) async {
    final DatabaseHelper db = DatabaseHelper();
    await db.deleteProduct(id); // Ürünü veritabanından sil
    _getProducts(); // Ürün listesini yeniden yükle
  }

  // Ürün düzenleme diyalog penceresini gösterme
  void _showEditProductDialog(
      int id, String productName, String price, String qty, String image) {
    _productNameController.text = productName; // Ürün adı alanını doldur
    _priceController.text = price; // Fiyat alanını doldur
    _qtyController.text = qty; // Miktar alanını doldur
    _image = image.isNotEmpty ? File(image) : null; // Ürün fotoğrafını ayarla

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Ürünü Düzenle'), // Diyalog başlığı
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _productNameController,
                style: const TextStyle(),
                decoration: InputDecoration(
                  labelText: 'Ürün Adı', // Ürün adı etiket metni
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: const Color.fromARGB(255, 245, 229, 229),
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: _priceController,
                decoration: InputDecoration(
                  labelText: 'Fiyat', // Fiyat etiket metni
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: const Color.fromARGB(255, 245, 229, 229),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 15),
              TextField(
                controller: _qtyController,
                decoration: InputDecoration(
                  labelText: 'Miktar', // Miktar etiket metni
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: const Color.fromARGB(255, 245, 229, 229),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 15),
              ElevatedButton(
                onPressed: _pickImage, // Fotoğraf seçme işlemi
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                      vertical: 20.0, horizontal: 30.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  backgroundColor: const Color.fromARGB(255, 248, 135, 135),
                ),
                child: const Text(
                  'Fotoğraf Seç', // Buton etiketi
                  style: TextStyle(
                      fontSize: 12, color: Color.fromARGB(255, 243, 240, 240)),
                ),
              ),
              const SizedBox(height: 16),
              if (_image != null)
                Image.file(_image!, height: 100, width: 100) // Seçilen fotoğrafı göster
              else if (image.isNotEmpty)
                Image.file(File(image), height: 100, width: 100), // Mevcut fotoğrafı göster
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Diyaloğu kapat
              },
              child: const Text('İptal'),
            ),
            TextButton(
              onPressed: () {
                _updateProduct(id); // Ürünü güncelle
                Navigator.of(context).pop(); // Diyaloğu kapat
              },
              child: const Text('Güncelle'),
            ),
            TextButton(
              onPressed: () {
                _deleteProduct(id); // Ürünü sil
                Navigator.of(context).pop(); // Diyaloğu kapat
              },
              child: const Text('Sil'),
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
          title: const Text('Ürünler'), // Uygulama çubuğu başlığı
          actions: [
            IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const AdminPage()), // Admin sayfasına dön
                );
              },
            ),
          ],
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextField(
                    controller: _productNameController,
                    decoration: const InputDecoration(
                      labelText: 'Ürün Adı', // Ürün adı etiket metni
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Color.fromARGB(255, 245, 229, 229),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _priceController,
                    decoration: const InputDecoration(
                      labelText: 'Fiyat', // Fiyat etiket metni
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Color.fromARGB(255, 245, 229, 229),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _qtyController,
                    decoration: const InputDecoration(
                      labelText: 'Miktar', // Miktar etiket metni
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Color.fromARGB(255, 245, 229, 229),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _pickImage, // Fotoğraf seçme işlemi
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          vertical: 20.0, horizontal: 30.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      backgroundColor: const Color.fromARGB(255, 248, 135, 135),
                    ),
                    child: const Text(
                      'Fotoğraf Seç', // Buton etiketi
                      style: TextStyle(
                          fontSize: 18,
                          color: Color.fromARGB(255, 243, 240, 240)),
                    ),
                  ),
                  if (_image != null)
                    Image.file(_image!, height: 100, width: 100), // Seçilen fotoğrafı göster
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _addProduct, // Ürünü ekleme işlemi
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          vertical: 20.0, horizontal: 30.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      backgroundColor: const Color.fromARGB(255, 248, 135, 135),
                    ),
                    child: const Text(
                      'Ürün Ekleme', // Buton etiketi
                      style: TextStyle(
                          fontSize: 18,
                          color: Color.fromARGB(255, 243, 240, 240)),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(
              height: 40,
              thickness: 2,
              color: Colors.grey,
              indent: 16,
              endIndent: 16,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: _products.isEmpty
                    ? const Center(child: Text('Ürün bulunamadı')) // Ürün yoksa uyarı mesajı
                    : ListView.separated(
                        separatorBuilder: (context, index) => const Divider(
                          height: 1,
                          thickness: 1,
                          color: Colors.grey,
                        ),
                        itemCount: _products.length,
                        itemBuilder: (context, index) {
                          final product = _products[index];
                          return ListTile(
                            title: Text('Ürün Adı: ${product['productName']}'), // Ürün adı
                            subtitle: Text(
                                'Fiyat: ${product['price']}₺, Miktar: ${product['qty']}'), // Fiyat ve miktar
                            onTap: () => _showEditProductDialog(
                              product['id'],
                              product['productName'],
                              product['price'].toString(),
                              product['qty'].toString(),
                              product['image'],
                            ), // Ürüne tıklandığında düzenleme diyalogunu göster
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
