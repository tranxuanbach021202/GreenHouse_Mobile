import 'dart:async';
import 'package:flutter/material.dart';

abstract class BaseViewModel extends ChangeNotifier {
  bool _isLoading = false;
  bool _isDisposed = false;
  bool _isInitializeDone = false;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;


  FutureOr<void> _initState;

  BaseViewModel() {
    _init();
  }

  FutureOr<void> init();

  void _init() async {
    this.isLoading = true;
    _initState = init();
    await _initState;
    this._isInitializeDone = true;
    this.isLoading = false;
    this._errorMessage = null;
  }

  void setError(String message) {
    _errorMessage = message;
    reloadState();
  }

  void clearError() {
    _errorMessage = null;
    reloadState();
  }

  void changeStatus() => isLoading = !isLoading;

  void reloadState() {
    // if (!isLoading)
      notifyListeners();
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  //Getters
  FutureOr<void> get initState => _initState;

  bool get isLoading => _isLoading;
  bool get isDisposed => _isDisposed;
  bool get isInitialized => _isInitializeDone;

  //Setters
  set isLoading(bool value) {
    _isLoading = value;
    scheduleMicrotask(() {
      if (!_isDisposed) notifyListeners();
    });
  }
}