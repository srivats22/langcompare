import 'package:easy_dynamic_theme/easy_dynamic_theme.dart';
import 'package:flutter/material.dart';
import 'package:lang_compare/configurekeys.dart';
import 'package:lang_compare/manage-language.dart';

class Settings extends StatelessWidget {
  const Settings({super.key});

  @override
  Widget build(BuildContext context) {
    bool isDarkModeOn = Theme.of(context).brightness == Brightness.dark;
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                "About",
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              Text(
                "Lang Compare, is an experimental Gen AI application. \nThat allows you to compare syntax between two programming languages.",
                textAlign: TextAlign.start,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const Divider(
                indent: 20,
                endIndent: 20,
              ),
              Text(
                "App Settings",
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              ListTile(
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const ConfigureKeys()));
                },
                title: const Text("API Key"),
                subtitle: const Text("Manage API Key"),
                trailing: IconButton.filledTonal(
                  onPressed: () {},
                  icon: const Icon(Icons.arrow_forward),
                ),
              ),
              ListTile(
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const ManageLanguage()));
                },
                title: const Text("Languages"),
                subtitle: const Text("Manage Programming languages"),
                trailing: IconButton.filledTonal(
                  onPressed: () {},
                  icon: const Icon(Icons.arrow_forward),
                ),
              ),
              ListTile(
                title: const Text("Theme"),
                subtitle: Text(isDarkModeOn ? "Dark Mode" : "Light Mode"),
                trailing: Switch(
                  onChanged: (isChanged) {
                    EasyDynamicTheme.of(context).changeTheme();
                  },
                  value: isDarkModeOn,
                ),
              ),
              const AboutListTile(
                aboutBoxChildren: [
                  Text(
                      "An Experimental Gen AI application for comparing syntax between programming languages")
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
