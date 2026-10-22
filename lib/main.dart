import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:intl/intl.dart';

void main() { runApp(MohasbSoftApp()); }

class MohasbSoftApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'محاسب سوفت',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.teal),
      home: HomeScreen(),
    );
  }
}

class DatabaseHelper {
  static Database? _db;
  static Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await initDb();
    return _db!;
  }
  static Future<Database> initDb() async {
    String path = join(await getDatabasesPath(), 'mohasb.db');
    return await openDatabase(path, version: 1, onCreate: (db, version) async {
      await db.execute('CREATE TABLE sales(id INTEGER PRIMARY KEY AUTOINCREMENT, customer TEXT, amount REAL, date TEXT, notes TEXT)');
      await db.execute('CREATE TABLE expenses(id INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT, amount REAL, date TEXT)');
    });
  }
  static Future<double> getTotalSales() async {
    final db = await database;
    var res = await db.rawQuery("SELECT SUM(amount) as total FROM sales");
    return res.first['total'] as double? ?? 0.0;
  }
  static Future<double> getTotalExpenses() async {
    final db = await database;
    var res = await db.rawQuery("SELECT SUM(amount) as total FROM expenses");
    return res.first['total'] as double? ?? 0.0;
  }
}

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}
class _HomeScreenState extends State<HomeScreen> {
  double totalSales = 0, totalExpenses = 0;
  @override
  void initState() { super.initState(); loadData(); }
  loadData() async {
    totalSales = await DatabaseHelper.getTotalSales();
    totalExpenses = await DatabaseHelper.getTotalExpenses();
    setState(() {});
  }
  @override
  Widget build(BuildContext context) {
    double profit = totalSales - totalExpenses;
    return Scaffold(
      appBar: AppBar(title: Text('محاسب سوفت - عام', style: TextStyle(fontWeight: FontWeight.bold)), centerTitle: true, backgroundColor: Colors.teal),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(children: [
          Row(children: [
            Expanded(child: Container(padding: EdgeInsets.all(14), decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: Column(children: [Icon(Icons.trending_up, color: Colors.green), SizedBox(height: 6), Text('المبيعات'), Text('$totalSales ريال', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green))]))),
            SizedBox(width: 10),
            Expanded(child: Container(padding: EdgeInsets.all(14), decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: Column(children: [Icon(Icons.trending_down, color: Colors.red), SizedBox(height: 6), Text('المصروفات'), Text('$totalExpenses ريال', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red))]))),
          ]),
          SizedBox(height: 10),
          Container(width: double.infinity, padding: EdgeInsets.all(16), decoration: BoxDecoration(color: profit >=0 ? Colors.teal.shade50 : Colors.red.shade50, borderRadius: BorderRadius.circular(12), border: Border.all(color: profit >=0 ? Colors.teal : Colors.red)), child: Column(children: [Text('صافي الربح'), Text('$profit ريال', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: profit >=0 ? Colors.teal : Colors.red))])),
          SizedBox(height: 20),
          GridView.count(shrinkWrap: true, physics: NeverScrollableScrollPhysics(), crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, children: [
            _menuBtn(context, 'فاتورة بيع', Icons.point_of_sale, Colors.green, SalesScreen()),
            _menuBtn(context, 'مصروف جديد', Icons.money_off, Colors.red, ExpenseScreen()),
            _menuBtn(context, 'العملاء', Icons.people, Colors.blue, CustomersScreen()),
            _menuBtn(context, 'التقارير', Icons.bar_chart, Colors.orange, ReportsScreen()),
          ]),
        ]),
      ),
      floatingActionButton: FloatingActionButton(onPressed: () => loadData(), child: Icon(Icons.refresh), backgroundColor: Colors.teal),
    );
  }
  Widget _menuBtn(BuildContext ctx, String title, IconData icon, Color color, Widget page) {
    return InkWell(onTap: () => Navigator.push(ctx, MaterialPageRoute(builder: (_) => page)).then((_) => loadData()), child: Container(decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)]), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [CircleAvatar(backgroundColor: color.withOpacity(0.15), radius: 28, child: Icon(icon, color: color, size: 30)), SizedBox(height: 10), Text(title, style: TextStyle(fontWeight: FontWeight.bold))])) );
  }
}

class SalesScreen extends StatefulWidget { @override State<SalesScreen> createState() => _SalesScreenState(); }
class _SalesScreenState extends State<SalesScreen> {
  final _custCtrl = TextEditingController(); final _amountCtrl = TextEditingController(); final _notesCtrl = TextEditingController();
  save() async {
    if (_amountCtrl.text.isEmpty) return;
    final db = await DatabaseHelper.database;
    await db.insert('sales', {'customer': _custCtrl.text.isEmpty ? 'عميل عام' : _custCtrl.text, 'amount': double.tryParse(_amountCtrl.text) ?? 0, 'date': DateFormat('yyyy-MM-dd').format(DateTime.now()), 'notes': _notesCtrl.text});
    Navigator.pop(context);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: Text('فاتورة بيع جديدة'), backgroundColor: Colors.green), body: Padding(padding: EdgeInsets.all(16), child: Column(children: [TextField(controller: _custCtrl, decoration: InputDecoration(labelText: 'اسم العميل', border: OutlineInputBorder(), prefixIcon: Icon(Icons.person))), SizedBox(height: 12), TextField(controller: _amountCtrl, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: 'المبلغ', border: OutlineInputBorder(), prefixIcon: Icon(Icons.attach_money))), SizedBox(height: 12), TextField(controller: _notesCtrl, decoration: InputDecoration(labelText: 'ملاحظات', border: OutlineInputBorder(), prefixIcon: Icon(Icons.note))), SizedBox(height: 20), SizedBox(width: double.infinity, height: 50, child: ElevatedButton(onPressed: save, style: ElevatedButton.styleFrom(backgroundColor: Colors.green), child: Text('حفظ البيع', style: TextStyle(fontSize: 18))))])));
  }
}

class ExpenseScreen extends StatefulWidget { @override State<ExpenseScreen> createState() => _ExpenseScreenState(); }
class _ExpenseScreenState extends State<ExpenseScreen> {
  final _titleCtrl = TextEditingController(); final _amountCtrl = TextEditingController();
  save() async {
    if (_amountCtrl.text.isEmpty) return;
    final db = await DatabaseHelper.database;
    await db.insert('expenses', {'title': _titleCtrl.text.isEmpty ? 'مصروف عام' : _titleCtrl.text, 'amount': double.tryParse(_amountCtrl.text) ?? 0, 'date': DateFormat('yyyy-MM-dd').format(DateTime.now())});
    Navigator.pop(context);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: Text('مصروف جديد'), backgroundColor: Colors.red), body: Padding(padding: EdgeInsets.all(16), child: Column(children: [TextField(controller: _titleCtrl, decoration: InputDecoration(labelText: 'سبب المصروف', border: OutlineInputBorder(), prefixIcon: Icon(Icons.description))), SizedBox(height: 12), TextField(controller: _amountCtrl, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: 'المبلغ', border: OutlineInputBorder(), prefixIcon: Icon(Icons.money_off))), SizedBox(height: 20), SizedBox(width: double.infinity, height: 50, child: ElevatedButton(onPressed: save, style: ElevatedButton.styleFrom(backgroundColor: Colors.red), child: Text('حفظ المصروف', style: TextStyle(fontSize: 18))))])));
  }
}

class CustomersScreen extends StatelessWidget { @override Widget build(BuildContext context) { return Scaffold(appBar: AppBar(title: Text('العملاء'), backgroundColor: Colors.blue), body: Center(child: Text('قريباً - كشف حساب العملاء'))); } }
class ReportsScreen extends StatelessWidget { @override Widget build(BuildContext context) { return Scaffold(appBar: AppBar(title: Text('التقارير'), backgroundColor: Colors.orange), body: Center(child: Text('قريباً - تقارير PDF'))); } }
