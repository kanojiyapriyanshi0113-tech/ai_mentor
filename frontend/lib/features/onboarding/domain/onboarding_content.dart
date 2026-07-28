class OnboardingContent {
  final String title;
  final String description;
  final String assetPath;

  const OnboardingContent({
    required this.title,
    required this.description,
    required this.assetPath,
  });

  static const List<OnboardingContent> pages = [
    OnboardingContent(
      title: 'Personalized AI Mentor',
      description: 'Get exam guidance tailored to your prep — UPSC, SSC, Banking, Railway, NEET, JEE, State PSC.',
      assetPath: 'assets/onboarding/ai_mentor.png',
    ),
    OnboardingContent(
      title: 'Ask Anything, Anytime',
      description: 'Chat with your AI mentor for doubts, strategy, and motivation — 24/7.',
      assetPath: 'assets/onboarding/chat.png',
    ),
    OnboardingContent(
      title: 'Start Your Free Trial',
      description: 'Enjoy 7 days free access to premium mentoring features.',
      assetPath: 'assets/onboarding/trial.png',
    ),
  ];
}
