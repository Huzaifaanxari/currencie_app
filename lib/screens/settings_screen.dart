import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../providers/locale_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../login_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String selectedLanguage = 'English';

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final localeProvider = Provider.of<LocaleProvider>(context);

    selectedLanguage = _getLanguageName(localeProvider.locale.languageCode);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.settings),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            title: Text(AppLocalizations.of(context)!.language),
            subtitle: Text(selectedLanguage),
            trailing: const Icon(Icons.language),
            onTap: () {
              _showLanguagePicker(context, localeProvider);
            },
          ),
          SwitchListTile(
            title: Text(AppLocalizations.of(context)!.darkMode),
            value: themeProvider.isDarkMode,
            onChanged: (value) {
              themeProvider.toggleTheme(value);
            },
          ),
          ListTile(
            title: Text(AppLocalizations.of(context)!.accentColor),
            trailing: CircleAvatar(
              backgroundColor: themeProvider.accentColor,
            ),
            onTap: () {
              _showColorPicker(context, themeProvider);
            },
          ),
          const Divider(),
          ListTile(
            title: Text(AppLocalizations.of(context)!.currencyRateSource),
            subtitle: Text(AppLocalizations.of(context)!.exchangeRateAPI),
            trailing: const Icon(Icons.info_outline),
          ),
          const Divider(),
          ListTile(
            title: Text("Log Out"),
            leading: const Icon(Icons.logout, color: Colors.red),
            onTap: () {
              _showLogoutConfirmation(context);
            },
          ),
        ],
      ),
    );
  }

  void _showLanguagePicker(
      BuildContext context, LocaleProvider localeProvider) {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        final languages = [
          {'name': 'English', 'code': 'en'},
          {'name': 'Spanish', 'code': 'es'},
          {'name': 'French', 'code': 'fr'},
        ];

        return ListView(
          children: languages.map((lang) {
            return ListTile(
              title: Text(lang['name']!),
              onTap: () {
                localeProvider.setLocale(Locale(lang['code']!));
                setState(() {
                  selectedLanguage = lang['name']!;
                });
                Navigator.pop(context);
              },
            );
          }).toList(),
        );
      },
    );
  }

  void _showColorPicker(
      BuildContext context, ThemeProvider themeProvider) {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return GridView.count(
          crossAxisCount: 5,
          padding: const EdgeInsets.all(16),
          shrinkWrap: true,
          children: [
            Colors.blue,
            Colors.red,
            Colors.green,
            Colors.purple,
            Colors.orange
          ].map((color) {
            return GestureDetector(
              onTap: () {
                themeProvider.setAccentColor(color);
                Navigator.pop(context);
              },
              child: CircleAvatar(backgroundColor: color),
            );
          }).toList(),
        );
      },
    );
  }

  String _getLanguageName(String code) {
    switch (code) {
      case 'es':
        return 'Spanish';
      case 'fr':
        return 'French';
      case 'en':
      default:
        return 'English';
    }
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(" Are you sure?"),
          content: const Text("Do you really want to log out? We'll miss you! "),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _logout(context);
              },
              child: const Text("Yes, Log Out"),
            ),
          ],
        );
      },
    );
  }

  void _logout(BuildContext context) {
    // Perform logout logic here (e.g., clearing user session, tokens, etc.)
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }
}
