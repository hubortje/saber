import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localized_locales/flutter_localized_locales.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:saber/components/settings/settings_color.dart';
import 'package:saber/components/settings/settings_dropdown.dart';
import 'package:saber/components/settings/settings_selection.dart';
import 'package:saber/components/settings/settings_switch.dart';

import 'package:saber/components/settings/nextcloud_profile.dart';
import 'package:saber/components/settings/app_info.dart';
import 'package:saber/components/settings/update_manager.dart';
import 'package:saber/components/theming/adaptive_toggle_buttons.dart';
import 'package:saber/data/flavor_config.dart';
import 'package:saber/data/prefs.dart';
import 'package:saber/i18n/strings.g.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  void initState() {
    Prefs.locale.addListener(onChanged);
    UpdateManager.status.addListener(onChanged);
    super.initState();
  }

  void onChanged() {
    setState(() {});
  }

  static final bool usesMaterialByDefault = () {
    if (defaultTargetPlatform == TargetPlatform.iOS) return false;
    if (defaultTargetPlatform == TargetPlatform.macOS) return false;
    return true;
  }();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final platform = Theme.of(context).platform;
    final appBarCentered = platform == TargetPlatform.iOS
        || platform == TargetPlatform.macOS;

    final bool requiresManualUpdates = !kIsWeb && FlavorConfig.appStore == null;

    final IconData materialIcon = () {
      if (kIsWeb) return FontAwesomeIcons.firefoxBrowser;
      if (defaultTargetPlatform == TargetPlatform.linux) return FontAwesomeIcons.linux;
      if (defaultTargetPlatform == TargetPlatform.windows) return FontAwesomeIcons.windows;
      return Icons.android;
    }();

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            collapsedHeight: kToolbarHeight,
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                t.home.titles.settings,
                style: TextStyle(color: colorScheme.onBackground),
              ),
              centerTitle: appBarCentered,
              titlePadding: EdgeInsetsDirectional.only(
                  start: appBarCentered ? 0 : 16,
                  bottom: 16
              ),
            ),
            actions: [
              if (UpdateManager.status.value != UpdateStatus.upToDate) IconButton(
                tooltip: t.home.tooltips.showUpdateDialog,
                icon: const Icon(Icons.system_update),
                onPressed: () {
                  UpdateManager.showUpdateDialog(context, userTriggered: true);
                },
              ),
            ],
          ),
          SliverList(delegate: SliverChildListDelegate.fixed([
            Column(children: [
              const NextcloudProfile(),
              const Padding(
                padding: EdgeInsets.all(8),
                child: AppInfo(),
              ),
              SettingsDropdown(
                title: t.settings.prefLabels.locale,
                icon: Icons.language,
                pref: Prefs.locale,
                options: [
                  ToggleButtonsOption("", Text(t.settings.systemLanguage)),
                  ...LocaleSettings.supportedLocales.map((locale) {
                    final String localeCode = locale.toLanguageTag();
                    String? localeName;
                    localeName ??= LocaleNamesLocalizationsDelegate.nativeLocaleNames[localeCode.replaceAll("-", "_")];
                    localeName ??= localeCode;
                    return ToggleButtonsOption(localeCode, Text(localeName));
                  }),
                ],
              ),
              SettingsSelection(
                title: t.settings.prefLabels.appTheme,
                iconBuilder: (i) {
                  if (i == ThemeMode.system.index) return Icons.brightness_auto;
                  if (i == ThemeMode.light.index) return Icons.light_mode;
                  if (i == ThemeMode.dark.index) return Icons.dark_mode;
                  return null;
                },
                pref: Prefs.appTheme,
                optionsWidth: 60,
                options: [
                  ToggleButtonsOption(ThemeMode.system.index, Icon(Icons.brightness_auto, semanticLabel: t.settings.themeModes.system)),
                  ToggleButtonsOption(ThemeMode.light.index, Icon(Icons.light_mode, semanticLabel: t.settings.themeModes.light)),
                  ToggleButtonsOption(ThemeMode.dark.index, Icon(Icons.dark_mode, semanticLabel: t.settings.themeModes.dark)),
                ],
              ),
              SettingsSelection(
                title: t.settings.prefLabels.platform,
                iconBuilder: (i) {
                  if (platform == TargetPlatform.iOS) return Icons.apple;
                  if (platform == TargetPlatform.macOS) return Icons.apple;
                  return materialIcon;
                },
                pref: Prefs.platform,
                optionsWidth: 60,
                options: [
                  ToggleButtonsOption(
                    () {
                      if (usesMaterialByDefault) return -1;
                      return TargetPlatform.android.index;
                    }(),
                    Icon(materialIcon, semanticLabel: "Material"),
                  ),
                  ToggleButtonsOption(
                    () {
                      if (!usesMaterialByDefault) return -1;
                      return TargetPlatform.iOS.index;
                    }(),
                    const Icon(Icons.apple, semanticLabel: "Cupertino"),
                  ),
                ],
              ),
              SettingsColor(
                title: t.settings.prefLabels.customAccentColor,
                icon: Icons.colorize,
                pref: Prefs.accentColor,
              ),
              SettingsSwitch(
                title: t.settings.prefLabels.hyperlegibleFont,
                subtitle: t.settings.prefDescriptions.hyperlegibleFont,
                iconBuilder: (b) {
                  return b ? Icons.font_download : Icons.font_download_off;
                },
                pref: Prefs.hyperlegibleFont,
              ),
              if (requiresManualUpdates) SettingsSwitch(
                title: t.settings.prefLabels.shouldCheckForUpdates,
                icon: Icons.system_update,
                pref: Prefs.shouldCheckForUpdates,
              ),
              SettingsSwitch(
                title: t.settings.prefLabels.editorToolbarOnBottom,
                iconBuilder: (b) {
                  return b ? Icons.vertical_align_bottom : Icons.vertical_align_top;
                },
                pref: Prefs.editorToolbarOnBottom,
              ),
              SettingsSwitch(
                title: t.settings.prefLabels.editorToolbarShowInFullscreen,
                icon: Icons.fullscreen,
                pref: Prefs.editorToolbarShowInFullscreen,
              ),
              SettingsSwitch(
                title: t.settings.prefLabels.editorAutoInvert,
                subtitle: t.settings.prefDescriptions.editorAutoInvert,
                iconBuilder: (b) {
                  return b ? Icons.invert_colors_on : Icons.invert_colors_off;
                },
                pref: Prefs.editorAutoInvert,
              ),
              SettingsSwitch(
                title: t.settings.prefLabels.preferGreyscale,
                subtitle: t.settings.prefDescriptions.preferGreyscale,
                iconBuilder: (b) {
                  return b ? Icons.monochrome_photos : Icons.enhance_photo_translate;
                },
                pref: Prefs.preferGreyscale,
              ),
              SettingsSelection(
                title: t.settings.prefLabels.editorStraightenLines,
                subtitle: (){
                  if (Prefs.editorStraightenDelay.value == 0) return t.settings.straightenDelay.off;
                  return "${Prefs.editorStraightenDelay.value}ms";
                }(),
                iconBuilder: (i) {
                  return (i <= 0) ? Icons.gesture : Icons.straighten;
                },
                pref: Prefs.editorStraightenDelay,
                options: [
                  ToggleButtonsOption(0, Text(t.settings.straightenDelay.off)),
                  ToggleButtonsOption(500, Text(t.settings.straightenDelay.regular)),
                  ToggleButtonsOption(1000, Text(t.settings.straightenDelay.slow)),
                ],
                afterChange: (_) => setState(() {}),
              ),
              SettingsSwitch(
                title: t.settings.prefLabels.autoClearWhiteboardOnExit,
                subtitle: t.settings.prefDescriptions.autoClearWhiteboardOnExit,
                icon: Icons.cleaning_services,
                pref: Prefs.autoClearWhiteboardOnExit,
              ),
              SettingsSwitch(
                title: t.settings.prefLabels.editorPromptRename,
                subtitle: t.settings.prefDescriptions.editorPromptRename,
                iconBuilder: (b) {
                  return b ? Icons.keyboard : Icons.keyboard_hide;
                },
                pref: Prefs.editorPromptRename,
              ),
            ]),
          ])),
        ],
      ),
    );
  }

  @override
  void dispose() {
    Prefs.locale.removeListener(onChanged);
    UpdateManager.status.removeListener(onChanged);
    super.dispose();
  }
}
