import 'package:equatable/equatable.dart';

class SettingsState extends Equatable {
  final bool notificationsEnabled;
  final bool darkModeEnabled;
  final bool biometricsEnabled;
  final String language;
  final int householdSize;
  final bool isLoading;

  const SettingsState({
    this.notificationsEnabled = true,
    this.darkModeEnabled = false,
    this.biometricsEnabled = false,
    this.language = 'English',
    this.householdSize = 1,
    this.isLoading = false,
  });

  SettingsState copyWith({
    bool? notificationsEnabled,
    bool? darkModeEnabled,
    bool? biometricsEnabled,
    String? language,
    int? householdSize,
    bool? isLoading,
  }) {
    return SettingsState(
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      darkModeEnabled: darkModeEnabled ?? this.darkModeEnabled,
      biometricsEnabled: biometricsEnabled ?? this.biometricsEnabled,
      language: language ?? this.language,
      householdSize: householdSize ?? this.householdSize,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object?> get props => [
    notificationsEnabled,
    darkModeEnabled,
    biometricsEnabled,
    language,
    householdSize,
    isLoading,
  ];
}
