import 'package:flutter/material.dart';
import 'package:mobile_coffe_app/admin_page.dart';
import 'package:mobile_coffe_app/database_helper.dart';

// Kullanıcı yönetim sayfasını yöneten widget
class UserPage extends StatefulWidget {
  const UserPage({super.key});

  @override
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  List<Map<String, dynamic>> _user = []; // Kullanıcıların listesi
  final TextEditingController _userNameController = TextEditingController(); // Kullanıcı adı girişi için kontrolör
  final TextEditingController _passwordController = TextEditingController(); // Şifre girişi için kontrolör

  @override
  void initState() {
    super.initState();
    _getUser(); // Sayfa açıldığında kullanıcıları yükle
  }

  // Veritabanından kullanıcı listesini yükleme
  Future<void> _getUser() async {
    final DatabaseHelper db = DatabaseHelper();
    final List<Map<String, dynamic>> user = await db.getUserList();
    setState(() {
      _user = user;
    });
  }

  // Yeni kullanıcı ekleme
  Future<void> _addUser() async {
    final DatabaseHelper db = DatabaseHelper();
    await db.addUser(
      _userNameController.text, // Kullanıcı adı
      _passwordController.text, // Şifre
    );
    _userNameController.clear(); // Kullanıcı adı alanını temizle
    _passwordController.clear(); // Şifre alanını temizle
    _getUser(); // Kullanıcı listesini yeniden yükle
  }

  // Mevcut bir kullanıcıyı güncelleme
  Future<void> _updateUser(int id) async {
    final DatabaseHelper db = DatabaseHelper();
    await db.updateUser(
      id,
      _userNameController.text, // Yeni kullanıcı adı
      _passwordController.text, // Yeni şifre
    );
    _userNameController.clear(); // Kullanıcı adı alanını temizle
    _passwordController.clear(); // Şifre alanını temizle
    _getUser(); // Kullanıcı listesini yeniden yükle
  }

  // Kullanıcıyı silme
  Future<void> _deleteUser(int id) async {
    final DatabaseHelper db = DatabaseHelper();
    await db.deleteUser(id); // Kullanıcıyı veritabanından sil
    _getUser(); // Kullanıcı listesini yeniden yükle
  }

  // Kullanıcı düzenleme diyalog penceresini gösterme
  void _showEditUserDialog(int id, String userName, String password) {
    _userNameController.text = userName; // Kullanıcı adı alanını doldur
    _passwordController.text = password; // Şifre alanını doldur
    bool isPasswordVisible = false; // Şifrenin görünürlüğü

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Personeli Düzenle'), // Diyalog başlığı
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _userNameController,
                    decoration: const InputDecoration(
                      labelText: 'Personel Adı', // Kullanıcı adı etiket metni
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Color.fromARGB(255, 245, 229, 229), // Alanın arka plan rengi
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 20.0,
                        horizontal: 20.0,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: 'Şifre', // Şifre etiket metni
                      border: const OutlineInputBorder(),
                      filled: true,
                      fillColor: const Color.fromARGB(255, 245, 229, 229), // Alanın arka plan rengi
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 20.0,
                        horizontal: 20.0,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          isPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off, // Şifre görünürlüğü simgeleri
                        ),
                        onPressed: () {
                          setState(() {
                            isPasswordVisible = !isPasswordVisible; // Şifre görünürlüğünü değiştirme
                          });
                        },
                      ),
                    ),
                    obscureText: !isPasswordVisible, // Şifreyi gizle/göster
                    keyboardType: TextInputType.visiblePassword,
                  ),
                ],
              );
            },
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
                _updateUser(id); // Kullanıcıyı güncelle
                Navigator.of(context).pop(); // Diyaloğu kapat
              },
              child: const Text('Güncelle'),
            ),
            TextButton(
              onPressed: () {
                _deleteUser(id); // Kullanıcıyı sil
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
          title: const Text('Personeller'), // Uygulama çubuğu başlığı
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
                    controller: _userNameController,
                    decoration: const InputDecoration(
                      labelText: 'Personel Adı', // Kullanıcı adı etiket metni
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Color.fromARGB(255, 245, 229, 229), // Alanın arka plan rengi
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 20.0,
                        horizontal: 20.0,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _passwordController,
                    decoration: const InputDecoration(
                      labelText: 'Şifre', // Şifre etiket metni
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Color.fromARGB(255, 245, 229, 229), // Alanın arka plan rengi
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 20.0,
                        horizontal: 20.0,
                      ),
                    ),
                    obscureText: true, // Şifreyi gizle
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _addUser, // Kullanıcı ekleme
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        vertical: 20.0,
                        horizontal: 30.0,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      backgroundColor: const Color.fromARGB(255, 248, 135, 135),
                    ),
                    child: const Text(
                      'Personel Ekle', // Buton etiketi
                      style: TextStyle(
                        fontSize: 18,
                        color: Color.fromARGB(255, 243, 240, 240),
                      ),
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
                child: _user.isEmpty
                    ? const Center(child: Text('Personel bulunamadı')) // Personel yoksa gösterilecek mesaj
                    : ListView.builder(
                        itemCount: _user.length,
                        itemBuilder: (context, index) {
                          final user = _user[index];
                          return Column(
                            children: [
                              ListTile(
                                title: Text('Personel Adı: ${user['username']}'), // Personel adını göster
                                onTap: () => _showEditUserDialog(
                                  user['id'],
                                  user['username'],
                                  user['password'],
                                ), // Personel düzenleme diyalog penceresini göster
                              ),
                              const Divider(
                                height: 1,
                                thickness: 1,
                                color: Colors.grey,
                              ),
                            ],
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
