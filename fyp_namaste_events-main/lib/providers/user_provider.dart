import 'package:flutter/material.dart';
import 'package:fyp_namaste_events/model/user_registration_model.dart';

class UserProvider extends ChangeNotifier {
  userData _userData = userData(
    id: '',
    userName: '',
    email: '',
    token: '',
    phone:'',
    role:'',
    password:'',
  );

  userData get user => _userData;

  void setUser(String user) {
    _userData = userData.fromJson(user);
    notifyListeners();
  }

  void setUserFromModel(userData user) {
    _userData = user;
    notifyListeners();
  }
}
