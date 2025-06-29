import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Kullanıcı oturum yönetimi ve kullanıcı bilgilerini yöneten bir Provider sınıfı
class UserProvider with ChangeNotifier {
  bool _isLoggedIn = false; // Kullanıcının giriş yapıp yapmadığını belirten özel değişken
  String _userType = ''; // Kullanıcı tipini saklayan özel değişken

  // Giriş yapma durumunu döndüren getter
  bool get isLoggedIn => _isLoggedIn;
  
  // Kullanıcı tipini döndüren getter
  String get userType => _userType;

  // Constructor
  UserProvider() {
    _loadLoginStatus(); // Kullanıcı giriş durumunu yükle
  }

  // Giriş durumunu SharedPreferences'tan yükler
  Future<void> _loadLoginStatus() async {
    final prefs = await SharedPreferences.getInstance(); // SharedPreferences örneğini al
    _isLoggedIn = prefs.getBool('isLoggedIn') ?? false; // 'isLoggedIn' anahtarından değeri al, yoksa false döndür
    _userType = prefs.getString('userType') ?? ''; // 'userType' anahtarından değeri al, yoksa boş string döndür
    notifyListeners(); // Dinleyicilere durumu güncellediğini bildir
  }

  // Kullanıcıyı giriş yaptırma işlemi
  Future<void> login(String userType) async {
    _isLoggedIn = true; // Giriş yapmış olarak işaretle
    _userType = userType; // Kullanıcı tipini ayarla
    final prefs = await SharedPreferences.getInstance(); // SharedPreferences örneğini al
    await prefs.setBool('isLoggedIn', true); // 'isLoggedIn' anahtarını true olarak ayarla
    await prefs.setString('userType', userType); // 'userType' anahtarını kullanıcı tipi ile ayarla
    notifyListeners(); // Dinleyicilere durumu güncellediğini bildir
  }

  // Kullanıcıyı çıkış yaptırma işlemi
  Future<void> logout() async {
    _isLoggedIn = false; // Giriş yapmamış olarak işaretle
    _userType = ''; // Kullanıcı tipini temizle
    final prefs = await SharedPreferences.getInstance(); // SharedPreferences örneğini al
    await prefs.setBool('isLoggedIn', false); // 'isLoggedIn' anahtarını false olarak ayarla
    await prefs.setString('userType', ''); // 'userType' anahtarını boş string olarak ayarla
    notifyListeners(); // Dinleyicilere durumu güncellediğini bildir
  }
}
