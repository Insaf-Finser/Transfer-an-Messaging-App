import 'rive_model.dart';

class NavItemModel {
  final String title;
  final RiveModel rive;

  NavItemModel({
    required this.title,
    required this.rive,
  });
}

List<NavItemModel> bottomNavItems = [
  NavItemModel(
    title: 'Chat',
    rive: RiveModel(
      src: 'assets/animations/animated_icons.riv',
      artboard: 'CHAT',
      stateMachineName: 'CHAT_Interactivity',
    ),
  ),
  NavItemModel(
    title: 'Groups',
    rive: RiveModel(
      src: 'assets/animations/animated_icons2.riv',
      artboard: 'Network',
      stateMachineName: 'State Machine 1',
    ),
  ),
  NavItemModel(
    title: 'Search',
    rive: RiveModel(
      src: 'assets/animations/animated_icons.riv',
      artboard: 'SEARCH',
      stateMachineName: 'SEARCH_Interactivity',
    ),
  ),
  
  NavItemModel(
    title: 'Settings',
    rive: RiveModel(
      src: 'assets/animations/animated_icons.riv',
      artboard: 'SETTINGS',
      stateMachineName: 'SETTINGS_Interactivity',
    ),
  ),
  NavItemModel(
    title: 'User',
    rive: RiveModel(
      src: 'assets/animations/animated_icons.riv',
      artboard: 'USER',
      stateMachineName: 'USER_Interactivity',
    ),
  ),
];
