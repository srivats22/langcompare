import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:lang_compare/models/api-model.dart';
import 'package:lang_compare/models/apibox.dart';
import 'package:url_launcher/url_launcher.dart';

enum KeyHolders { google, openai }

class ConfigureKeys extends StatefulWidget {
  const ConfigureKeys({super.key});

  @override
  State<ConfigureKeys> createState() => _ConfigureKeysState();
}

class _ConfigureKeysState extends State<ConfigureKeys> {
  final formKey = GlobalKey<FormState>();
  KeyHolders holder = KeyHolders.google;
  TextEditingController apiController = TextEditingController();
  bool isGoogle = true;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          actions: [
            IconButton(
              onPressed: (){
                showDialog(
                  context: context,
                  builder: (context){
                    return AlertDialog(
                      title: const Text("API Info"),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text("Your API Keys are saved on device, only you can see it"),
                          ListTile(
                            onTap: (){
                              _launchUrl('https://makersuite.google.com/app/apikey');
                            },
                            leading: const Icon(Icons.launch),
                            title: const Text("Get Gemini API Key"),
                            subtitle: const Text("Free"),
                          ),
                          ListTile(
                            onTap: (){
                              _launchUrl('https://platform.openai.com/api-keys');
                            },
                            leading: const Icon(Icons.launch),
                            title: const Text("Get Open AI API Key"),
                            subtitle: const Text("Paid"),
                          ),
                        ],
                      ),
                    );
                  }
                );
              },
              tooltip: 'Info',
              icon: const Icon(Icons.info),
            ),
          ],
        ),
        body: ValueListenableBuilder<Box<ApiModel>>(
          valueListenable: ApiBox.getApiKey().listenable(),
          builder: (context, box, _){
            final configuredKeys = box.values.toList().cast<ApiModel>();
            if(configuredKeys.isEmpty){
              return const Center(
                child: Text("No Keys Configured"),
              );
            }
            return ListView.builder(
              shrinkWrap: true,
              padding: const EdgeInsets.all(10),
              itemCount: configuredKeys.length,
              itemBuilder: (context, index){
                return ExpansionTile(
                  title: Text(configuredKeys[index].apiType),
                  children: [
                    Text(configuredKeys[index].apiKey),
                    OutlinedButton(
                      onPressed: (){
                        ApiBox.getApiKey().delete(configuredKeys[index].key);
                      },
                      child: const Text("Delete"),
                    ),
                  ],
                );
              },
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: (){
            showDialog(
              context: context,
              builder: (context){
                return StatefulBuilder(
                  builder: (context, setState){
                    return AlertDialog(
                      title: const Text("Configure Key"),
                      content: Form(
                        key: formKey,
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              RadioListTile(
                                title: const Text("Google"),
                                value: true,
                                groupValue: isGoogle,
                                onChanged: (value) => setState(() => isGoogle = value!),
                              ),
                              RadioListTile(
                                title: const Text("Open AI"),
                                value: false,
                                groupValue: isGoogle,
                                onChanged: (value) => setState(() => isGoogle = value!),
                              ),
                              TextFormField(
                                controller: apiController,
                                decoration: const InputDecoration(
                                  hintText: 'Enter API Key',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: (){
                            Navigator.of(context).pop();
                          },
                          child: const Text("Cancel"),
                        ),
                        ElevatedButton(
                          onPressed: (){
                            var allKeys = ApiBox.getApiKey();
                            if(isGoogle){
                              if(!allKeys.keys.contains('google')){
                                var gKey = ApiModel()
                                    ..apiType = "Google"
                                    ..apiKey = apiController.text;
                                allKeys.put('google', gKey)
                                .whenComplete(() => {
                                  apiController.clear(),
                                  Navigator.of(context).pop(),
                                });
                              }
                              else{
                                Navigator.of(context).pop();
                                var sb = const SnackBar(content: Text("Can't have duplicate keys"));
                                ScaffoldMessenger.of(context).showSnackBar(sb);
                              }
                            }
                            else{
                              if(!allKeys.keys.contains('openai')){
                                var gKey = ApiModel()
                                  ..apiType = "Open AI"
                                  ..apiKey = apiController.text;
                                allKeys.put('openai', gKey)
                                    .whenComplete(() => {
                                      apiController.clear(),
                                  Navigator.of(context).pop(),
                                });
                              }
                              else{
                                apiController.clear();
                                Navigator.of(context).pop();
                                var sb = const SnackBar(content: Text("Can't have duplicate keys"));
                                ScaffoldMessenger.of(context).showSnackBar(sb);
                              }
                            }
                          },
                          child: const Text("Save"),
                        ),
                      ],
                    );
                  },
                );
              }
            );
          },
          tooltip: 'Configure Key',
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      throw Exception('Could not launch $uri');
    }
  }
}
