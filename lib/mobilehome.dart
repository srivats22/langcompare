import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:lang_compare/configurekeys.dart';
import 'package:lang_compare/mobilecompare.dart';
import 'package:lang_compare/models/api-model.dart';
import 'package:lang_compare/models/apibox.dart';
import 'package:lang_compare/models/language-model.dart';
import 'package:lang_compare/models/languagebox.dart';

import 'common.dart';

class MobileHome extends StatefulWidget {
  const MobileHome({super.key});

  @override
  State<MobileHome> createState() => _MobileHomeState();
}

class _MobileHomeState extends State<MobileHome> {
  TextEditingController questionController = TextEditingController();
  List<String> langList = [];
  String baseLang = "";
  String compareLang = "";
  bool isLoading = true;
  bool showApiWarning = false;
  bool showModelSelection = false;
  String model = "";
  String apikey = "";

  @override
  void initState() {
    super.initState();
    initializer();
  }

  void initializer() {
    checkApiKeys();
    loadLangs();
    if (showApiWarning) {
      Future(showApiInfoDialog);
    }
    else{
      showModelSelection = true;
    }
    setState(() {
      isLoading = false;
    });
  }

  void checkApiKeys() {
    final apiBox = ApiBox.getApiKey();
    if (apiBox.isEmpty) {
      setState(() {
        showApiWarning = true;
      });
    }
  }

  void loadLangs() async {
    final box = LanguageBox.getLanguages();
    if (box.isEmpty) {
      for (var i = 0; i < lang.length; i++) {
        var l = LanguageModel()..languageName = lang[i];
        final box = LanguageBox.getLanguages();
        box.add(l);
      }
      for (var l in box.values) {
        langList.add(l.languageName);
      }
    } else {
      var langs = box.values.toList().cast<LanguageModel>();
      for (var element in langs) {
        langList.add(element.languageName);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: isLoading
            ? (const Center(
                child: CircularProgressIndicator(),
              ))
            : ListView(
                shrinkWrap: true,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      "Ask a question to see syntax differences between languages",
                      style: Theme.of(context).textTheme.headlineSmall,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 50, right: 50),
                    child: TextField(
                      controller: questionController,
                      decoration: InputDecoration(
                        hintText: 'Map Object Syntax',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                        suffixIcon: Padding(
                          padding: const EdgeInsets.only(right: 5),
                          child: IconButton.filledTonal(
                            onPressed: () {
                              if (questionController.text.isEmpty ||
                                  baseLang == "" ||
                                  compareLang == "") {
                                showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        title: const Text("Error"),
                                        content: const Text(
                                            "All Fields Are Required"),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                            child: const Text("Got It"),
                                          ),
                                        ],
                                      );
                                    });
                              }
                            },
                            icon: const Icon(Icons.arrow_forward),
                          ),
                        ),
                      ),
                      maxLines: 1,
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: DropdownMenu(
                      width: MediaQuery.of(context).size.width * .95,
                      menuHeight: 200,
                      enableFilter: true,
                      initialSelection: "",
                      label: const Text('Base Language'),
                      onSelected: (String? selectedLang) {
                        setState(() {
                          baseLang = selectedLang!;
                        });
                      },
                      dropdownMenuEntries: langList.map((String value) {
                        return DropdownMenuEntry(
                          enabled: compareLang != value,
                          value: value,
                          label: value,
                        );
                      }).toList(),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: DropdownMenu(
                      width: MediaQuery.of(context).size.width * .95,
                      menuHeight: 200,
                      initialSelection: compareLang,
                      label: const Text('Compare Language'),
                      onSelected: (String? selectedLang) {
                        setState(() {
                          compareLang = selectedLang!;
                        });
                      },
                      dropdownMenuEntries: langList.map((String value) {
                        return DropdownMenuEntry(
                          enabled: baseLang != value,
                          value: value,
                          label: value,
                        );
                      }).toList(),
                    ),
                  ),
                  Visibility(
                    visible: showModelSelection,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ValueListenableBuilder<Box<ApiModel>>(
                        valueListenable: ApiBox.getApiKey().listenable(),
                        builder: (context, box, _) {
                          final configuredKeys =
                          box.values.toList().cast<ApiModel>();
                          return DropdownMenu<ApiModel>(
                            width: MediaQuery.of(context).size.width * .95,
                            initialSelection: configuredKeys.first,
                            label: const Text("Model"),
                            onSelected: (ApiModel? selectedModel) {
                              setState(() {
                                model = selectedModel!.apiType;
                                apikey = selectedModel.apiKey;
                              });
                            },
                            dropdownMenuEntries: box.values.map((ApiModel value) {
                              return DropdownMenuEntry(
                                value: value,
                                label: value.apiType,
                              );
                            }).toList(),
                          );
                        },
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: FilledButton.tonal(
                      onPressed: () {
                        if (baseLang == compareLang ||
                            questionController.text.isEmpty ||
                            compareLang == "" ||
                            baseLang == ""
                        || model == "") {
                          showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: const Text("Error"),
                                  content: const Text(
                                      "Both Base, Compare language, question and model is required before proceeding"),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: const Text("Ok"),
                                    ),
                                  ],
                                );
                              });
                        } else {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => MobileCompare(
                                questionController.text,
                                baseLang,
                                compareLang,
                                model,
                                apikey,
                              ),
                            ),
                          );
                        }
                      },
                      child: const Text("Compare"),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  void showApiInfoDialog() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("Info"),
            content: const Text("Configure API Key before proceeding"),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const ConfigureKeys()));
                },
                child: const Text("Configure"),
              ),
            ],
          );
        });
  }
}
