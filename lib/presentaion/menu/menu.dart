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

  int selectedNavIndex = 0;

  void animateIcons(index){
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Menu'),
      ),
      body: Center(
        child: Text(
          'Select a menu item using the navigation bar below.',
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 8.0), // Add padding to prevent overflow
          child: Container(
            height: 66,
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8), // Reduce vertical margin
            decoration: BoxDecoration(
              color: const Color.fromARGB(227, 70, 70, 70),
              borderRadius: const BorderRadius.all(Radius.circular(24)),
              boxShadow: [
                BoxShadow(
                  color: const Color.fromARGB(51, 0, 0, 0), // 0.2 * 255 = 51
                  blurRadius: 20,
                  offset: const Offset(0, 20),
                  // changes position of shadow
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
                    onTap: (){
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

class AnimatedBar extends StatelessWidget {
  const AnimatedBar({
    super.key,
    required this.isActive ,
  });

  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: isActive ? 20 : 0, // Adjust width based on isActive
      height: 4,
      margin: const EdgeInsets.only(bottom: 2),
      decoration: BoxDecoration(
        color: const Color.from(alpha: 1, red: 0.537, green: 0.898, blue: 0.961),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}