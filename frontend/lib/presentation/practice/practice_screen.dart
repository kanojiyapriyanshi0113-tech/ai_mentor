import "package:flutter/material.dart";
import "package:provider/provider.dart";

import "../../core/providers/subscription_provider.dart";
import "models/practice_dummy_models.dart";
import "widgets/bookmarked_question_card.dart";
import "widgets/dpp_card.dart";
import "widgets/mock_test_card.dart";
import "widgets/pyq_card.dart";

class PracticeScreen extends StatefulWidget {
  const PracticeScreen({super.key});

  @override
  State<PracticeScreen> createState() => _PracticeScreenState();
}

class _PracticeScreenState extends State<PracticeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final provider = context.read<SubscriptionProvider>();
      if (provider.summary == null && !provider.isLoadingSummary) {
        provider.loadSummary();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final summary = context.watch<SubscriptionProvider>().summary;

    // PYQs is not part of the Free Trial plan's feature list, so it must
    // not appear at all for free-trial users (not just locked/greyed out).
    // Until the plan is confirmed loaded, default to hiding it so a free
    // trial user never sees content they aren't entitled to, even briefly.
    final showPyqs = summary != null && !summary.isFreeTrial;

    final tabs = <Tab>[
      const Tab(text: "Mock Tests"),
      const Tab(text: "Daily Practice"),
      if (showPyqs) const Tab(text: "PYQs"),
      const Tab(text: "Bookmarked"),
    ];

    final tabViews = <Widget>[
      const _MockTestsTab(),
      const _DailyPracticeTab(),
      if (showPyqs) const _PreviousYearQuestionsTab(),
      const _BookmarkedQuestionsTab(),
    ];

    return DefaultTabController(
      length: tabs.length,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Practice"),
          automaticallyImplyLeading: false,
          bottom: TabBar(
            isScrollable: true,
            tabs: tabs,
          ),
        ),
        body: SafeArea(
          child: TabBarView(
            children: tabViews,
          ),
        ),
      ),
    );
  }
}

class _MockTestsTab extends StatelessWidget {
  const _MockTestsTab();

  @override
  Widget build(BuildContext context) {
    final tests = DummyPracticeRepository.getMockTests();

    if (tests.isEmpty) {
      return const _EmptyState(message: "No mock tests available yet");
    }

    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: tests.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return MockTestCard(test: tests[index], onTap: () {});
      },
    );
  }
}

class _DailyPracticeTab extends StatelessWidget {
  const _DailyPracticeTab();

  @override
  Widget build(BuildContext context) {
    final dpps = DummyPracticeRepository.getDailyPractice();

    if (dpps.isEmpty) {
      return const _EmptyState(message: "No daily practice problems yet");
    }

    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: dpps.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return DppCard(dpp: dpps[index], onTap: () {});
      },
    );
  }
}

class _PreviousYearQuestionsTab extends StatelessWidget {
  const _PreviousYearQuestionsTab();

  @override
  Widget build(BuildContext context) {
    final pyqs = DummyPracticeRepository.getPreviousYearQuestions();

    if (pyqs.isEmpty) {
      return const _EmptyState(message: "No previous year questions available");
    }

    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: pyqs.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return PyqCard(pyq: pyqs[index], onTap: () {});
      },
    );
  }
}

class _BookmarkedQuestionsTab extends StatelessWidget {
  const _BookmarkedQuestionsTab();

  @override
  Widget build(BuildContext context) {
    final bookmarks = DummyPracticeRepository.getBookmarkedQuestions();

    if (bookmarks.isEmpty) {
      return const _EmptyState(message: "You haven't bookmarked any questions yet");
    }

    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: bookmarks.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return BookmarkedQuestionCard(
          question: bookmarks[index],
          onTap: () {},
          onRemoveBookmark: () {},
        );
      },
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String message;

  const _EmptyState({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          message,
          style: TextStyle(color: Colors.grey[600]),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
