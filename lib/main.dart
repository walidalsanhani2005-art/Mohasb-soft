import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:intl/intl.dart';
import 'customers_page.dart';

void main() => runApp(MaterialApp(home: Home(), debugShowCheckedModeBanner: false));

class DB {
  static Database? d;
  static Future<Database> get db async {
    if (d != null) return d!;
    String p = join(await getDatabasesPath(), 'mohaseb.db');
    d = await openDatabase(p, version: 2, onCreate: (db, v) async {
      await db.execute('CREATE TABLE s(id INTEGER PRIMARY KEY AUTOINCREMENT, amount REAL)');
      await db.execute('CREATE TABLE e(id INTEGER PRIMARY KEY AUTOINCREMENT, amount REAL)');
      await db.execute('CREATE TABLE c(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, phone TEXT, debt REAL)');
    }, onUpgrade: (db, oldV, newV) async {
      await db.execute('CREATE TABLE IF NOT EXISTS c(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, phone TEXT, debt REAL)');
    });
    return d!;
  }
  static Future<double> tot(String t) async {
    final x = await (await db).rawQuery('SELECT SUM(amount) as s FROM $t');
    return (x.first['s'] as num?)?.toDouble() ?? 0;
  }
}

class Home extends StatefulWidget { @override _HomeState createState() => _HomeState(); }
class _HomeState extends State<Home> {
  double s=0,e=0;
  load() async { s = await DB.tot('s'); e = await DB.tot('e'); setState((){}); }
  @override void initState(){ load(); super.initState(); }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('محاسب سوفت 2.0 - عام'), backgroundColor: Colors.teal),
      body: Column(children: [
        Padding(
          padding: EdgeInsets.all(8),
          child: Row(children: [
            Expanded(child: Card(child: Padding(padding: EdgeInsets.all(16), child: Column(children: [Text('المبيعات'), SizedBox(height:4), Text('$s ريال', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold))])))),
            Expanded(child: Card(child: Padding(padding: EdgeInsets.all(16), child: Column(children: [Text('المصروفات'), SizedBox(height:4), Text('$e ريال', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold))])))),
          ]),
        ),
        Card(color: Color(0xFFE0F7FA), margin: EdgeInsets.symmetric(horizontal: 8), child: ListTile(title: Text('صافي الربح:'), trailing: Text('${s-e} ريال', style: TextStyle(color: (s-e)<0?Colors.red:Colors.green, fontSize: 20, fontWeight: FontWeight.bold)))),
        SizedBox(height: 12),
        Expanded(child: GridView.count(crossAxisCount: 2, padding: EdgeInsets.all(12), crossAxisSpacing: 12, mainAxisSpacing: 12, children: [
          InkWell(onTap: () async { final db=await DB.db; await db.insert('s', {'amount': 100}); load(); }, child: Container(decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)]), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.calculate, size: 40, color: Colors.green), SizedBox(height: 8), Text('بيع جديد')]))),
          InkWell(onTap: () async { final db=await DB.db; await db.insert('e', {'amount': 100}); load(); }, child: Container(decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)]), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.money_off, size: 40, color: Colors.red), SizedBox(height: 8), Text('مصروف')]))),
          InkWell(onTap: () { Navigator.push(context, MaterialPageRoute(builder: (c)=> CustomersPage())); }, child: Container(decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)]), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.people, size: 40, color: Colors.blue), SizedBox(height: 8), Text('العملاء')]))),
          InkWell(onTap: () {}, child: Container(decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)]), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.bar_chart, size: 40, color: Colors.orange), SizedBox(height: 8), Text('التقارير')]))),
        ]))
      ]),
      floatingActionButton: FloatingActionButton(child: Icon(Icons.refresh), onPressed: load, backgroundColor: Colors.teal),
    );
  }
}
