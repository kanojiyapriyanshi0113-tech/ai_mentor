class AppRoutes {
  AppRoutes._();

  static const splash = "/";
  static const onboarding = "/onboarding";
  static const login = "/login";
  static const register = "/register";
  static const forgotPassword = "/forgot-password";
  static const examSelection = "/exam-selection";

  static const home = "/home";
  static const courses = "/courses";
  static const practice = "/practice";
  static const profile = "/profile";
  static const aiMentor = "/ai-mentor";

  static const settings = "/settings";
  static const help = "/help";
  static const upgradePlan = "/upgrade-plan";

  // Teacher module
  static const teacherDashboard = "/teacher/dashboard";
  static const teacherBatches = "/teacher/batches";
  static const teacherSubjects = "/teacher/subjects";
  static const teacherChapters = "/teacher/chapters";
  static const teacherLectures = "/teacher/lectures";
  static const teacherPdfs = "/teacher/pdfs";
  static const teacherMockTests = "/teacher/mock-tests";
  static const teacherPyqs = "/teacher/pyqs";
  static const teacherNotifications = "/teacher/notifications";

  // Admin module
  static const adminDashboard = "/admin/dashboard";
  static const adminTeachers = "/admin/teachers";
  static const adminStudents = "/admin/students";
  static const adminSubscriptions = "/admin/subscriptions";
  static const adminCoupons = "/admin/coupons";
  static const adminReports = "/admin/reports";
  static const adminSettings = "/admin/settings";
}
