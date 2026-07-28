class AdminDashboardModel {
  final int totalStudents;
  final int totalTeachers;
  final int totalRevenuePaise;
  final int activeSubscriptions;
  final int activeBatches;
  final int upcomingLiveClasses;
  final int aiUsageToday;

  AdminDashboardModel({
    required this.totalStudents,
    required this.totalTeachers,
    required this.totalRevenuePaise,
    required this.activeSubscriptions,
    required this.activeBatches,
    required this.upcomingLiveClasses,
    required this.aiUsageToday,
  });

  factory AdminDashboardModel.fromJson(Map<String, dynamic> json) => AdminDashboardModel(
        totalStudents: json['total_students'] as int? ?? 0,
        totalTeachers: json['total_teachers'] as int? ?? 0,
        totalRevenuePaise: json['total_revenue_paise'] as int? ?? 0,
        activeSubscriptions: json['active_subscriptions'] as int? ?? 0,
        activeBatches: json['active_batches'] as int? ?? 0,
        upcomingLiveClasses: json['upcoming_live_classes'] as int? ?? 0,
        aiUsageToday: json['ai_usage_today'] as int? ?? 0,
      );
}

class TeacherAccountModel {
  final String id;
  final String name;
  final String email;
  final bool isApproved;
  final bool isSuspended;
  final DateTime createdAt;

  TeacherAccountModel({
    required this.id,
    required this.name,
    required this.email,
    required this.isApproved,
    required this.isSuspended,
    required this.createdAt,
  });

  factory TeacherAccountModel.fromJson(Map<String, dynamic> json) => TeacherAccountModel(
        id: json['id'] as String,
        name: json['name'] as String,
        email: json['email'] as String,
        isApproved: json['is_approved'] as bool? ?? false,
        isSuspended: json['is_suspended'] as bool? ?? false,
        createdAt: DateTime.parse(json['created_at'] as String),
      );
}

class StudentAccountModel {
  final String id;
  final String name;
  final String email;
  final bool isBlocked;
  final bool premium;
  final DateTime createdAt;

  StudentAccountModel({
    required this.id,
    required this.name,
    required this.email,
    required this.isBlocked,
    required this.premium,
    required this.createdAt,
  });

  factory StudentAccountModel.fromJson(Map<String, dynamic> json) => StudentAccountModel(
        id: json['id'] as String,
        name: json['name'] as String,
        email: json['email'] as String,
        isBlocked: json['is_blocked'] as bool? ?? false,
        premium: json['premium'] as bool? ?? false,
        createdAt: DateTime.parse(json['created_at'] as String),
      );
}

class AdminPlanModel {
  final int id;
  final String code;
  final String name;
  final int pricePaise;
  final int durationDays;
  final bool isTrial;
  final bool isActive;

  AdminPlanModel({
    required this.id,
    required this.code,
    required this.name,
    required this.pricePaise,
    required this.durationDays,
    required this.isTrial,
    required this.isActive,
  });

  factory AdminPlanModel.fromJson(Map<String, dynamic> json) => AdminPlanModel(
        id: json['id'] as int,
        code: json['code'] as String,
        name: json['name'] as String,
        pricePaise: json['price_paise'] as int? ?? 0,
        durationDays: json['duration_days'] as int? ?? 0,
        isTrial: json['is_trial'] as bool? ?? false,
        isActive: json['is_active'] as bool? ?? false,
      );
}

/// Matches the response shape of GET /plans (dto.PlanResponse on the
/// backend) - a plain plan catalog entry. Deliberately separate from
/// AdminPlanModel: that endpoint's response has no "id" or "is_active"
/// field, so parsing it with AdminPlanModel.fromJson would crash on the
/// non-nullable id cast. Used only for the Subscription Overview section.
class PlanCatalogModel {
  final String code;
  final String name;
  final int pricePaise;
  final int durationDays;
  final bool isTrial;

  PlanCatalogModel({
    required this.code,
    required this.name,
    required this.pricePaise,
    required this.durationDays,
    required this.isTrial,
  });

  factory PlanCatalogModel.fromJson(Map<String, dynamic> json) => PlanCatalogModel(
        code: json['code'] as String,
        name: json['name'] as String,
        pricePaise: json['price_paise'] as int? ?? 0,
        durationDays: json['duration_days'] as int? ?? 0,
        isTrial: json['is_trial'] as bool? ?? false,
      );
}

class CouponModel {
  final String id;
  final String code;
  final int discountPercent;
  final int discountAmountPaise;
  final int maxUses;
  final int usedCount;
  final DateTime validFrom;
  final DateTime validUntil;
  final bool isActive;

  CouponModel({
    required this.id,
    required this.code,
    required this.discountPercent,
    required this.discountAmountPaise,
    required this.maxUses,
    required this.usedCount,
    required this.validFrom,
    required this.validUntil,
    required this.isActive,
  });

  factory CouponModel.fromJson(Map<String, dynamic> json) => CouponModel(
        id: json['id'] as String,
        code: json['code'] as String,
        discountPercent: json['discount_percent'] as int? ?? 0,
        discountAmountPaise: json['discount_amount_paise'] as int? ?? 0,
        maxUses: json['max_uses'] as int? ?? 0,
        usedCount: json['used_count'] as int? ?? 0,
        validFrom: DateTime.parse(json['valid_from'] as String),
        validUntil: DateTime.parse(json['valid_until'] as String),
        isActive: json['is_active'] as bool? ?? false,
      );
}

class PaymentModel {
  final String id;
  final String userId;
  final String? subscriptionId;
  final int amountPaise;
  final String status;
  final String paymentMethod;
  final String transactionRef;
  final DateTime createdAt;
  final DateTime? refundedAt;

  PaymentModel({
    required this.id,
    required this.userId,
    this.subscriptionId,
    required this.amountPaise,
    required this.status,
    required this.paymentMethod,
    required this.transactionRef,
    required this.createdAt,
    this.refundedAt,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) => PaymentModel(
        id: json['id'] as String,
        userId: json['user_id'] as String,
        subscriptionId: json['subscription_id'] as String?,
        amountPaise: json['amount_paise'] as int? ?? 0,
        status: json['status'] as String,
        paymentMethod: json['payment_method'] as String? ?? '',
        transactionRef: json['transaction_ref'] as String? ?? '',
        createdAt: DateTime.parse(json['created_at'] as String),
        refundedAt: json['refunded_at'] != null ? DateTime.parse(json['refunded_at'] as String) : null,
      );
}

class RevenueReportModel {
  final int totalRevenuePaise;
  final int totalPayments;
  final int refundedPaise;

  RevenueReportModel({
    required this.totalRevenuePaise,
    required this.totalPayments,
    required this.refundedPaise,
  });

  factory RevenueReportModel.fromJson(Map<String, dynamic> json) => RevenueReportModel(
        totalRevenuePaise: json['total_revenue_paise'] as int? ?? 0,
        totalPayments: json['total_payments'] as int? ?? 0,
        refundedPaise: json['refunded_paise'] as int? ?? 0,
      );
}

class StudentsReportModel {
  final int totalStudents;
  final int newStudents30d;
  final int activeTrials;
  final int premiumStudents;

  StudentsReportModel({
    required this.totalStudents,
    required this.newStudents30d,
    required this.activeTrials,
    required this.premiumStudents,
  });

  factory StudentsReportModel.fromJson(Map<String, dynamic> json) => StudentsReportModel(
        totalStudents: json['total_students'] as int? ?? 0,
        newStudents30d: json['new_students_30d'] as int? ?? 0,
        activeTrials: json['active_trials'] as int? ?? 0,
        premiumStudents: json['premium_students'] as int? ?? 0,
      );
}

class CoursesReportModel {
  final int totalBatches;
  final int totalSubjects;
  final int totalChapters;
  final int totalLectures;
  final int totalMockTests;

  CoursesReportModel({
    required this.totalBatches,
    required this.totalSubjects,
    required this.totalChapters,
    required this.totalLectures,
    required this.totalMockTests,
  });

  factory CoursesReportModel.fromJson(Map<String, dynamic> json) => CoursesReportModel(
        totalBatches: json['total_batches'] as int? ?? 0,
        totalSubjects: json['total_subjects'] as int? ?? 0,
        totalChapters: json['total_chapters'] as int? ?? 0,
        totalLectures: json['total_lectures'] as int? ?? 0,
        totalMockTests: json['total_mock_tests'] as int? ?? 0,
      );
}

class AppSettingModel {
  final String key;
  final String value;

  AppSettingModel({required this.key, required this.value});

  factory AppSettingModel.fromJson(Map<String, dynamic> json) => AppSettingModel(
        key: json['key'] as String,
        value: json['value'] as String,
      );
}

class BannerModel {
  final String id;
  final String title;
  final String imageUrl;
  final String linkUrl;
  final int displayOrder;
  final bool isActive;

  BannerModel({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.linkUrl,
    required this.displayOrder,
    required this.isActive,
  });

  factory BannerModel.fromJson(Map<String, dynamic> json) => BannerModel(
        id: json['id'] as String,
        title: json['title'] as String,
        imageUrl: json['image_url'] as String,
        linkUrl: json['link_url'] as String? ?? '',
        displayOrder: json['display_order'] as int? ?? 0,
        isActive: json['is_active'] as bool? ?? false,
      );
}
