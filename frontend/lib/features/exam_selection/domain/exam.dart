class ExamOption {
  final String code;
  final String name;
  final String icon;

  const ExamOption({required this.code, required this.name, required this.icon});

  static const List<ExamOption> all = [
    ExamOption(code: 'UPSC', name: 'UPSC', icon: '🏛️'),
    ExamOption(code: 'SSC', name: 'SSC', icon: '📝'),
    ExamOption(code: 'BANKING', name: 'Banking', icon: '🏦'),
    ExamOption(code: 'RAILWAY', name: 'Railway', icon: '🚆'),
    ExamOption(code: 'NEET', name: 'NEET', icon: '🩺'),
    ExamOption(code: 'JEE', name: 'JEE', icon: '⚙️'),
    ExamOption(code: 'STATE_PSC', name: 'State PSC', icon: '🏢'),
  ];
}
