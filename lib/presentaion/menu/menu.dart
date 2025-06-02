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
    GroupPage(),
    SearchPage(),
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
      body: pages[selectedNavIndex],
       // Use the selected page widget
       backgroundColor: Colors.grey[200],
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Container(
            height: 66,
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: const BorderRadius.all(Radius.circular(24)),
              boxShadow: [
                BoxShadow(
                  color : Colors.grey,
                  blurRadius: 3,
                  offset: const Offset(5, 5),
                ),
                BoxShadow(
                  color: Colors.white,
                  blurRadius: 5,
                  offset: const Offset(-3, -5),
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
  const Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        SizedBox(height: 20),
        Text('Chat', style: TextStyle(fontSize: 24)),
      ],
    ),
  );
}

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) => 
  const Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        SizedBox(height: 20),
        Text('Search', style: TextStyle(fontSize: 24)),
      ],
    ),
  );
}

class GroupPage extends StatelessWidget {
  const GroupPage({super.key});

  @override
  Widget build(BuildContext context) => 
  const Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        SizedBox(height: 20),
        Text('Group', style: TextStyle(fontSize: 24)),
      ],
    ),
  );
}

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) => 
  const Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        SizedBox(height: 20),
        Text('Settings', style: TextStyle(fontSize: 24)),
      ],
    ),
  );
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) => 
  const Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        SizedBox(height: 20),
        Text('Profile', style: TextStyle(fontSize: 24)),
      ],
    ),
  );
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