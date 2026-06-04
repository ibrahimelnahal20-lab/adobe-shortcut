import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/localization/localization_provider.dart';
import '../../../core/providers/platform_provider.dart';
import '../../../core/providers/theme_provider.dart';

class OnboardingModal extends ConsumerStatefulWidget {
  final bool isSettingsMode;

  const OnboardingModal({super.key, this.isSettingsMode = false});

  @override
  ConsumerState<OnboardingModal> createState() => _OnboardingModalState();
}

class _OnboardingModalState extends ConsumerState<OnboardingModal> with SingleTickerProviderStateMixin {
  late ThemeMode _themeMode;
  late String _language;
  late String _platform;
  
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _themeMode = ref.read(themeProvider);
    _platform = ref.read(platformProvider) ?? 'both';
    
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.05), end: Offset.zero).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
    );
    
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _language = ref.read(localizationProvider);
  }

  void _applyTheme(ThemeMode mode) async {
    setState(() => _themeMode = mode);
    ref.read(themeProvider.notifier).setTheme(mode);
  }

  void _applyLanguage(String lang) async {
    setState(() => _language = lang);
    await ref.read(localizationProvider.notifier).setLanguage(lang);
  }

  void _applyPlatform(String plat) async {
    setState(() => _platform = plat);
    ref.read(platformProvider.notifier).setPlatform(plat);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isArabic = _language == 'ar';
    final textDirection = isArabic ? TextDirection.rtl : TextDirection.ltr;

    return Directionality(
      textDirection: textDirection,
      child: Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: FadeTransition(
          opacity: _fadeAnim,
          child: SlideTransition(
            position: _slideAnim,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isDesktop = constraints.maxWidth >= 900;
                final showVisuals = isDesktop;
                
                return Container(
                  constraints: BoxConstraints(
                    maxWidth: showVisuals ? 960 : 500,
                    // Removed maxHeight constraint to allow natural content-based sizing
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 40,
                        offset: const Offset(0, 20),
                      )
                    ]
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: showVisuals
                      ? IntrinsicHeight(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(flex: 48, child: _buildPreferencesArea(theme, isArabic)),
                              Expanded(flex: 52, child: _buildVisualArea(theme, isArabic)),
                            ],
                          ),
                        )
                      : _buildPreferencesArea(theme, isArabic),
                );
              }
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVisualArea(ThemeData theme, bool isArabic) {
    return Container(
      color: theme.colorScheme.primary.withValues(alpha: 0.03),
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                'assets/logos/adobe.svg',
                width: 24,
                height: 24,
                colorFilter: ColorFilter.mode(theme.colorScheme.primary, BlendMode.srcIn),
              ),
              const SizedBox(width: 12),
              Text(
                'Adobe Shortcut',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                  letterSpacing: 0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            constraints: const BoxConstraints(maxWidth: 260, maxHeight: 260),
            alignment: Alignment.center,
            child: RepaintBoundary(
              child: Lottie.asset(
                'assets/lottie/Onboard.json',
                fit: BoxFit.contain,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            isArabic 
                ? "جميع اختصارات Adobe المفضلة لديك في مكان واحد."
                : "All your favorite Adobe shortcuts in one place.",
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              height: isArabic ? 1.6 : 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreferencesArea(ThemeData theme, bool isArabic) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Column(
            mainAxisSize: MainAxisSize.min, // Fits content naturally
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
          if (!widget.isSettingsMode) ...[
            Align(
              alignment: isArabic ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  isArabic ? 'مرحباً بك' : 'Welcome',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
          
          Text(
            widget.isSettingsMode
                ? (isArabic ? 'اختر تفضيلاتك' : 'Choose your preferences')
                : (isArabic ? 'مرحباً بك في Adobe Shortcut' : 'Welcome to Adobe Shortcut'),
            textAlign: widget.isSettingsMode ? TextAlign.center : (isArabic ? TextAlign.right : TextAlign.left),
            style: GoogleFonts.poppins(
              textStyle: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
                height: isArabic ? 1.4 : 1.15,
                fontSize: widget.isSettingsMode ? 26 : 28,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            widget.isSettingsMode
                ? (isArabic ? 'يمكنك تعديل هذه الإعدادات في أي وقت.' : 'You can change these settings anytime.')
                : (isArabic ? 'دعنا نخصص تجربتك قبل البدء.' : 'Let\'s personalize your experience before we start.'),
            textAlign: widget.isSettingsMode ? TextAlign.center : (isArabic ? TextAlign.right : TextAlign.left),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              fontSize: 15,
              height: isArabic ? 1.6 : 1.4,
            ),
          ),
          const SizedBox(height: 16),

          _buildCompactSection(
            theme: theme,
            title: isArabic ? 'المظهر' : 'Theme',
            child: _buildSegmented<ThemeMode>(
              theme: theme,
              segments: [
                ButtonSegment(
                  value: ThemeMode.light, 
                  label: Center(child: Text(isArabic ? 'فاتح' : 'Light')),
                ),
                ButtonSegment(
                  value: ThemeMode.dark, 
                  label: Center(child: Text(isArabic ? 'داكن' : 'Dark')),
                ),
              ],
              selected: _themeMode == ThemeMode.system 
                  ? (MediaQuery.platformBrightnessOf(context) == Brightness.dark ? ThemeMode.dark : ThemeMode.light) 
                  : _themeMode,
              onSelectionChanged: (s) => _applyTheme(s.first),
            ),
          ),
          
          const SizedBox(height: 16),
          
          _buildCompactSection(
            theme: theme,
            title: isArabic ? 'اللغة' : 'Language',
            child: _buildSegmented<String>(
              theme: theme,
              segments: [
                const ButtonSegment(value: 'en', label: Center(child: Text('English'))),
                ButtonSegment(
                  value: 'ar', 
                  label: Center(
                    child: Text(
                      'العربية',
                      style: GoogleFonts.alexandria(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
              selected: _language,
              onSelectionChanged: (s) => _applyLanguage(s.first),
            ),
          ),

          const SizedBox(height: 16),

          _buildCompactSection(
            theme: theme,
            title: isArabic ? 'نظام التشغيل' : 'Platform',
            child: _buildSegmented<String>(
              theme: theme,
              segments: [
                ButtonSegment(
                  value: 'windows', 
                  label: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                        'assets/Icons/windows.svg', 
                        width: 16, 
                        height: 16,
                        colorFilter: ColorFilter.mode(
                          _platform == 'windows' 
                              ? theme.colorScheme.primary 
                              : theme.colorScheme.onSurface.withValues(alpha: 0.7), 
                          BlendMode.srcIn
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Text('Windows'),
                    ],
                  ),
                ),
                ButtonSegment(
                  value: 'macos', 
                  label: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                        'assets/Icons/mac.svg', 
                        width: 16, 
                        height: 16,
                        colorFilter: ColorFilter.mode(
                          _platform == 'macos' 
                              ? theme.colorScheme.primary 
                              : theme.colorScheme.onSurface.withValues(alpha: 0.7), 
                          BlendMode.srcIn
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Text('macOS'),
                    ],
                  ),
                ),
                ButtonSegment(
                  value: 'both', 
                  label: Center(child: Text(isArabic ? 'كلاهما' : 'Both')),
                ),
              ],
              selected: _platform,
              onSelectionChanged: (s) => _applyPlatform(s.first),
            ),
          ),

          const SizedBox(height: 16),

          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () async {
                final navigator = Navigator.of(context);
                if (!widget.isSettingsMode) {
                  final prefs = ref.read(sharedPreferencesProvider);
                  await prefs.setBool('has_onboarded', true);
                }
                navigator.pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                padding: EdgeInsets.zero,
                alignment: Alignment.center,
              ),
              child: Text(
                widget.isSettingsMode 
                    ? (isArabic ? 'حفظ التغييرات' : 'Save Changes')
                    : (isArabic ? 'متابعة' : 'Continue'),
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 0.5),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
        ),
      ),
    );
  }

  Widget _buildCompactSection({required ThemeData theme, required String title, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600, color: theme.colorScheme.onSurface)),
        const SizedBox(height: 8),
        child,
      ],
    );
  }

  Widget _buildSegmented<T>({required ThemeData theme, required List<ButtonSegment<T>> segments, required T selected, required void Function(Set<T>) onSelectionChanged}) {
    return SizedBox(
      width: double.infinity,
      child: SegmentedButton<T>(
        segments: segments,
        selected: {selected},
        onSelectionChanged: onSelectionChanged,
        style: SegmentedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          selectedBackgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
          selectedForegroundColor: theme.colorScheme.primary,
          backgroundColor: theme.colorScheme.surface,
          foregroundColor: theme.colorScheme.onSurface.withValues(alpha: 0.7),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          side: BorderSide(color: theme.colorScheme.outline.withValues(alpha: 0.15)),
          visualDensity: VisualDensity.standard,
        ),
        showSelectedIcon: false,
      ),
    );
  }
}
