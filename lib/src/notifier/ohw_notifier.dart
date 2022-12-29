import 'package:flutter/material.dart';


BuildContext? _mainContext;
BuildContext get mainContext => _mainContext!;

bool get hasContext => _mainContext != null;





void setContext(BuildContext c) {
  if (_mainContext == null) {
    _mainContext = c;
  }
}



class OhwNotifier extends ChangeNotifier {


  String _baseUrl = "http://192.168.1.2:8085/data.json";
  String get baseUrl => _baseUrl;
  set baseUrl(String value) {
    if (value != _baseUrl) {
      _baseUrl = value;
      notifyListeners();
    }
  }

  int _timeInterval = 1;
  int get timeInterval => _timeInterval;
  set timeInterval(int value) {
    if (value != _timeInterval) {
      _timeInterval = value;
      notifyListeners();
    }
  }
}