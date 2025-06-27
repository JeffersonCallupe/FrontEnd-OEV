import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:oev_mobile_app/presentation/providers/auth_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  static const String name = 'home_screen';
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends ConsumerState<HomeScreen> {
  int _selectedIndex = 0;
  bool _showFilterChip = false; // Controla la visibilidad del Chip

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: ref.read(authProvider).token?.name ?? 'xdxd test',
      home: Scaffold(
        backgroundColor: const Color.fromRGBO(30, 30, 44, 0.996),
        appBar: AppBar(
          backgroundColor: const Color(0xff2a2c3e),
          leading: Padding(
            padding: const EdgeInsets.all(10),
            child: Image.asset('assets/images/logo_unmsm.png'),
          ),
          actions: [
            IconButton(
              onPressed: () {
                // Acción para el ícono de filtrado
                setState(() {
                  _showFilterChip =
                      true; // Mostrar el Chip al presionar el filtro
                });
              },
              icon: const Icon(Icons.filter_list, color: Colors.white),
            ),
            IconButton(
              onPressed: () {
                context.push('/profile');
              },
              icon: const CircleAvatar(
                backgroundColor: Colors.white54,
                child: Icon(
                  Icons.person,
                  color: Color(0xff2a2c3e),
                ),
              ),
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    ref.read(authProvider).token?.name ?? 'Usuario',
                    style: const TextStyle(color: Colors.white),
                  ),
                  Text(
                    ref.read(authProvider).token?.role ?? 'Role',
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 20),
            IconButton(
              onPressed: () {
                ref.read(authProvider.notifier).logout();
              },
              icon: const Icon(
                Icons.logout,
                color: Color(0xFFFFFFFF),
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: _buildBody(),
            ),
            if (_showFilterChip)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Chip(
                  label: const Text('Talleres'),
                  onDeleted: () {
                    setState(() {
                      _showFilterChip = false; // Ocultar el Chip al eliminarlo
                    });
                  },
                ),
              ),
          ],
        ),
        bottomNavigationBar: Theme(
          data: Theme.of(context).copyWith(
            canvasColor: const Color(0xff2a2c3e),
          ),
          child: BottomNavigationBar(
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.home, color: Colors.lightBlue),
                label: '',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.menu_book, color: Colors.white),
                label: '',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.video_call, color: Colors.white),
                label: '',
              ),
            ],
            currentIndex: _selectedIndex,
            onTap: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            showSelectedLabels: false,
            showUnselectedLabels: false,
            type: BottomNavigationBarType.fixed,
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return const Center(
          child: Text('Inicio', style: TextStyle(color: Colors.white)),
        );
      default:
        return const Center(
          child: Text('VistaDefecto', style: TextStyle(color: Colors.white)),
        );
    }
  }
}
