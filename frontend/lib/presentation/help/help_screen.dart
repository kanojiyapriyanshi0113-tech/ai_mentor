import "package:flutter/material.dart";

class _FaqItem {
  final String question;
  final String answer;

  const _FaqItem({required this.question, required this.answer});
}

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  static const _faqs = [
    _FaqItem(
      question: "How do I change my exam category?",
      answer: "Go to Profile > Current Exam > Change, and select your new exam.",
    ),
    _FaqItem(
      question: "How does the free trial work?",
      answer: "You get 7 days of full access when you register. You can upgrade anytime from your Profile.",
    ),
    _FaqItem(
      question: "How do I ask a doubt to AI Mentor?",
      answer: "Go to the AI Mentor tab and type your question, or tap one of the suggested prompts.",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Help & Support")),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.08),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Icon(Icons.support_agent, color: Theme.of(context).primaryColor, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Need more help?", style: TextStyle(fontWeight: FontWeight.w700)),
                        Text("Reach out to our support team", style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text("Frequently Asked Questions", style: Theme.of(context).textTheme.titleSmall?.copyWith(color: Colors.grey[600])),
            const SizedBox(height: 8),
            ..._faqs.map((faq) {
              return ExpansionTile(
                tilePadding: EdgeInsets.zero,
                title: Text(faq.question, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5)),
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(faq.answer, style: TextStyle(fontSize: 13, color: Colors.grey[700])),
                  ),
                ],
              );
            }),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.email_outlined),
              title: const Text("Email Support"),
              subtitle: const Text("support@aimentor.app"),
            ),
          ],
        ),
      ),
    );
  }
}
