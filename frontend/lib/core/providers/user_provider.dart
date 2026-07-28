import 'package:flutter/material.dart';

import '../models/user_model.dart';

class UserProvider extends ChangeNotifier {
  UserModel? _currentUser;

  UserModel? get currentUser => _currentUser;

  bool get isLoggedIn => _currentUser != null;

  void setUser(UserModel user) {
    _currentUser = user;
    notifyListeners();
  }

  void updateSelectedExam(String examName, int examId) {
    if (_currentUser == null) return;
    _currentUser = _currentUser!.copyWith(
      selectedExamName: examName,
      selectedExamId: examId,
    );
    notifyListeners();
  }

  void clear() {
    _currentUser = null;
    notifyListeners();
  }
}
