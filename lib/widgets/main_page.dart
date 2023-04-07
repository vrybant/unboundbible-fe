import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:unboundbible/widgets/bible_page.dart';
import 'package:unboundbible/widgets/search.dart';
import 'package:unboundbible/widgets/shelf_page.dart';
import 'package:unboundbible/controllers/counter.dart';

final counter = Counter();

class MainPage extends StatelessWidget {
  final List<Widget> pages = [
    BiblePage(),
    SearchPage(),
    SearchPage(),
    ShelfPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) => Scaffold(
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.blue,
          iconSize: 28,
          selectedFontSize: 12,
          onTap: (value) => counter.update(value),
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Библия',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.business),
              label: 'Поиск',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.school),
              label: 'Глава',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: 'Перевод',
            ),
          ],
          currentIndex: counter.value,
          selectedItemColor: Colors.amber[800],
        ),
        body: IndexedStack(
          index: counter.value,
          children: pages,
        ),
      ),
    );
  }
}
