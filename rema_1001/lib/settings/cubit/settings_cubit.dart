import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  static const String _notificationsKey = 'notifications_enabled';
  static const String _darkModeKey = 'dark_mode_enabled';
  static const String _biometricsKey = 'biometrics_enabled';
  static const String _languageKey = 'language';

  SettingsCubit() : super(const SettingsState()) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    emit(state.copyWith(isLoading: true));
    try {
      final prefs = await SharedPreferences.getInstance();
      emit(
        state.copyWith(
          notificationsEnabled: prefs.getBool(_notificationsKey) ?? true,
          darkModeEnabled: prefs.getBool(_darkModeKey) ?? false,
          biometricsEnabled: prefs.getBool(_biometricsKey) ?? false,
          language: prefs.getString(_languageKey) ?? 'English',
          isLoading: false,
        ),
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false));
    }
  }

  Future<void> toggleNotifications(bool enabled) async {
    emit(state.copyWith(notificationsEnabled: enabled));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notificationsKey, enabled);
  }

  Future<void> toggleDarkMode(bool enabled) async {
    emit(state.copyWith(darkModeEnabled: enabled));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_darkModeKey, enabled);
  }

  Future<void> toggleBiometrics(bool enabled) async {
    emit(state.copyWith(biometricsEnabled: enabled));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_biometricsKey, enabled);
  }

  Future<void> setLanguage(String language) async {
    emit(state.copyWith(language: language));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, language);
  }
}
