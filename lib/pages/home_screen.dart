import 'package:flutter/material.dart';
import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:my_app/pages/audio_recording_screen.dart';
import 'package:my_app/pages/profile_screen.dart';
import 'package:my_app/pages/recording_list_screen.dart';
import 'package:permission_handler/permission_handler.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  var _bottomNavIndex = 0;

  List<Widget> pages = [];

  final iconList = <IconData>[
    Icons.home_rounded,
    Icons.person_rounded,
  ];

  late PermissionStatus microphonePermissionStatus;

  Future<void> getMicrophonePermission() async {
    // Check the current permission status for the microphone.
    microphonePermissionStatus = await Permission.microphone.status;

    // If the permission is not granted, request permission from the user.
    if (microphonePermissionStatus != PermissionStatus.granted) {
      microphonePermissionStatus = await Permission.microphone.request();
    }

    // Handle the permission request result.
    switch (microphonePermissionStatus) {
      case PermissionStatus.granted:
        // The user granted permission.

        break;
      case PermissionStatus.denied:
        // The user denied permission.
        break;
      case PermissionStatus.permanentlyDenied:
        // The user has permanently denied permission.
        break;
      case PermissionStatus.restricted:
        // The user doesn't have the permission to use the microphone.
        break;
      case PermissionStatus.limited:
        // The user didn't answer the permission request.
        break;
      case PermissionStatus.provisional:
        // The user didn't answer the permission request.
        break;
    }
  }

  @override
  void initState() {
    // if (recordingsBox.get('recordingsbox') != null)
    // hiveDatabaseHandler.getrecordingsbox();
    pages = [
      // const RecordingViewScreen(),
      const RecordingListScreen(),
      const ProfileScreen(),
    ];
    getMicrophonePermission();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (microphonePermissionStatus == PermissionStatus.granted) {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const AudioRecordingScreen()),
            );
          } else {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Microphone permission needed'),
                content: const Text(
                    'Go to Settings and allow AI Audio Insight to access your microphone'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Dismiss'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      openAppSettings();
                      getMicrophonePermission();
                    },
                    child: const Text('Settings'),
                  ),
                ],
              ),
            );
          }
        },
        backgroundColor: Colors.blue,
        child: const Icon(Icons.mic),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: AnimatedBottomNavigationBar(
        icons: iconList,
        activeIndex: _bottomNavIndex,
        notchSmoothness: NotchSmoothness.verySmoothEdge,
        gapLocation: GapLocation.center,
        leftCornerRadius: 32,
        rightCornerRadius: 32,
        onTap: (index) => setState(() => _bottomNavIndex = index),
        activeColor: Colors.blue,
      ),
      body: pages[_bottomNavIndex],
    );
  }
}
