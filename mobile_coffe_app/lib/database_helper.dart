import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:intl/intl.dart';

class DatabaseHelper {
  // Singleton deseni ile DatabaseHelper sınıfının tek bir örneği oluşturulur.
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  static Database? _database;

  DatabaseHelper._internal();

  // Veritabanı nesnesine erişimi sağlar. Eğer veritabanı önceden oluşturulmamışsa başlatır.
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // Veritabanını başlatır ve eğer gerekirse tabloları oluşturur.
  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'aksicafe_.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  // İlk veritabanı oluşturulduğunda çağrılır ve gerekli tabloları oluşturur.
  Future _onCreate(Database db, int version) async {
    await db.execute(
      '''
      CREATE TABLE adminAcc (
        id INTEGER PRIMARY KEY,
        username TEXT NOT NULL,
        password TEXT NOT NULL
      )
      ''',
    );
    await db.execute(
      '''
      CREATE TABLE userAcc (
        id INTEGER PRIMARY KEY,
        username TEXT NOT NULL,
        password TEXT NOT NULL
      )
      ''',
    );
    await db.execute(
      '''
      CREATE TABLE urunAdi(
        id INTEGER PRIMARY KEY,
        productName TEXT NOT NULL,
        price TEXT NOT NULL,
        qty INTEGER NOT NULL,
        image TEXT NOT NULL
      )
      ''',
    );
    await db.execute(
      '''
      CREATE TABLE masaAdi(
        id INTEGER PRIMARY KEY,
        masaIsim TEXT NOT NULL
      )
      ''',
    );
    await db.execute(
      '''
      CREATE TABLE siparis(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        masaAdi TEXT NOT NULL,
        siparisler TEXT NOT NULL,
        tutar TEXT NOT NULL,
        siparisNot TEXT
      )
      ''',
    );
    await db.execute(
      '''
      CREATE TABLE aylikCiro(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        ay TEXT NOT NULL,
        aylikPara REAL NOT NULL
      )
      ''',
    );

    // Başlangıç verileri olarak bir admin ve bir kullanıcı ekler.
    await db.insert('adminAcc', {'username': 'admin', 'password': 'admin123'});
    await db.insert('userAcc', {'username': 'user', 'password': 'user123'});
  }

  // Siparişler tablosundaki tüm tutarların toplamını döndürür.
  Future<double> getTotalAmount() async {
    final db = await database;
    List<Map<String, dynamic>> results = await db
        .rawQuery('SELECT SUM(CAST(tutar AS REAL)) AS total FROM siparis');

    double total = 0.0;

    if (results.isNotEmpty && results.first['total'] != null) {
      total = results.first['total'] as double;
    }

    return total;
  }

  // Aylık ciroları döndürür. Geçerli ayın toplam cirosunu hesaplar.
  Future<double> getMonthlyTotal() async {
    final db = await database;
    final now = DateTime.now();
    final currentMonth = DateFormat('yyyy-MM').format(now);

    List<Map<String, dynamic>> results = await db.query(
      'aylikCiro',
      where: 'ay = ?',
      whereArgs: [currentMonth],
    );

    double total = 0.0;

    if (results.isNotEmpty) {
      for (var row in results) {
        total += row['aylikPara'] as double;
      }
    }

    return total;
  }

  // Verilen kullanıcı adı ve şifreye göre kullanıcıyı sorgular ve döndürür.
  Future<Map<String, dynamic>?> getUser(String username, String password) async {
    Database db = await database;
    List<Map<String, dynamic>> adminResult = await db.query(
      'adminAcc',
      where: 'username = ? AND password = ?',
      whereArgs: [username, password],
    );
    if (adminResult.isNotEmpty) {
      return {'type': 'admin', 'user': adminResult.first};
    }
    List<Map<String, dynamic>> userResult = await db.query(
      'userAcc',
      where: 'username = ? AND password = ?',
      whereArgs: [username, password],
    );
    if (userResult.isNotEmpty) {
      return {'type': 'user', 'user': userResult.first};
    }
    return null;
  }

  // Ürünlerin listesini döndürür.
  Future<List<Map<String, dynamic>>> getProductList() async {
    final db = await database;
    final List<Map<String, dynamic>> products =
        await db.rawQuery('SELECT * FROM urunAdi');
    return products;
  }

  // Yeni bir ürün ekler.
  Future<void> addProduct(String productName, double price, int qty, String image) async {
    final db = await database;
    await db.insert(
      'urunAdi',
      {
        'productName': productName,
        'price': price.toString(),
        'qty': qty,
        'image': image,
      },
    );
  }

  // Varolan bir ürünü günceller.
  Future<void> updateProduct(int id, String productName, double price, int qty, String image) async {
    final db = await database;
    await db.update(
      'urunAdi',
      {
        'productName': productName,
        'price': price.toString(),
        'qty': qty,
        'image': image,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Belirli bir ürünü siler.
  Future<void> deleteProduct(int id) async {
    final db = await database;
    await db.delete(
      'urunAdi',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Kullanıcıların listesini döndürür.
  Future<List<Map<String, dynamic>>> getUserList() async {
    final db = await database;
    final List<Map<String, dynamic>> userAcc =
        await db.rawQuery('SELECT * FROM userAcc');
    return userAcc;
  }

  // Yeni bir kullanıcı ekler.
  Future<void> addUser(String userName, String password) async {
    final db = await database;
    await db.insert(
      'userAcc',
      {
        'username': userName,
        'password': password,
      },
    );
  }

  // Varolan bir kullanıcıyı günceller.
  Future<void> updateUser(int id, String userName, String password) async {
    final db = await database;
    await db.update(
      'userAcc',
      {
        'username': userName,
        'password': password,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Belirli bir kullanıcıyı siler.
  Future<void> deleteUser(int id) async {
    final db = await database;
    await db.delete(
      'userAcc',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Masaların listesini döndürür.
  Future<List<Map<String, dynamic>>> getMasaList() async {
    final db = await database;
    final List<Map<String, dynamic>> masa =
        await db.rawQuery('SELECT * FROM masaAdi');
    return masa;
  }

  // Yeni bir masa ekler.
  Future<void> addMasa(String masaIsim) async {
    final db = await database;
    await db.insert(
      'masaAdi',
      {
        'masaIsim': masaIsim,
      },
    );
  }

  // Varolan bir masayı günceller.
  Future<void> updateMasa(int id, String masaIsim) async {
    final db = await database;
    await db.update(
      'masaAdi',
      {
        'masaIsim': masaIsim,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Belirli bir masayı siler.
  Future<void> deleteMasa(int id) async {
    final db = await database;
    await db.delete(
      'masaAdi',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Belirli bir masa adı ve siparişlerle ilgili siparişleri döndürür.
  Future<List<Map<String, dynamic>>> getOrder(String masaAdi, String siparisler) async {
    final db = await database;
    final orders = await db.query(
      'siparis',
      where: 'masaAdi = ? AND siparisler = ?',
      whereArgs: [masaAdi, siparisler],
    );
    return orders;
  }

  // Yeni bir sipariş ekler.
  Future<void> addOrder(String masaAdi, String siparisler, String price, [String? siparisNot]) async {
    final db = await database;
    await db.insert(
      'siparis',
      {
        'masaAdi': masaAdi,
        'siparisler': siparisler,
        'tutar': price,
        'siparisNot': siparisNot
      },
    );
  }

  // Varolan bir siparişi günceller.
  Future<void> updateOrder(String masaAdi, String siparisler, [String? siparisNot]) async {
    final db = await database;
    await db.update(
      'siparis',
      {
        'siparisler': siparisler,
        'siparisNot': siparisNot,
      },
      where: 'masaAdi = ?',
      whereArgs: [masaAdi],
    );
  }

  // Belirli bir masa adı ile ilgili siparişi siler.
  Future<void> deleteOrder(String masaAdi) async {
    final db = await database;
    await db.delete(
      'siparis',
      where: 'masaAdi = ?',
      whereArgs: [masaAdi],
    );
  }

  // Belirli bir masa ID ile ilgili siparişleri döndürür.
  Future<List<Map<String, dynamic>>> getOrderByMasaId(int masaId) async {
    final db = await database;
    final orders = await db.query(
      'siparis',
      where: 'masaAdi = ?',
      whereArgs: [masaId.toString()],
    );
    return orders;
  }

  // Occupied tables (dolu masalar) listesini döndürür.
  Future<List<String>> getOccupiedTables() async {
    final db = await database;
    final List<Map<String, dynamic>> orders =
        await db.query('siparis', columns: ['masaAdi']);
    return orders
        .where((order) => !order['masaAdi'].toString().contains('.'))
        .map((order) => order['masaAdi'].toString())
        .toList();
  }

  // Belirli bir masa ID'sinin dolu olup olmadığını kontrol eder.
  Future<bool> isTableOccupied(int tableId) async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query(
      'siparis',
      where: 'masaAdi = ?',
      whereArgs: [tableId.toString()],
    );
    return result.isNotEmpty;
  }

  // Tüm siparişleri siler.
  Future<void> deleteAllOrders() async {
    final db = await database;
    await db.delete('siparis');
  }

  // Siparişler tablosundaki tüm siparişleri döndürür.
  Future<List<Map<String, dynamic>>> getOrderList() async {
    final db = await database;
    return db.query('siparis');
  }
}
