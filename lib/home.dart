import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:loading_animation_widget/loading_animation_widget.dart';

import 'common.dart';
import 'configurekeys.dart';
import 'models/api-model.dart';
import 'models/apibox.dart';
import 'models/language-model.dart';
import 'models/languagebox.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  TextEditingController questionController = TextEditingController();
  List<String> langList = [];
  String baseLang = lang.first;
  String compareLang = "";
  List baseLangAnsList = [];
  List compareLangAnsList = [];
  ScrollController baseAnsScrollController = ScrollController();
  ScrollController compareAnsScrollController = ScrollController();
  bool isLoading = false;
  bool isAnsVisible = false;
  bool showApiWarning = false;
  bool showModelSelection = false;
  String model = "";
  String apikey = "";

  @override
  void initState() {
    super.initState();
    int compareStrings(String a, String b) => a.compareTo(b);
    lang.sort(compareStrings);
    initializer();
  }

  void initializer() {
    checkApiKeys();
    loadLangs();
    if (showApiWarning) {
      Future(showApiInfoDialog);
    } else {
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

  void compareSyntax() async {
    setState(() {
      isLoading = true;
    });
    if (model == "Google") {
      try {
        final baseLangResp = await http.post(
          Uri.parse(
              "https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key=$apikey"),
          headers: <String, String>{'Content-type': 'application/json'},
          body: jsonEncode({
            "contents": [
              {
                "parts": [
                  {
                    "text": """
              You are an experienced assistant who has vast knowledge in $baseLang.
              Explain what ${questionController.text} does.
              Give the user the syntax for creating a ${questionController.text},
              and an example.
              The output needs to be in markdown
              """
                  }
                ]
              }
            ]
          }),
        );
        final compareLangResp = await http.post(
          Uri.parse(
              "https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key=$apikey"),
          headers: <String, String>{'Content-type': 'application/json'},
          body: jsonEncode({
            "contents": [
              {
                "parts": [
                  {
                    "text": """
              You are an experienced assistant who has vast knowledge in $compareLang.
              Explain what ${questionController.text} does.
              Give the user the syntax for creating a ${questionController.text},
              and an example.
              The output needs to be in markdown
              """
                  }
                ]
              }
            ]
          }),
        );

        if (baseLangResp.statusCode == 200 &&
            compareLangResp.statusCode == 200) {
          var baseLangRsp = jsonDecode(baseLangResp.body);
          var compareLangRsp = jsonDecode(compareLangResp.body);
          if (baseLangAnsList.isNotEmpty && compareLangAnsList.isNotEmpty) {
            setState(() {
              baseLangAnsList.remove(0);
              compareLangAnsList.remove(0);
            });
          }
          setState(() {
            baseLangAnsList.add(Text(
              baseLang,
              style: Theme.of(context).textTheme.displayMedium,
            ));
            baseLangAnsList.add(
              Markdown(
                shrinkWrap: true,
                data: baseLangRsp['candidates'][0]['content']['parts'][0]
                    ['text'],
              ),
            );
            compareLangAnsList.add(Text(
              compareLang,
              style: Theme.of(context).textTheme.displayMedium,
            ));
            compareLangAnsList.add(Markdown(
              shrinkWrap: true,
              data: compareLangRsp['candidates'][0]['content']['parts'][0]
                  ['text'],
            ));
            isLoading = false;
            isAnsVisible = true;
          });
        }
      } catch (e) {
        generateErrorDialog(e.toString());
      }
    }
    if(model == "Open AI") {
      try {
        final baseLangResp = await http.post(
          Uri.parse("https://api.openai.com/v1/chat/completions"),
          headers: <String, String>{
            'Content-type': 'application/json',
            HttpHeaders.authorizationHeader: 'Bearer $apikey',
          },
          body: jsonEncode({
            "model": "gpt-3.5-turbo",
            "messages": [
              {
                "role": "system",
                "content": """
              You are an experienced assistant who has vast knowledge in $baseLang.
              Explain what ${questionController.text} does.
              Give the user the syntax for creating a ${questionController.text},
              and an example.
              The output needs to be in markdown
              """
              }
            ]
          }),
        );
        final compareLangResp = await http.post(
          Uri.parse("https://api.openai.com/v1/chat/completions"),
          headers: <String, String>{
            'Content-type': 'application/json',
            HttpHeaders.authorizationHeader: 'Bearer $apikey',
          },
          body: jsonEncode({
            "model": "gpt-3.5-turbo",
            "messages": [
              {
                "role": "system",
                "content": """
              You are an experienced assistant who has vast knowledge in $baseLang.
              Explain what ${questionController.text} does.
              Give the user the syntax for creating a ${questionController.text},
              and an example.
              The output needs to be in markdown
              """
              }
            ]
          }),
        );

        if (baseLangResp.statusCode == 200 &&
            compareLangResp.statusCode == 200) {
          var baseLangRsp = jsonDecode(baseLangResp.body);
          var compareLangRsp = jsonDecode(compareLangResp.body);
          if (baseLangAnsList.isNotEmpty && compareLangAnsList.isNotEmpty) {
            setState(() {
              baseLangAnsList.remove(0);
              compareLangAnsList.remove(0);
            });
          }
          setState(() {
            baseLangAnsList.add(Text(
              baseLang,
              style: Theme.of(context).textTheme.displayMedium,
            ));
            baseLangAnsList.add(
              Markdown(
                shrinkWrap: true,
                data: baseLangRsp['choices'][0]['message']['content'],
              ),
            );
            compareLangAnsList.add(Text(
              compareLang,
              style: Theme.of(context).textTheme.displayMedium,
            ));
            compareLangAnsList.add(Markdown(
              shrinkWrap: true,
              data: compareLangRsp['choices'][0]['message']['content'],
            ));
            isLoading = false;
            isAnsVisible = true;
          });
        }
      } catch (e) {
        generateErrorDialog(e.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Center(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  "Ask a question to see syntax differences between languages",
                  style: Theme.of(context).textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 50, right: 50, top: 20),
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
                                    content:
                                        const Text("All Fields Are Required"),
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
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: DropdownMenu(
                      initialSelection: baseLang,
                      label: const Text('Base Language'),
                      onSelected: (String? selectedLang) {
                        setState(() {
                          baseLang = selectedLang!;
                        });
                      },
                      dropdownMenuEntries: lang.map((String value) {
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
                    child: Text(
                      "VS",
                      style: Theme.of(context)
                          .textTheme
                          .displayMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: DropdownMenu(
                      initialSelection: compareLang,
                      label: const Text('Compare Language'),
                      onSelected: (String? selectedLang) {
                        setState(() {
                          compareLang = selectedLang!;
                        });
                      },
                      dropdownMenuEntries: lang.map((String value) {
                        return DropdownMenuEntry(
                          enabled: baseLang != value,
                          value: value,
                          label: value,
                        );
                      }).toList(),
                    ),
                  ),
                ],
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
              FilledButton.tonal(
                onPressed: () {
                  compareSyntax();
                },
                child: const Text("Compare"),
              ),
              const Divider(),
              Visibility(
                visible: isLoading,
                child: LoadingAnimationWidget.newtonCradle(
                  color: Theme.of(context).colorScheme.primary,
                  size: 200,
                ),
              ),
              Visibility(
                visible: isAnsVisible,
                child: Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 250,
                        child: Scrollbar(
                          controller: baseAnsScrollController,
                          thumbVisibility: true,
                          child: ListView.builder(
                            shrinkWrap: true,
                            controller: baseAnsScrollController,
                            itemCount: baseLangAnsList.length,
                            itemBuilder: (builder, index) {
                              return baseLangAnsList[index];
                            },
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: SizedBox(
                        height: 250,
                        child: Scrollbar(
                          controller: compareAnsScrollController,
                          thumbVisibility: true,
                          child: ListView.builder(
                            shrinkWrap: true,
                            controller: compareAnsScrollController,
                            itemCount: compareLangAnsList.length,
                            itemBuilder: (builder, index) {
                              return compareLangAnsList[index];
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void generateErrorDialog(String errorMsg) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("An Error Occured"),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  Text(errorMsg),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text("Try Again"),
              ),
            ],
          );
        });
  }
}
