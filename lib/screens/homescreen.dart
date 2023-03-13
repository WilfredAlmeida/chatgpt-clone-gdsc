import 'dart:convert';

import 'package:chatgpt_clone_wilfred/widgets/history_tile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  var historyWidgets = [];
  List<Map<String, String>> historyWidgetsData = [];
  TextEditingController controller = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    Future.wait([getDataFromFirestore()]);
    super.initState();
  }

  Future<void> getDataFromFirestore() async {
    FirebaseFirestore.instance.collection("history").get().then((value) {
      for (var i = 0; i < value.docs.length; i++) {
        setState(() {
          historyWidgetsData.add({
            "title": value.docs[i]['title'],
            "result": value.docs[i]['result']
          });
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Chat GPT Clone"),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                // height: 100,
                child: historyWidgetsData.isEmpty
                    ? const Center(
                        child: Text(
                          "No History Found",
                          textAlign: TextAlign.center,
                        ),
                      )
                    : ListView.builder(
                        itemBuilder: (c, i) {
                          return HistoryWidget(data: historyWidgetsData[i]);
                        },
                        itemCount: historyWidgetsData.length,
                      ),
              ),
              SizedBox(
                height: 100,
                child: Row(
                  children: [
                    SizedBox(
                      width: 350,
                      child: TextField(controller: controller),
                    ),
                    _isLoading
                        ? const CircularProgressIndicator()
                        : IconButton(
                            onPressed: () async {
                              String input = controller.text;

                              if (input.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Enter Some Input"),
                                  ),
                                );
                                return;
                              }

                              setState(() {
                                _isLoading = true;
                              });

                              var uri = Uri.parse(
                                  "https://api.openai.com/v1/completions");

                              var body = json.encode({
                                "model": "text-davinci-001",
                                "prompt": input,
                                "temperature": 0.6,
                                "max_tokens": 1000
                              });

                              var headers = {
                                'Authorization':
                                    'Bearer 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',
                                'Content-Type': 'application/json'
                              };

                              var response = await http.post(uri,
                                  body: body, headers: headers);

                              if (response.statusCode != 200) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Something went wrong"),
                                  ),
                                );
                                return;
                              }

                              var result = jsonDecode(response.body);

                              var resultText = result["choices"][0]['text'];

                              setState(() {
                                // historyWidgets.add(
                                //     HistoryWidget(data: resultText));
                                historyWidgetsData.add(
                                    {"title": input, "result": resultText});
                                _isLoading = false;
                              });

                              await FirebaseFirestore.instance
                                  .collection("history")
                                  .add({"title": input, "result": resultText});
                            },
                            icon: const Icon(Icons.send),
                          )
                  ],
                ),
              )
            ],
          ),
        ));
  }
}
