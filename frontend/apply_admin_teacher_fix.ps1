$ErrorActionPreference = "Stop"
$root = "C:\Users\ABC\Desktop\AI_Mentor\frontend\lib"
$utf8Bom = New-Object System.Text.UTF8Encoding($true)

function Replace-InFile($relPath, $old, $new) {
    $path = Join-Path $root $relPath
    $text = [System.IO.File]::ReadAllText($path)
    if ($text.Contains($old)) {
        $text = $text.Replace($old, $new)
        [System.IO.File]::WriteAllText($path, $text, $utf8Bom)
        Write-Host "Fixed: $path"
    } elseif ($text.Contains($new)) {
        Write-Host "Already applied, skipping: $path"
    } else {
        Write-Warning "Pattern not found (check manually): $path"
    }
}

# 1) admin_provider.dart - fix broken import paths
Replace-InFile "features\admin\presentation\providers\admin_provider.dart" `
    "import '../models/admin_models.dart';`nimport '../network/admin_api_service.dart';" `
    "import '../../../../core/models/admin_models.dart';`nimport '../../../../core/network/admin_api_service.dart';"

# 2) teacher_provider.dart - fix broken import paths
Replace-InFile "features\teacher\presentation\providers\teacher_provider.dart" `
    "import '../models/teacher_models.dart';`nimport '../network/teacher_api_service.dart';" `
    "import '../../../../core/models/teacher_models.dart';`nimport '../../../../core/network/teacher_api_service.dart';"

# 3) main.dart - add imports + register providers
Replace-InFile "main.dart" `
    "import `"core/theme/app_theme.dart`";" `
    "import `"core/theme/app_theme.dart`";`nimport `"features/admin/presentation/providers/admin_provider.dart`";`nimport `"features/teacher/presentation/providers/teacher_provider.dart`";"

Replace-InFile "main.dart" `
    "ChangeNotifierProvider(create: (_) => CourseProvider()),`n      ]," `
    "ChangeNotifierProvider(create: (_) => CourseProvider()),`n        ChangeNotifierProvider(create: (_) => AdminProvider()),`n        ChangeNotifierProvider(create: (_) => TeacherProvider()),`n      ],"

# 4) app_router.dart - add imports + routes
Replace-InFile "core\router\app_router.dart" `
    "import `"../../presentation/shell/main_shell_screen.dart`";`nimport `"../navigation/navigation_service.dart`";" `
    "import `"../../presentation/shell/main_shell_screen.dart`";`nimport `"../../features/admin/presentation/screens/admin_dashboard_screen.dart`";`nimport `"../../features/teacher/presentation/screens/teacher_dashboard_screen.dart`";`nimport `"../navigation/navigation_service.dart`";"

Replace-InFile "core\router\app_router.dart" `
    "GoRoute(`n      path: AppRoutes.upgradePlan,`n      builder: (context, state) => const UpgradePlanScreen(),`n    ),`n    StatefulShellRoute" `
    "GoRoute(`n      path: AppRoutes.upgradePlan,`n      builder: (context, state) => const UpgradePlanScreen(),`n    ),`n    GoRoute(`n      path: AppRoutes.adminDashboard,`n      builder: (context, state) => const AdminDashboardScreen(),`n    ),`n    GoRoute(`n      path: AppRoutes.teacherDashboard,`n      builder: (context, state) => const TeacherDashboardScreen(),`n    ),`n    StatefulShellRoute"

Write-Host ""
Write-Host "Done. Now run: flutter clean; flutter pub get; flutter run"
