import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:rema_1001/router/route_names.dart';
import 'package:rema_1001/page/profile/settings/allergies/bloc/allergies_cubit.dart';
import 'package:rema_1001/page/profile/settings/allergies/bloc/allergies_state.dart';
import 'package:rema_1001/page/profile/settings/cubit/settings_cubit.dart';
import 'package:rema_1001/page/profile/settings/cubit/settings_state.dart';

class Settings extends StatelessWidget {
  const Settings({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // General Settings Section
          _buildSectionHeader(context, 'General'),
          BlocBuilder<SettingsCubit, SettingsState>(
            builder: (context, state) {
              return SwitchListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                title: const Text('Notifications'),
                subtitle: const Text('Enable push notifications'),
                value: state.notificationsEnabled,
                onChanged: (value) {
                  context.read<SettingsCubit>().toggleNotifications(value);
                },
                secondary: const Icon(Icons.notifications),
              );
            },
          ),
          SizedBox(height: 8),
          BlocBuilder<SettingsCubit, SettingsState>(
            builder: (context, state) {
              return SwitchListTile(
                title: const Text('Dark Mode'),
                subtitle: const Text('Use dark theme'),
                value: true,
                onChanged: (value) {
                  context.read<SettingsCubit>().toggleDarkMode(value);
                },
                secondary: const Icon(Icons.dark_mode),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              );
            },
          ),
          SizedBox(height: 8),
          BlocBuilder<SettingsCubit, SettingsState>(
            builder: (context, state) {
              return ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                title: const Text('Language'),
                subtitle: Text(state.language),
                leading: const Icon(Icons.language),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showLanguageDialog(context),
              );
            },
          ),
          SizedBox(height: 8),
          BlocBuilder<SettingsCubit, SettingsState>(
            builder: (context, state) {
              return ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                title: const Text('Household Size'),
                subtitle: Text(
                  '${state.householdSize} ${state.householdSize == 1 ? 'person' : 'people'}',
                ),
                leading: const Icon(Icons.people),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showHouseholdSizeDialog(context),
              );
            },
          ),

          // Health & Dietary Section
          _buildSectionHeader(context, 'Health & Dietary'),
          BlocBuilder<AllergiesCubit, AllergiesState>(
            builder: (context, state) {
              final allergyCount = state.selectedAllergies.length;
              return ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                title: const Text('Allergies'),
                subtitle: allergyCount > 0
                    ? Text(
                        '$allergyCount ${allergyCount == 1 ? 'allergy' : 'allergies'} selected',
                      )
                    : const Text('Manage your allergies'),
                leading: const Icon(Icons.medical_information),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.pushNamed(RouteNames.allergies),
              );
            },
          ),
          SizedBox(height: 8),
          ListTile(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            title: const Text('Dietary Preferences'),
            subtitle: const Text('Set your dietary preferences'),
            leading: const Icon(Icons.restaurant),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),

          // Privacy & Security Section
          _buildSectionHeader(context, 'Privacy & Security'),
          BlocBuilder<SettingsCubit, SettingsState>(
            builder: (context, state) {
              return SwitchListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                title: const Text('Biometric Authentication'),
                subtitle: const Text('Use fingerprint or face ID'),
                value: state.biometricsEnabled,
                onChanged: (value) {
                  context.read<SettingsCubit>().toggleBiometrics(value);
                },
                secondary: const Icon(Icons.fingerprint),
              );
            },
          ),
          SizedBox(height: 8),
          ListTile(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            title: const Text('Privacy Policy'),
            leading: const Icon(Icons.policy),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),

          // About Section
          _buildSectionHeader(context, 'About'),
          ListTile(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            title: const Text('App Version'),
            subtitle: const Text('1.0.0'),
            leading: const Icon(Icons.info),
          ),
          SizedBox(height: 8),
          ListTile(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            title: const Text('Terms of Service'),
            leading: const Icon(Icons.description),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _showLanguageDialog(BuildContext context) {
    final languages = ['English', 'Norwegian', 'Swedish', 'Danish'];

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Select Language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: languages.map((language) {
            return BlocBuilder<SettingsCubit, SettingsState>(
              builder: (context, state) {
                return RadioListTile<String>(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  title: Text(language),
                  value: language,
                  groupValue: state.language,
                  onChanged: (value) {
                    if (value != null) {
                      context.read<SettingsCubit>().setLanguage(value);
                      Navigator.of(dialogContext).pop();
                    }
                  },
                );
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showHouseholdSizeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, state) {
          return AlertDialog(
            title: const Text('Household Size'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('How many people live in your household?'),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline),
                      onPressed: state.householdSize > 1
                          ? () => context
                                .read<SettingsCubit>()
                                .setHouseholdSize(state.householdSize - 1)
                          : null,
                      iconSize: 32,
                    ),
                    const SizedBox(width: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${state.householdSize}',
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(
                              color: Theme.of(
                                context,
                              ).colorScheme.onPrimaryContainer,
                            ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline),
                      onPressed: state.householdSize < 20
                          ? () => context
                                .read<SettingsCubit>()
                                .setHouseholdSize(state.householdSize + 1)
                          : null,
                      iconSize: 32,
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('Done'),
              ),
            ],
          );
        },
      ),
    );
  }
}
