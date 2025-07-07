import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:oev_mobile_app/presentation/providers/auth_provider.dart';
import 'package:oev_mobile_app/presentation/screens/chatbot/chatbot_screen.dart';
import 'package:oev_mobile_app/presentation/widgets/course/course_list.dart';
import 'package:oev_mobile_app/presentation/widgets/course/my_courses.dart';

class HomeScreen extends ConsumerStatefulWidget {
  static const String name = 'home_screen';
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends ConsumerState<HomeScreen> {
  int _selectedIndex = 0;
  final List<String> _titles = ["", "", "", ""];
  final Color selectedColor = Color(0xFF12CDD9);
  final Color unselectedColor = Colors.white;
  final Color backgroundColor = Color(0xFF252836);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: ref.read(authProvider).token?.name ?? 'User Mock',
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
          ],
        ),
        bottomNavigationBar: Theme(
          data: Theme.of(context).copyWith(
            canvasColor: const Color(0xff2a2c3e),
          ),
          child: BottomNavigationBar(
            items: List.generate(3, (index) {
              bool isSelected = _selectedIndex == index;
              return BottomNavigationBarItem(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isSelected ? backgroundColor : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 10, right: 10),
                    child: Icon(
                      index == 0
                          ? Icons.home
                          : index == 1
                              ? Icons.menu_book
                              : Icons.smart_toy_rounded,
                      color: isSelected ? selectedColor : unselectedColor,
                    ),
                  ),
                ),
                label: '',
              );
            }),
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
          child: CourseList(),
        );
      case 1:
        return const Center(
          child: MyCourses(),
        );
      case 2:
        return  Center(
          child: ChatScreen(),
        );
      default:
        return const Center(
          child: Text('VistaDefecto', style: TextStyle(color: Colors.white)),
        );
    }
  }
}
