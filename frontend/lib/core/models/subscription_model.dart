class SubscriptionSummary {
  final String currentPlan;
  final int trialDaysLeft;
  final int aiQuestionsRemaining;
  final int chaptersRemaining;
  final int videosRemaining;
  final int pdfNotesRemaining;
  final int mockTestsRemaining;
  SubscriptionSummary({
    required this.currentPlan,
    required this.trialDaysLeft,
    required this.aiQuestionsRemaining,
    required this.chaptersRemaining,
    required this.videosRemaining,
    required this.pdfNotesRemaining,
    required this.mockTestsRemaining,
  });
  factory SubscriptionSummary.fromApiJson(Map<String, dynamic> json) {
    return SubscriptionSummary(
      currentPlan: json["current_plan"] as String,
      trialDaysLeft: json["trial_days_left"] as int? ?? 0,
      aiQuestionsRemaining: json["ai_questions_remaining"] as int? ?? 0,
      chaptersRemaining: json["chapters_remaining"] as int? ?? 0,
      videosRemaining: json["videos_remaining"] as int? ?? 0,
      pdfNotesRemaining: json["pdf_notes_remaining"] as int? ?? 0,
      mockTestsRemaining: json["mock_tests_remaining"] as int? ?? 0,
    );
  }
  bool get isFreeTrial => currentPlan.toLowerCase().contains("trial");
}

class SubscriptionPlan {
  final String code;
  final String name;
  final int pricePaise;
  final int durationDays;
  final bool isTrial;
  SubscriptionPlan({
    required this.code,
    required this.name,
    required this.pricePaise,
    required this.durationDays,
    required this.isTrial,
  });
  factory SubscriptionPlan.fromApiJson(Map<String, dynamic> json) {
    return SubscriptionPlan(
      code: json["code"] as String,
      name: json["name"] as String,
      pricePaise: json["price_paise"] as int? ?? 0,
      durationDays: json["duration_days"] as int? ?? 0,
      isTrial: json["is_trial"] as bool? ?? false,
    );
  }
  double get priceRupees => pricePaise / 100;
  String get priceLabel => pricePaise == 0 ? "Free" : "\u20B9${priceRupees.toStringAsFixed(0)}";
}

class PlanFeatureConfig {
  final List<String> included;
  final List<String> locked;
  const PlanFeatureConfig({required this.included, required this.locked});
}

const Map<String, PlanFeatureConfig> kPlanFeatureConfig = {
  "free_trial": PlanFeatureConfig(
    included: [
      "7 Days Access",
      "1 Exam",
      "1 Batch",
      "First 5 Chapters",
      "First 5 Video Lectures",
      "First 5 PDF Notes",
      "5 Mock Tests",
      "AI Chat (20 Questions/Day)",
      "Daily Progress",
    ],
    locked: [
      "Live Classes",
      "AI Planner",
      "AI Notes",
      "Document Upload",
      "Image Doubt Upload",
    ],
  ),
  "pro": PlanFeatureConfig(
    included: [
      "All Exams",
      "Maximum 5 Batches",
      "20 Chapters",
      "20 Video Lectures",
      "20 PDF Notes",
      "20 Mock Tests",
      "Previous 2 Years PYQs",
      "AI Chat (100 Questions/Day)",
      "Image Doubt Upload",
      "Image Upload to AI",
      "Document Upload",
      "Study Progress",
      "Performance Analytics",
    ],
    locked: [
      "Live Classes",
      "AI Planner",
      "AI Notes Generator",
    ],
  ),
  "ultra": PlanFeatureConfig(
    included: [
      "Everything in Pro",
      "Maximum 5 Batches",
      "Unlimited Chapters",
      "50 Video Lectures",
      "50 PDF Notes",
      "50 Mock Tests",
      "Live Classes",
      "AI Planner",
      "AI Notes Generator",
      "AI Chat (500 Questions/Day)",
      "Personalized Recommendations",
      "Priority Content Updates",
    ],
    locked: [],
  ),
  "ultra_max": PlanFeatureConfig(
    included: [
      "Everything in Ultra",
      "Unlimited AI Chat",
      "AI Interview",
      "AI Career Guidance",
      "AI Mock Interview",
      "AI Resume Review",
      "AI Revision Planner",
      "AI Test Analysis",
      "Priority Support",
      "Early Access Features",
    ],
    locked: [],
  ),
};

PlanFeatureConfig getPlanFeatureConfig(String code) {
  return kPlanFeatureConfig[code] ??
      const PlanFeatureConfig(included: [], locked: []);
}
