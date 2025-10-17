import 'package:equatable/equatable.dart';

class SettingsState extends Equatable {
  final bool notificationsEnabled;
  final bool darkModeEnabled;
  final bool biometricsEnabled;
  final String language;
  final bool isLoading;

  const SettingsState({
    this.notificationsEnabled = true,
    this.darkModeEnabled = false,
    this.biometricsEnabled = false,
    this.language = 'English',
    this.isLoading = false,
  });

  SettingsState copyWith({
    bool? notificationsEnabled,
    bool? darkModeEnabled,
    bool? biometricsEnabled,
    String? language,
    bool? isLoading,
  }) {
    return SettingsState(
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      darkModeEnabled: darkModeEnabled ?? this.darkModeEnabled,
      biometricsEnabled: biometricsEnabled ?? this.biometricsEnabled,
      language: language ?? this.language,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object?> get props => [
    notificationsEnabled,
    darkModeEnabled,
    biometricsEnabled,
    language,
    isLoading,
  ];
}
