import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:intl/intl.dart';

void main() => runApp(MaterialApp(home: Home(), debugShowCheckedModeBanner: false));

class DB {
  static Database? d;
  static Future<Database> get db async {
    if (d != null) return d!;
    String p = join(await getDatabasesPath(), 'm.db');
    d = await openDatabase(p, version: 1, onCreate: (db, v) async {
      await db.execute('CREATE TABLE s(id INTEGER PRIMARY KEY, c TEXT, a REAL, d TEXT)');
      await db.execute('CREATE TABLE e(id INTEGER PRIMARY KEY, t TEXT, a REAL, d TEXT)');
    });
    return d!;
  }
  static Future<double> tot(String t) async {
    final x = await (await db).rawQuery('SELECT SUM(a) as s FROM $t');
    return (x.first['s'] as num?)?.toDouble() ?? 0;
  }
}

class Home extends StatefulWidget { @override State<Home> createState() => _HomeState(); }
class _HomeState extends State<Home> {
  double s=0,e=0;
  void initState(){ super.initState(); load(); }
  load() async { s=await DB.tot('s'); e=await DB.tot('e'); setState((){}); }
  @override
  Widget build(BuildContext context) {
    double p=s-e;
    return Scaffold(
      appBar: AppBar(title: Text('محاسب سوفت 2.0 - عام'), backgroundColor: Colors.teal, centerTitle: true),
      body: Padding(padding: EdgeInsets.all(16), child: Column(children: [
        Row(children: [
          Expanded(child: Card(child: Padding(padding: EdgeInsets.all(16), child: Column(children: [Text('المبيعات'), Text('$s ريال', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold))])))),
          SizedBox(width: 8),
          Expanded(child: Card(child: Padding(padding: EdgeInsets.all(16), child: Column(children: [Text('المصروفات'), Text('$e ريال', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold))])))),
        ]),
        Card(color: Colors.teal.shade50, child: Padding(padding: EdgeInsets.all(20), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('صافي الربح:', style: TextStyle(fontSize: 18)), Text('$p ريال', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: p>=0?Colors.teal:Colors.red))]))),
        SizedBox(height: 20),
        Expanded(child: GridView.count(crossAxisCount: 2, children: [
          _b('بيع جديد', Icons.point_of_sale, Colors.green, () => Navigator.push(context, MaterialPageRoute(builder: (_)=>Sale())).then((_)=>load())),
          _b('مصروف', Icons.money_off, Colors.red, () => Navigator.push(context, MaterialPageRoute(builder: (_)=>Exp())).then((_)=>load())),
          _b('العملاء', Icons.people, Colors.blue, (){}),
          _b('التقارير', Icons.bar_chart, Colors.orange, (){}),
        ]))
      ])),
      floatingActionButton: FloatingActionButton(onPressed: load, child: Icon(Icons.refresh), backgroundColor: Colors.teal),
    );
  }
  Widget _b(String t, IconData i, Color c, VoidCallback o) => Card(child: InkWell(onTap: o, child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(i, size: 40, color: c), SizedBox(height: 8), Text(t, style: TextStyle(fontWeight: FontWeight.bold)) ])));
}

class Sale extends StatelessWidget {
  final c1=TextEditingController(); final c2=TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: Text('بيع جديد'), backgroundColor: Colors.green), body: Padding(padding: EdgeInsets.all(16), child: Column(children: [
      TextField(controller: c1, decoration: InputDecoration(labelText: 'العميل', border: OutlineInputBorder())),
      SizedBox(height: 10),
      TextField(controller: c2, decoration: InputDecoration(labelText: 'المبلغ', border: OutlineInputBorder()), keyboardType: TextInputType.number),
      SizedBox(height: 20),
      ElevatedButton(onPressed: () async { if(c2.text.isEmpty) return; final db=await DB.db; await db.insert('s', {'c':c1.text, 'a':double.tryParse(c2.text)??0, 'd':DateFormat('yyyy-MM-dd').format(DateTime.now())}); Navigator.pop(context); }, child: Text('حفظ'), style: ElevatedButton.styleFrom(backgroundColor: Colors.green, minimumSize: Size(double.infinity, 50)))
    ])));
  }
}

class Exp extends StatelessWidget {
  final c1=TextEditingController(); final c2=TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: Text('مصروف'), backgroundColor: Colors.red), body: Padding(padding: EdgeInsets.all(16), child: Column(children: [
      TextField(controller: c1, decoration: InputDecoration(labelText: 'البيان', border: OutlineInputBorder())),
      SizedBox(height: 10),
      TextField(controller: c2, decoration: InputDecoration(labelText: 'المبلغ', border: OutlineInputBorder()), keyboardType: TextInputType.number),
      SizedBox(height: 20),
      ElevatedButton(onPressed: () async { if(c2.text.isEmpty) return; final db=await DB.db; await db.insert('e', {'t':c1.text, 'a':double.tryParse(c2.text)??0, 'd':DateFormat('yyyy-MM-dd').format(DateTime.now())}); Navigator.pop(context); }, child: Text('حفظ'), style: ElevatedButton.styleFrom(backgroundColor: Colors.red, minimumSize: Size(double.infinity, 50)))
    ])));
  }
}
