import 'rive_model.dart';

class NavToolModel{
  final String title;
  final RiveModel rive;

  NavToolModel({
    required this.title,
    required this.rive,
  });
}

List<NavToolModel> navTools = [
  NavToolModel(
    title: 'Chat',
    rive: RiveModel(
      src: 'assets/RiveAssets/icons.riv',
      artboard: 'CHAT',
      stateMachineName: 'CHAT_Interactivity',
    ),
  ),
  NavToolModel(
    title: 'Search',
    rive: RiveModel(
      src: 'assets/RiveAssets/icons.riv',
      artboard: 'SEARCH',
      stateMachineName: 'SEARCH_Interactivity',
    ),
  ),
  NavToolModel(
    title: 'Timer',
    rive: RiveModel(
      src: 'assets/RiveAssets/icons.riv',
      artboard: 'TIMER',
      stateMachineName: 'TIMER_Interactivity',
    ),
  ),
  NavToolModel(
    title: 'Reload',
    rive: RiveModel(
      src: 'assets/RiveAssets/icons.riv',
      artboard: 'RELOAD',
      stateMachineName: 'RELOAD_Interactivity',
    ),
  ),
  NavToolModel(
    title: 'Home',
    rive: RiveModel(
      src: 'assets/RiveAssets/icons.riv',
      artboard: 'HOME',
      stateMachineName: 'HOME_Interactivity',
    ),
  ),
  NavToolModel(
    title: 'Star',
    rive: RiveModel(
      src: 'assets/RiveAssets/icons.riv',
      artboard: 'STAR',
      stateMachineName: 'STAR_Interactivity',
    ),
  ),
  NavToolModel(
    title: 'Audio',
    rive: RiveModel(
      src: 'assets/RiveAssets/icons.riv',
      artboard: 'AUDIO',
      stateMachineName: 'AUDIO_Interactivity',
    ),
  ),
  NavToolModel(
    title: 'Settings',
    rive: RiveModel(
      src: 'assets/RiveAssets/icons.riv',
      artboard: 'SETTINGS',
      stateMachineName: 'SETTINGS_Interactivity',
    ),
  ),
  NavToolModel(
    title: 'User',
    rive: RiveModel(
      src: 'assets/RiveAssets/icons.riv',
      artboard: 'USER',
      stateMachineName: 'USER_Interactivity',
    ),
  ),
];