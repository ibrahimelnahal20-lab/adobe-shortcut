import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'widgets/onboarding_modal.dart';
import 'widgets/hero_section.dart';
import 'widgets/featured_apps_section.dart';
import 'widgets/why_adobe_shortcut_section.dart';
import 'widgets/featured_shortcuts_section.dart';
import 'widgets/home_footer.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkOnboarding();
    });
  }

  Future<void> _checkOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    final hasOnboarded = prefs.getBool('has_onboarded') ?? false;

    if (!hasOnboarded && mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const OnboardingModal(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(top: 140),
      child: Column(
        children: const [
          HeroSection(),
          SizedBox(height: 64),
          FeaturedAppsSection(),
          SizedBox(height: 64),
          FeaturedShortcutsSection(),
          SizedBox(height: 64),
          WhyAdobeShortcutSection(),
          SizedBox(height: 64),
          HomeFooter(),
        ],
      ),
    );
  }
}
