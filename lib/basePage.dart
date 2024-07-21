import 'package:flutter/material.dart';
import 'package:okter/utils/color_pallet.dart';
import 'package:okter/screens/calender_page.dart';
import 'package:okter/screens/friends_page.dart';
import 'package:okter/screens/personalBest_page.dart';
import 'package:okter/screens/settings_page.dart';
import 'package:okter/screens/programs_page.dart';

Widget okterDrawerScaffold(context, bodycontent) {
  return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const SettingsPage()));
            },
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      extendBodyBehindAppBar: true,
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.groups),
            label: 'Venner',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.fitness_center),
            label: 'Programmer',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: 'Kalender',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.emoji_events),
            label: 'Rekorder',
          ),
          /*
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil',
          ),
          */
        ],
        currentIndex: 0,
        backgroundColor: themeColorPallet['grey dark'],
        //fixedColor: Colors.transparent,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white,
        onTap: (index) {
          Navigator.of(context).push(_createRoute(index));
        },
      ),
      body: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
        return Container(
          height: constraints.maxHeight,
          width: constraints.maxWidth,
          color: themeColorPallet['grey dark'],
          child: Padding(
              padding: const EdgeInsets.all(16),
              child: SingleChildScrollView(child: bodycontent)),
        );
      }));
}

Route _createRoute(int index) {
  List<Widget> pages = [];
  pages.add(const FriendsPage());
  pages.add(const ProgramsPage());
  pages.add(const CalenderPage());
  pages.add(const PersonalBestPage());
  pages.add(const SettingsPage());
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => pages[index],
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(0.0, 1.0);
      const end = Offset.zero;
      const curve = Curves.ease;

      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

      return SlideTransition(
        position: animation.drive(tween),
        child: child,
      );
    },
  );
}

Widget okterScaffold(name, context, bodycontent) {
  final currentWidth = MediaQuery.of(context).size.width;
  double paddingWidth = 6.0;
  if (currentWidth > 540) {
    paddingWidth = currentWidth / 5;
  }
  if (currentWidth > 700) {
    paddingWidth = currentWidth / 4;
  }
  return Scaffold(
      appBar: AppBar(
        backgroundColor: themeColorPallet['grey dark'],
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            size: 24,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          name,
          style: const TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
        return Container(
          padding: EdgeInsets.only(left: paddingWidth, right: paddingWidth),
          height: constraints.maxHeight,
          width: constraints.maxWidth,
          color: themeColorPallet['grey dark'],
          child: Padding(
              padding: const EdgeInsets.all(16),
              child: SingleChildScrollView(child: bodycontent)),
        );
      }));
}

Widget okterSignInScaffold(name, context, bodycontent) {
  final currentWidth = MediaQuery.of(context).size.width;
  double paddingWidth = 6.0;
  if (currentWidth > 540) {
    paddingWidth = currentWidth / 5;
  }
  if (currentWidth > 700) {
    paddingWidth = currentWidth / 4;
  }
  return Scaffold(body: LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
    return Container(
      padding: EdgeInsets.only(left: paddingWidth, right: paddingWidth),
      height: constraints.maxHeight,
      width: constraints.maxWidth,
      color: themeColorPallet['grey dark'],
      child: Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(child: bodycontent)),
    );
  }));
}

Widget okterAddButtonScaffold(name, bottomNavigation, context, bodycontent) {
  final currentWidth = MediaQuery.of(context).size.width;
  double paddingWidth = 6.0;
  if (currentWidth > 540) {
    paddingWidth = currentWidth / 5;
  }
  if (currentWidth > 700) {
    paddingWidth = currentWidth / 4;
  }
  return Scaffold(
      bottomNavigationBar: bottomNavigation,
      appBar: AppBar(
        leading: Icon(Icons.work_outline),
        backgroundColor: themeColorPallet['grey dark'],
        elevation: 0,
        title: Text(
          name,
          style: const TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
        return Container(
          padding: EdgeInsets.only(left: paddingWidth, right: paddingWidth),
          height: constraints.maxHeight,
          width: constraints.maxWidth,
          color: themeColorPallet['grey dark'],
          child: Padding(
              padding: const EdgeInsets.all(16),
              child: SingleChildScrollView(child: bodycontent)),
        );
      }));
}

Widget okterBackAddButtonScaffold(
    name, List<Widget> actions, context, bodycontent) {
  final currentWidth = MediaQuery.of(context).size.width;
  double paddingWidth = 6.0;
  if (currentWidth > 540) {
    paddingWidth = currentWidth / 5;
  }
  if (currentWidth > 700) {
    paddingWidth = currentWidth / 4;
  }
  return Scaffold(
      bottomNavigationBar: AppBar(
        backgroundColor: themeColorPallet['grey dark'],
        elevation: 0,
        actions: actions,
        title: Text(
          name,
          style: const TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
        return Container(
          padding: EdgeInsets.only(left: paddingWidth, right: paddingWidth),
          height: constraints.maxHeight,
          width: constraints.maxWidth,
          color: themeColorPallet['grey dark'],
          child: Padding(
              padding: const EdgeInsets.all(16),
              child: SingleChildScrollView(child: bodycontent)),
        );
      }));
}
