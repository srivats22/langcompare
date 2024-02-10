import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:http/http.dart' as http;
import 'package:loading_animation_widget/loading_animation_widget.dart';

class MobileCompare extends StatefulWidget {
  final String question, baseLang, compareLang, model, apikey;
  const MobileCompare(this.question, this.baseLang, this.compareLang,
      this.model, this.apikey,
      {super.key});

  @override
  State<MobileCompare> createState() => _MobileCompareState();
}

class _MobileCompareState extends State<MobileCompare> {
  bool isLoading = true;
  List ans = [];

  void getAnswer() async {
    if(widget.model == "Google"){
      try{
        final baseLangResp = await http.post(
          Uri.parse(
              "https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key=${widget.apikey}"),
          headers: <String, String>{'Content-type': 'application/json'},
          body: jsonEncode({
            "contents": [
              {
                "parts": [
                  {
                    "text": """
              You are an experienced assistant who has vast knowledge in ${widget.baseLang} and ${widget.compareLang}.
              Explain what ${widget.question} does.
              Give the user the syntax for creating a ${widget.question}
              in both ${widget.baseLang} and ${widget.compareLang},
              and an example.
              The output needs to be in markdown
              """
                  }
                ]
              }
            ]
          }),
        );
        if(baseLangResp.statusCode == 200){
          var resp = jsonDecode(baseLangResp.body);
          setState(() {
            ans.add(
              SizedBox(
                width: MediaQuery.of(context).size.width * .75,
                child: Markdown(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  data: resp['candidates'][0]['content']['parts'][0]['text'],
                ),
              ),
            );
            isLoading = false;
          });
        }
      }
      catch(e){
        generateErrorDialog(e.toString());
      }
    }
    else{
      try{
        final baseLangResp = await http.post(
          Uri.parse('https://api.openai.com/v1/chat/completions'),
          headers: <String, String>{
            'Content-type': 'application/json',
            HttpHeaders.authorizationHeader: 'Bearer ${widget.apikey}',
          },
          body: jsonEncode({
            "model": "gpt-3.5-turbo",
            "messages": [
              {
                "role": "system",
                "content": """
              You are an experienced assistant who has vast knowledge in ${widget.baseLang} and ${widget.compareLang}.
              Explain what ${widget.question} does.
              Give the user the syntax for creating a ${widget.question}
              in both ${widget.baseLang} and ${widget.compareLang},
              and an example.
              The output needs to be in markdown
              """
              }
            ]
          }),
        );
        if(baseLangResp.statusCode == 200){
          var resp = jsonDecode(baseLangResp.body);
          setState(() {
            ans.add(
              SizedBox(
                width: MediaQuery.of(context).size.width * .75,
                child: Markdown(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  data: resp['choices'][0]['message']['content'],
                ),
              ),
            );
            isLoading = false;
          });
        }
      }
      catch(e){
        generateErrorDialog(e.toString());
      }
    }
  }

  @override
  void initState() {
    super.initState();
    getAnswer();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(),
        body: isLoading
            ? Center(
                child: LoadingAnimationWidget.newtonCradle(
                  color: Theme.of(context).colorScheme.primary,
                  size: 200,
                ),
              )
            : ListView.builder(
              shrinkWrap: true,
              itemCount: ans.length,
              itemBuilder: (context, index) {
                return ans[index];
              },
            ),
      ),
    );
  }

  void generateErrorDialog(String errorMsg){
    showDialog(
        context: context,
        builder: (context){
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
                onPressed: (){
                  Navigator.of(context).pop();
                },
                child: const Text("Try Again"),
              ),
            ],
          );
        }
    );
  }
}
