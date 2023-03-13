import 'package:flutter/material.dart';

class HistoryWidget extends StatelessWidget {
  final Map<String, String> data;

  const HistoryWidget({Key? key, required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          title: Text(
            data['title']!,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
          onTap: () {
            showDialog(
              context: context,
              builder: (ctx) {
                return AlertDialog(
                  title: const Text("Result"),
                  content: SingleChildScrollView(
                    child: Text(data['result']!.trim()),
                  ),
                );
              },
            );
          },
        ),
        const Divider(
          height: 2,
          thickness: 2,
        )
      ],
    );
  }
}
