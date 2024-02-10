import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:lang_compare/models/language-model.dart';
import 'package:lang_compare/models/languagebox.dart';

class ManageLanguage extends StatefulWidget {
  const ManageLanguage({super.key});

  @override
  State<ManageLanguage> createState() => _ManageLanguageState();
}

class _ManageLanguageState extends State<ManageLanguage> {
  TextEditingController newLang = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(),
        body: Column(
          children: [
            Expanded(
              child: ValueListenableBuilder<Box<LanguageModel>>(
                valueListenable: LanguageBox.getLanguages().listenable(),
                builder: (context, box, _) {
                  final lang = box.values.toList().cast<LanguageModel>();
                  return ListView.builder(
                    shrinkWrap: true,
                    padding: const EdgeInsets.all(10),
                    itemCount: lang.length,
                    itemBuilder: (context, index) {
                      return Card(
                        child: ListTile(
                          title: Text(lang[index].languageName),
                          trailing: IconButton.filledTonal(
                            onPressed: (){
                              LanguageBox.getLanguages().delete(lang[index].key);
                              var sb = const SnackBar(content: Text("Delete"));
                              ScaffoldMessenger.of(context).showSnackBar(sb);
                            },
                            icon: const Icon(Icons.delete),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                controller: newLang,
                onFieldSubmitted: (newValue){
                  var box = LanguageBox.getLanguages();
                  var newLangObj = LanguageModel()
                    ..languageName = newLang.text;
                  box.add(newLangObj)
                      .whenComplete(() => newLang.clear(),);
                },
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                  hintText: 'Enter New Language',
                  suffixIcon: Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: IconButton.filledTonal(
                      onPressed: () {
                        var box = LanguageBox.getLanguages();
                        var newLangObj = LanguageModel()
                          ..languageName = newLang.text;
                        box.add(newLangObj)
                        .whenComplete(() => newLang.clear(),);
                      },
                      icon: const Icon(Icons.arrow_upward),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
