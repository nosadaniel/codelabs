import 'dart:async';

import 'package:flutter/material.dart';

import '../model/guest_book_message.dart';
import '../screens/widgets/paragraph.dart';
import 'widgets/styled_button.dart';

class GuestBook extends StatelessWidget {
  GuestBook({super.key, required this.addMessage, required this.message});

  final GlobalKey<FormState> _formKey =
      GlobalKey<FormState>(debugLabel: 'GuestBook');
  final TextEditingController _controller = TextEditingController();
  final FutureOr<void> Function(String message) addMessage;
  final List<GuestBookMessage> message;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8.0),
          child: Form(
            key: _formKey,
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _controller,
                    decoration:
                        const InputDecoration(hintText: 'Leave a message'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Enter your message to continue';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 8),
                StyledButton(
                    child: Row(
                      // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: const [
                        Icon(Icons.send),
                        SizedBox(width: 4),
                        Text('SEND')
                      ],
                    ),
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        await addMessage(_controller.text);
                      }
                    }),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: message
              .map<Paragraph>(
                  (msg) => Paragraph('${msg.name} : ${msg.message}'))
              .toList(),
        )
      ],
    );
  }
}
