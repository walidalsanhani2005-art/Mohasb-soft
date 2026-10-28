import 'package:flutter/material.dart';
import 'main.dart';

class CustomersPage extends StatefulWidget {
  @override
  _CustomersPageState createState() => _CustomersPageState();
}

class _CustomersPageState extends State<CustomersPage> {
  List<Map> customers = [];

  getData() async {
    final db = await DB.db;
    final data = await db.rawQuery('SELECT * FROM c');
    setState(() => customers = data);
  }

  @override
  void initState() {
    getData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('العملاء'), backgroundColor: Colors.teal),
      body: customers.isEmpty 
      ? Center(child: Text('لا يوجد عملاء بعد'))
      : ListView.builder(
        itemCount: customers.length,
        itemBuilder: (context, i) {
          return Card(
            child: ListTile(
              leading: Icon(Icons.person, color: Colors.blue),
              title: Text(customers[i]['name'] ?? ''),
              subtitle: Text(customers[i]['phone'] ?? ''),
              trailing: Text('${customers[i]['debt']} ريال'),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        backgroundColor: Colors.teal,
        onPressed: () async {
          final db = await DB.db;
          await db.insert('c', {'name': 'عميل جديد', 'phone': '777000000', 'debt': 0});
          getData();
        },
      ),
    );
  }
}
