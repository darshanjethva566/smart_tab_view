import 'package:flutter/material.dart';
import 'package:smart_tab_view/smart_tab_view.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SmartTabView Example',
      theme: ThemeData(primarySwatch: Colors.orange),
      home: const ExampleHome(),
    );
  }
}

class ExampleHome extends StatelessWidget {
  const ExampleHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("SmartTabView Example")),
      body: SmartTabView(

        isScrollable: true,
        verticalTabWidth: 60,
        tabPosition: TabPosition.left,
        tabs: const [

          Tab(icon: Icon(Icons.info), ),
          Tab(icon: Icon(Icons.star), ),
          Tab(icon: Icon(Icons.timeline),),
          Tab(icon: Icon(Icons.check), ),
        ],
        sections: const [
          ExampleSection(title: 'Overview', color: Colors.orange),
          ExampleSection(title: 'Benefits', color: Colors.green),
          ExampleSection(title: 'Process', color: Colors.blue),
          ExampleSection(title: 'Requirement', color: Colors.purple),
        ],
      ),
    );
  }
}

class ExampleSection extends StatelessWidget {
  final String title;
  final Color color;
  const ExampleSection({super.key, required this.title, required this.color});
  @override
  Widget build(BuildContext context) {
    return Container(
      color: color.withOpacity(0.1),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(
          40,
              (i) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Text('$title Line ${i + 1}', style: const TextStyle(fontSize: 13)),
          ),
        ),
      ),
    );
  }
}
