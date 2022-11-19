import 'package:flutter/material.dart';

import '../state/application_state.dart';

class YesNoSelection extends StatelessWidget {
  const YesNoSelection(
      {super.key, required this.attending, required this.onSelection});

  final Attending attending;
  final void Function(Attending selection) onSelection;

  @override
  Widget build(BuildContext context) {
    switch (attending) {
      case Attending.yes:
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              ElevatedButton(
                onPressed: () => onSelection(Attending.yes),
                style: ElevatedButton.styleFrom(elevation: 0),
                child: const Text('YES'),
              ),
              const SizedBox(width: 8),
              TextButton(
                onPressed: () => onSelection(Attending.no),
                child: const Text(
                  'NO',
                  style: TextStyle(color: Colors.redAccent),
                ),
              )
            ],
          ),
        );

      case Attending.no:
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              TextButton(
                onPressed: () => onSelection(Attending.yes),
                child: const Text('YES'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () => onSelection(Attending.no),
                style: ElevatedButton.styleFrom(
                    elevation: 0, backgroundColor: Colors.redAccent),
                child: const Text('NO'),
              )
            ],
          ),
        );
      default:
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              ElevatedButton(
                onPressed: () => onSelection(Attending.yes),
                style: ElevatedButton.styleFrom(elevation: 0),
                child: const Text('YES'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () => onSelection(Attending.no),
                style: ElevatedButton.styleFrom(
                    elevation: 0, backgroundColor: Colors.redAccent),
                child: const Text('NO'),
              )
            ],
          ),
        );
    }
  }
}
