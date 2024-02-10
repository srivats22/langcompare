import 'package:flutter/material.dart';
import 'package:lang_compare/home.dart';
import 'package:lang_compare/mobilehome.dart';
import 'package:lang_compare/settings.dart';
import 'package:platform_identifier/platform_identifier.dart';

class Navi extends StatefulWidget {
  const Navi({super.key});

  @override
  State<Navi> createState() => _NaviState();
}

enum NaviOptions { home, settings }

class _NaviState extends State<Navi> {
  NaviOptions naviView = NaviOptions.home;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Lang Compare"),
          centerTitle: false,
        ),
        body: Column(
          children: [
            Align(
              alignment: Alignment.topCenter,
              child: SegmentedButton(
                segments: const [
                  ButtonSegment(
                    value: NaviOptions.home,
                    label: Text('Home')
                  ),
                  ButtonSegment(
                      value: NaviOptions.settings,
                      label: Text('Settings')
                  ),
                ],
                selected: <NaviOptions>{naviView},
                onSelectionChanged: (Set<NaviOptions> selection){
                  setState(() {
                    naviView = selection.first;
                  });
                },
              ),
            ),
            Expanded(
              child: naviView.index == 0 ? buildHomeView() : const Settings(),
            )
          ],
        ),
      ),
    );
  }

  Widget buildHomeView(){
    if(PlatformIdentifier.isMobile
    || PlatformIdentifier.isMobileBrowser){
      return const MobileHome();
    }
    return const Home();
  }
}
