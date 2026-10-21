import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'theme.dart';
import 'screens/home_screen.dart';
import 'screens/carte_screen.dart';
import 'screens/graphiques_screen.dart';
import 'screens/requetes_screen.dart';
import 'screens/recherche_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: kBg,
  ));
  runApp(const ClearDataApp());
}

class ClearDataApp extends StatelessWidget {
  const ClearDataApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ClearData',
      theme: appTheme,
      debugShowCheckedModeBanner: false,
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _index = 0;

  late final List<Widget> _screens = [
    HomeScreen(onNavigate: (i) => setState(() => _index = i)),
    const CarteScreen(),
    const GraphiquesScreen(),
    const RequetesScreen(),
    const RechercheScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _screens),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: kBorder)),
        ),
        child: BottomNavigationBar(
          currentIndex: _index,
          onTap: (i) => setState(() => _index = i),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Accueil'),
            BottomNavigationBarItem(icon: Icon(Icons.map_outlined), activeIcon: Icon(Icons.map), label: 'Carte'),
            BottomNavigationBarItem(icon: Icon(Icons.bar_chart_outlined), activeIcon: Icon(Icons.bar_chart), label: 'Graphiques'),
            BottomNavigationBarItem(icon: Icon(Icons.storage_outlined), activeIcon: Icon(Icons.storage), label: 'Requêtes'),
            BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Recherche'),
          ],
        ),
      ),
    );
  }
}
