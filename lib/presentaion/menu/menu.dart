import 'package:flutter/material.dart';
import 'package:rive/rive.dart';
import 'package:transfer/models/rive_item_model.dart';

class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  List<SMIBool?> riveIconsInputs = [];
  List<StateMachineController> controllers = [];
  int selectedNavIndex = 0;

  // List of page widgets
  final List<Widget> pages = [
    ChatPage(),
    SearchPage(),
    HomePage(),
    SettingsPage(),
    ProfilePage(),
  ];

  void animateIcons(index) {
    final input = riveIconsInputs[index];
    if (input != null) {
      input.change(true);
      Future.delayed(const Duration(seconds: 1), () {
        input.change(false);
      });
    }
  }

  void rivInit(Artboard artboard, int index, dynamic riveItem) {
    StateMachineController? controller = StateMachineController.fromArtboard(
      artboard,
      riveItem,
    );
    if (controller != null) {
      artboard.addController(controller);

      controllers.add(controller);
      final input = controller.findInput<bool>('active') as SMIBool?;
      setState(() {
        riveIconsInputs[index] = input;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    riveIconsInputs = List<SMIBool?>.filled(bottomNavItems.length, null);
  }

  @override
  void dispose() {
    for (final controller in controllers) {
      controller.dispose();
    }
    controllers.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Menu'),
      ),
      body: pages[selectedNavIndex], // Use the selected page widget
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Container(
            height: 66,
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            decoration: BoxDecoration(
              color: const Color.fromARGB(227, 70, 70, 70),
              borderRadius: const BorderRadius.all(Radius.circular(24)),
              boxShadow: [
                BoxShadow(
                  color: const Color.fromARGB(51, 0, 0, 0),
                  blurRadius: 20,
                  offset: const Offset(0, 20),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(
                bottomNavItems.length,
                (index) {
                  final riveItem = bottomNavItems[index].rive;

                  return GestureDetector(
                    onTap: () {
                      animateIcons(index);
                      setState(() {
                        selectedNavIndex = index;
                      });
                    },
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnimatedBar(isActive: selectedNavIndex == index),
                        Opacity(
                          opacity: selectedNavIndex == index ? 1 : 0.5,
                          child: SizedBox(
                            width: 36,
                            height: 36,
                            child: RiveAnimation.asset(
                              riveItem.src,
                              artboard: riveItem.artboard,
                              onInit: (artboard) {
                                rivInit(artboard, index, riveItem.stateMachineName);
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Dummy page widgets for demonstration
class ChatPage extends StatelessWidget {
  const ChatPage({super.key});

  @override
  Widget build(BuildContext context) => 
  const Center(child: Text('Chat Page'));
}

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) => const Center(child: Text('Search Page'));
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) => const Center(child: Text('Home Page'));
}

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) => const Center(child: Text('Settings Page'));
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) => const Center(child: Text('Profile Page'));
}

class AnimatedBar extends StatelessWidget {
  const AnimatedBar({
    super.key,
    required this.isActive,
  });

  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: isActive ? 20 : 0,
      height: 4,
      margin: const EdgeInsets.only(bottom: 2),
      decoration: BoxDecoration(
        color: const Color(0xFF89E5F5),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}