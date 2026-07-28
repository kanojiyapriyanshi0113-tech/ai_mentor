import "package:flutter/material.dart";

class SuggestedPrompts extends StatelessWidget {
  final List<String> prompts;
  final ValueChanged<String> onSelect;

  const SuggestedPrompts({
    super.key,
    required this.prompts,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: prompts.map((prompt) {
        return InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => onSelect(prompt),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.08),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Theme.of(context).primaryColor.withOpacity(0.25)),
            ),
            child: Text(
              prompt,
              style: TextStyle(fontSize: 12.5, color: Theme.of(context).primaryColor, fontWeight: FontWeight.w500),
            ),
          ),
        );
      }).toList(),
    );
  }
}
