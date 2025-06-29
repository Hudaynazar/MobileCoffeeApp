import 'package:flutter/material.dart';
import 'package:mobile_coffe_app/admin_page.dart';
import 'package:mobile_coffe_app/database_helper.dart';
import 'package:mobile_coffe_app/user_page.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Debug banner'ını gizler
      title: 'Giriş Sayfası', // Uygulamanın başlığı
      home: WillPopScope(
        onWillPop: () async {
          // Geri tuşuna basıldığında hiçbir işlem yapma
          return false;
        },
        child: const Scaffold(
          resizeToAvoidBottomInset: true, // Klavye açıldığında ekranın kaymasını önler
          backgroundColor: Colors.white, // Arka plan rengini beyaz yapar
          body: SingleChildScrollView(
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(20.0), // Etrafına 20 birim boşluk ekler
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center, // Ortaya hizalar
                  children: [
                    SizedBox(height: 30), // Üstten boşluk bırakır
                    SizedBox(height: 20), // Üstten boşluk bırakır
                    Image(
                      image: AssetImage('assets/image/cafe.png'), // Resim dosyasını ekler
                      width: 200,
                      height: 200,
                    ),
                    SizedBox(height: 40), // Üstten boşluk bırakır
                    LoginForm(), // Giriş formunu ekler
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  TextEditingController isim = TextEditingController(); // Kullanıcı adı için kontrolcü
  TextEditingController sifre = TextEditingController(); // Şifre için kontrolcü
  final DatabaseHelper _databaseHelper = DatabaseHelper(); // Veritabanı yardımcısını başlatır

  void _login() async {
    String username = isim.text; // Kullanıcı adını alır
    String password = sifre.text; // Şifreyi alır

    var user = await _databaseHelper.getUser(username, password); // Veritabanında kullanıcıyı kontrol eder

    if (user != null) {
      if (user['type'] == 'admin') {
        // Eğer kullanıcı 'admin' ise AdminPage'e yönlendirir
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const AdminPage()),
        );
      } else if (user['type'] == 'user') {
        // Eğer kullanıcı 'user' ise UserPage'e yönlendirir
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const UserPage()),
        );
      }
    } else {
      // Eğer kullanıcı geçerli değilse uyarı mesajı gösterir
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Geçersiz kullanıcı adı veya şifre')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        TextField(
          controller: isim, // Kullanıcı adı için kontrolcü
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.person), // Kullanıcı simgesi ekler
            hintText: 'Kullanıcı Adı', // Placeholder metni
            filled: true, // Arka plan rengini doldurur
            fillColor: const Color.fromARGB(255, 245, 229, 229), // Arka plan rengini ayarlar
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30.0), // Kenarları yuvarlatır
              borderSide: BorderSide.none, // Kenarlık çizgisi yok
            ),
          ),
        ),
        const SizedBox(height: 20.0), // Üstten boşluk bırakır
        TextField(
          controller: sifre, // Şifre için kontrolcü
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.lock), // Şifre simgesi ekler
            hintText: 'Şifre', // Placeholder metni
            filled: true, // Arka plan rengini doldurur
            fillColor: const Color.fromARGB(255, 245, 229, 229), // Arka plan rengini ayarlar
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30.0), // Kenarları yuvarlatır
              borderSide: BorderSide.none, // Kenarlık çizgisi yok
            ),
          ),
          obscureText: true, // Şifreyi gizler
        ),
        const SizedBox(height: 40.0), // Üstten boşluk bırakır
        SizedBox(
          width: double.infinity, // Butonun genişliğini ekran genişliğine göre ayarlar
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 15.0), // Butonun iç boşluğunu ayarlar
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0), // Kenarları yuvarlatır
              ),
              backgroundColor: const Color.fromARGB(255, 248, 135, 135), // Butonun arka plan rengini ayarlar
            ),
            onPressed: _login, // Butona basıldığında _login fonksiyonunu çağırır
            child: const Text(
              'Giriş Yap', // Buton üzerindeki metin
              style: TextStyle(
                  fontSize: 18, color: Color.fromARGB(255, 243, 240, 240)), // Metin stili
            ),
          ),
        ),
      ],
    );
  }
}
