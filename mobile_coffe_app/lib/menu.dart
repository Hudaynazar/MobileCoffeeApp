import 'package:flutter/material.dart';
import 'package:mobile_coffe_app/user_page.dart';
import 'database_helper.dart';
import 'dart:io';

// Menü sayfasını yöneten widget
class MenuPage extends StatefulWidget {
  final int masaId; // Masanın kimliği

  const MenuPage({super.key, required this.masaId});

  @override
  _MenuPageState createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  List<Map<String, dynamic>> _products = []; // Ürünlerin listesi
  final List<Map<String, dynamic>> _cart = []; // Sepetteki ürünler
  List<Map<String, dynamic>> _orders = []; // Siparişler
  double _totalPrice = 0.0; // Toplam fiyat

  @override
  void initState() {
    super.initState();
    _loadProducts(); // Ürünleri yükle
    _loadOrders(); // Siparişleri yükle
  }

  // Veritabanından ürünleri yükleme
  Future<void> _loadProducts() async {
    final products = await DatabaseHelper().getProductList();
    setState(() {
      _products = products;
    });
  }

  // Veritabanından siparişleri yükleme
  Future<void> _loadOrders() async {
    final db = await DatabaseHelper().database;
    final List<Map<String, dynamic>> orders = await db.query(
      'siparis',
      where: 'masaAdi = ?',
      whereArgs: [widget.masaId.toString()],
    );
    setState(() {
      _orders = orders;
      _totalPrice = _orders.fold(0.0, (sum, order) {
        final orderTotal = double.tryParse(order['tutar'] ?? '0') ?? 0.0;
        return sum + orderTotal;
      });
    });
  }

  // Sepete ürün ekleme
  void _addToCart(Map<String, dynamic> product, int quantity, String note) {
    final existingProduct = _cart.firstWhere(
      (p) => p['id'] == product['id'],
      orElse: () => <String, dynamic>{},
    );

    if (existingProduct.isNotEmpty) {
      final newQuantity = existingProduct['quantity'] + quantity;
      if (newQuantity <= product['qty']) {
        setState(() {
          existingProduct['quantity'] = newQuantity;
          existingProduct['note'] = note;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Depoda yeterli ürün yok')),
        );
      }
    } else {
      if (quantity <= product['qty']) {
        setState(() {
          _cart.add({
            'id': product['id'],
            'productName': product['productName'],
            'price': product['price'],
            'quantity': quantity,
            'note': note,
          });
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Depoda yeterli ürün yok')),
        );
      }
    }
  }

  // Sepetten ürün çıkarma
  void _removeFromCart(Map<String, dynamic> product) {
    setState(() {
      _cart.removeWhere((p) => p['id'] == product['id']);
    });
  }

  // Siparişi veritabanına kaydetme
  Future<void> _saveOrder() async {
    final db = await DatabaseHelper().database;
    final masaAdi = widget.masaId.toString();
    for (final cartItem in _cart) {
      final existingProduct = _products.firstWhere(
        (product) => product['id'] == cartItem['id'],
      );
      final newQty = existingProduct['qty'] - cartItem['quantity'];

      if (newQty >= 0) {
        await DatabaseHelper().updateProduct(
          existingProduct['id'],
          existingProduct['productName'],
          double.parse(existingProduct['price']),
          newQty,
          existingProduct['image'],
        );

        await DatabaseHelper().addOrder(
          masaAdi,
          cartItem['productName'],
          (double.parse(cartItem['price']) * cartItem['quantity']).toString(),
          cartItem['note'],
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Depoda yeterli ürün yok')),
        );
      }
    }
    setState(() {
      _cart.clear();
    });
    _loadOrders();

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const UserPage(),
      ),
    );
  }

  // Ödemeyi onaylama ve siparişleri güncelleme
  Future<void> _confirmPayment() async {
    final db = await DatabaseHelper().database;
    final masaAdi = widget.masaId.toString();

    final List<Map<String, dynamic>> existingMasalar = await db.query(
      'siparis',
      columns: ['masaAdi'],
      where: 'masaAdi LIKE ?',
      whereArgs: ['$masaAdi%'],
    );

    final String newMasaAdi = '$masaAdi.${existingMasalar.length}';

    for (final order in _orders) {
      await DatabaseHelper().addOrder(
        newMasaAdi,
        order['siparisler'],
        order['tutar'],
        order['siparisNot'] ?? '',
      );
    }

    await DatabaseHelper().deleteOrder(masaAdi);

    setState(() {
      _orders.clear();
      _totalPrice = 0.0;
      _cart.clear();
    });

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Ödeme Onaylandı'),
          content: const Text('Ödeme başarıyla tamamlandı.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Tamam'),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => const UserPage(),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  // Sepetteki ürünlerin toplam fiyatını hesaplama
  double _calculateCartTotalPrice() {
    return _cart.fold(0.0, (sum, item) {
      return sum + (double.parse(item['price']) * item['quantity']);
    });
  }

  // Sipariş notlarını gösterme
  Future<void> _showOrderNotes() async {
    final db = await DatabaseHelper().database;
    final masaAdi = widget.masaId.toString();

    final List<Map<String, dynamic>> orders = await db.query(
      'siparis',
      where: 'masaAdi = ?',
      whereArgs: [masaAdi],
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Sipariş Notları'),
          content: orders.isEmpty
              ? const Text('Sipariş notu bulunamadı.')
              : SizedBox(
                  width: double.maxFinite,
                  child: ListView(
                    children: orders.map((order) {
                      return ListTile(
                        title: Text(order['siparisler'] ?? 'No Order'),
                        subtitle: Text(order['siparisNot'] ?? 'No Note'),
                      );
                    }).toList(),
                  ),
                ),
          actions: <Widget>[
            TextButton(
              child: const Text('Tamam'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // Sayfa geri düğmesine basıldığında yapılacak işlemler
  Future<bool> _onWillPop() async {
    await _loadProducts();
    await _loadOrders();
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Masa ${widget.masaId}'), // Başlık
          actions: [
            IconButton(
              icon: const Icon(Icons.note),
              onPressed: _showOrderNotes, // Sipariş notlarını göster
            ),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const Text(
                      'Ürünler',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: 460,
                      child: GridView.builder(
                        shrinkWrap: true,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          childAspectRatio: 1,
                        ),
                        itemCount: _products.length,
                        itemBuilder: (context, index) {
                          final product = _products[index];
                          return Card(
                            child: Column(
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return ProductDetailDialog(
                                            product: product,
                                            addToCart: _addToCart,
                                            removeFromCart: _removeFromCart,
                                          );
                                        },
                                      );
                                    },
                                    child: Image.file(
                                      File(product['image']),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                Text(product['productName']),
                                Text('₺${product['price']}'),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Siparişler',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: 60,
                      child: Scrollbar(
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _orders.length,
                          itemBuilder: (context, index) {
                            final order = _orders[index];
                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('${order['siparisler']}',
                                      style: const TextStyle(fontSize: 16)),
                                  Text('₺${order['tutar']}',
                                      style: const TextStyle(fontSize: 14)),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Sepet',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: 60,
                      child: Scrollbar(
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _cart.length,
                          itemBuilder: (context, index) {
                            final cartItem = _cart[index];
                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                      '${cartItem['productName']} x${cartItem['quantity']}',
                                      style: const TextStyle(fontSize: 16)),
                                  Text(
                                      '₺${(double.tryParse(cartItem['price']?.toString() ?? '0') ?? 0.0) * cartItem['quantity']}',
                                      style: const TextStyle(fontSize: 14)),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Text(
                            'Toplam: ₺${_calculateCartTotalPrice() + _totalPrice}',
                            style: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 15.0, horizontal: 15.0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30.0),
                              ),
                              backgroundColor:
                                  const Color.fromARGB(255, 248, 135, 135),
                            ),
                            onPressed: () {
                              _confirmPayment(); // Ödemeyi onayla
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                  builder: (context) => const UserPage(),
                                ),
                              );
                            },
                            child: const Text(
                              'Ödemeyi Onayla',
                              style: TextStyle(
                                fontSize: 10,
                                color: Color.fromARGB(255, 243, 240, 240),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.only(
                                left: 20,
                                top: 15.0, // Üst taraf
                                bottom: 15.0, // Alt taraf
                                right: 20.0, // Sağ taraf için ekstra padding
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30.0),
                              ),
                              backgroundColor:
                                  const Color.fromARGB(255, 248, 135, 135),
                            ),
                            onPressed: _saveOrder, // Siparişi kaydet
                            child: const Text(
                              'Siparişi Kaydet',
                              style: TextStyle(
                                fontSize: 10,
                                color: Color.fromARGB(255, 243, 240, 240),
                              ),
                            ),
                          )
                        ],
                      ),
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

// Ürün detaylarını gösteren diyalog
class ProductDetailDialog extends StatefulWidget {
  final Map<String, dynamic> product;
  final Function(Map<String, dynamic>, int, String) addToCart;
  final Function(Map<String, dynamic>) removeFromCart;

  const ProductDetailDialog({
    super.key,
    required this.product,
    required this.addToCart,
    required this.removeFromCart,
  });

  @override
  _ProductDetailDialogState createState() => _ProductDetailDialogState();
}

class _ProductDetailDialogState extends State<ProductDetailDialog> {
  int _quantity = 1; // Varsayılan miktar
  String _note = ''; // Sipariş notu

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.product['productName']),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 150,
            height: 150,
            child: Image.file(
              File(widget.product['image']),
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 10),
          Text('₺${widget.product['price']}'),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.remove),
                onPressed: () {
                  if (_quantity > 1) {
                    setState(() {
                      _quantity--;
                    });
                  }
                },
              ),
              Text(_quantity.toString()),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () {
                  setState(() {
                    _quantity++;
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 10),
          TextField(
            decoration: const InputDecoration(
              labelText: 'Sipariş Notu',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              setState(() {
                _note = value;
              });
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          child: const Text('İptal'),
          onPressed: () {
            Navigator.of(context).pop(); // Diyaloğu kapat
          },
        ),
        TextButton(
          child: const Text('Ekle'),
          onPressed: () {
            widget.addToCart(widget.product, _quantity, _note); // Sepete ekle
            Navigator.of(context).pop(); // Diyaloğu kapat
          },
        ),
      ],
    );
  }
}
