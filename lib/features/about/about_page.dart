import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/localization/localization_provider.dart';
import '../../core/providers/apps_provider.dart';
import '../../core/router/route_paths.dart';
import '../home/widgets/home_footer.dart';
import '../home/widgets/featured_app_card.dart';

class AboutPage extends ConsumerWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final strings = ref.watch(appStringsProvider);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 120),

            // 1. Hero & Stats
            _buildHero(context, theme, strings),
            const SizedBox(height: 32),
            _buildStats(theme, strings),
            const SizedBox(height: 80),

            // 2. Our Mission
            _buildMission(context, theme, strings),
            const SizedBox(height: 100),

            // 3. Core Features
            _buildFeatures(context, theme, strings),
            const SizedBox(height: 100),

            // 4. Supported Applications
            _buildSupportedApps(context, theme, strings, ref),
            const SizedBox(height: 100),

            // 5. FAQ Section
            _buildFAQSection(context, theme, strings),
            const SizedBox(height: 100),

            // 5.5 Built by Creators Section
            _buildCreatorsSection(context, theme, strings),
            const SizedBox(height: 100),

            // 6. CTA Section
            _buildCTA(context, theme, strings),
            const SizedBox(height: 80),

            // 7. Footer
            const HomeFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildHero(BuildContext context, ThemeData theme, dynamic strings) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Adobe Shortcut',
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            strings.aboutHeroTitle,
            style:
                (isMobile
                        ? theme.textTheme.headlineMedium
                        : theme.textTheme.displayMedium)
                    ?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Text(
              strings.aboutHeroDesc,
              style:
                  (isMobile
                          ? theme.textTheme.bodyLarge
                          : theme.textTheme.titleLarge)
                      ?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.7,
                        ),
                        height: 1.5,
                      ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStats(ThemeData theme, dynamic strings) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _StatItem(label: strings.statShortcuts, icon: Icons.keyboard),
          _StatDivider(theme: theme),
          _StatItem(label: strings.statApps, icon: Icons.apps),
          _StatDivider(theme: theme),
          _StatItem(label: strings.statSearchModes, icon: Icons.search),
        ],
      ),
    );
  }

  Widget _buildMission(BuildContext context, ThemeData theme, dynamic strings) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 800),
        child: Column(
          children: [
            Text(
              strings.aboutMissionTitle,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Text(
              strings.aboutMissionDesc,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                height: 1.6,
                fontSize: 18,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatures(
    BuildContext context,
    ThemeData theme,
    dynamic strings,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1000),
        child: Column(
          children: [
            Text(
              strings.aboutFeaturesTitle,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),
            LayoutBuilder(
              builder: (context, constraints) {
                final isMobile = constraints.maxWidth < 600;
                final items = [
                  _FeatureEditorialItem(
                    icon: Icons.keyboard_alt_outlined,
                    title: strings.aboutFeature1Title,
                    desc: strings.aboutFeature1Desc,
                  ),
                  _FeatureEditorialItem(
                    icon: Icons.bookmark_border,
                    title: strings.aboutFeature2Title,
                    desc: strings.aboutFeature2Desc,
                  ),
                  _FeatureEditorialItem(
                    icon: Icons.grid_view,
                    title: strings.aboutFeature3Title,
                    desc: strings.aboutFeature3Desc,
                  ),
                  _FeatureEditorialItem(
                    icon: Icons.translate,
                    title: strings.aboutFeature4Title,
                    desc: strings.aboutFeature4Desc,
                  ),
                ];

                if (isMobile) {
                  return Column(
                    children: items
                        .map(
                          (item) => Padding(
                            padding: const EdgeInsets.only(bottom: 32.0),
                            child: item,
                          ),
                        )
                        .toList(),
                  );
                }

                return GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 32,
                  crossAxisSpacing: 48,
                  childAspectRatio: 3.5,
                  children: items,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSupportedApps(
    BuildContext context,
    ThemeData theme,
    dynamic strings,
    WidgetRef ref,
  ) {
    final appsAsync = ref.watch(allAppsProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: Column(
          children: [
            Text(
              strings.aboutAppsTitle,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              strings.aboutAppsSubtitle,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),
            appsAsync.when(
              data: (apps) {
                if (apps.isEmpty) return const SizedBox.shrink();
                return LayoutBuilder(
                  builder: (context, constraints) {
                    final width = constraints.maxWidth;
                    int columns = 1;
                    if (width >= 1000) {
                      columns = 4;
                    } else if (width >= 700) {
                      columns = 3;
                    } else if (width >= 500) {
                      columns = 2;
                    }

                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: columns,
                        mainAxisSpacing: 24,
                        crossAxisSpacing: 24,
                        mainAxisExtent: 280,
                      ),
                      itemCount: apps.length,
                      itemBuilder: (context, index) {
                        return FeaturedAppCard(
                          app: apps[index],
                          theme: theme,
                          strings: strings,
                          onTap: () {
                            context.go('/apps/${apps[index].slug}');
                          },
                        );
                      },
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFAQSection(
    BuildContext context,
    ThemeData theme,
    dynamic strings,
  ) {
    final faqs = <Map<String, String>>[
      {'q': strings.faq1Q, 'a': strings.faq1A},
      {'q': strings.faq2Q, 'a': strings.faq2A},
      {'q': strings.faq3Q, 'a': strings.faq3A},
      {'q': strings.faq4Q, 'a': strings.faq4A},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 800),
        child: Column(
          children: [
            Text(
              strings.aboutFaqTitle,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),
            _FAQAccordion(faqs: faqs, theme: theme),
          ],
        ),
      ),
    );
  }

  Widget _buildCreatorsSection(
    BuildContext context,
    ThemeData theme,
    dynamic strings,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1000),
        child: Column(
          children: [
            Text(
              strings.builtByCreatorsTitle,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              strings.builtByCreatorsDesc1,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              strings.builtByCreatorsDesc2,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),
            LayoutBuilder(
              builder: (context, constraints) {
                final isMobile = constraints.maxWidth < 700;

                final ibrahimCard = _CreatorCard(
                  name: strings.creatorIbrahim,
                  initials: 'IE',
                  role: strings.roleFlutterDeveloper,
                  responsibilities: [
                    strings.respFlutterWeb,
                    strings.respAppArchitecture,
                    strings.respPerformance,
                    strings.respSearchExperience,
                    strings.respFrontend,
                  ],
                  portfolio: 'https://ibrahim-portfolio-zeta.vercel.app/',
                  github: 'https://github.com/ibrahimelnahal20-lab',
                  linkedin:
                      'https://www.linkedin.com/in/ibrahim-elnahal-887955410',
                  email: 'ibrahimelnahal20@gmail.com',
                  theme: theme,
                  avatarAsset: 'assets/avatar/1.jpg',
                );

                final adhamCard = _CreatorCard(
                  name: strings.creatorAdham,
                  initials: 'AS',
                  role: strings.roleGraphicDesigner,
                  responsibilities: [
                    strings.respProductConcept,
                    strings.respGraphicDesign,
                    strings.respShortcutDatabase,
                    strings.respContentOrganization,
                    strings.respCreativeDirection,
                  ],
                  linkedin:
                      'https://www.linkedin.com/in/adham-shawky-83b90a3a0',
                  email: 'adhamtshawky@gmail.com',
                  theme: theme,
                  avatarAsset: 'assets/avatar/2.jpg',
                  imageAlignment: Alignment(
                    0,
                    -0.6,
                  ), // Moves image down slightly
                );

                if (isMobile) {
                  return Column(
                    children: [
                      ibrahimCard,
                      const SizedBox(height: 24),
                      adhamCard,
                    ],
                  );
                } else {
                  return IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(child: ibrahimCard),
                        const SizedBox(width: 32),
                        Expanded(child: adhamCard),
                      ],
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCTA(BuildContext context, ThemeData theme, dynamic strings) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 800),
        padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(32),
          border: Border.all(
            color: theme.colorScheme.primary.withValues(alpha: 0.1),
          ),
        ),
        child: Column(
          children: [
            Text(
              strings.aboutCtaTitle,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            FilledButton(
              onPressed: () => context.go(RoutePaths.shortcuts),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 20,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                strings.aboutCtaBtn,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final IconData icon;

  const _StatItem({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          label,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}

class _StatDivider extends StatelessWidget {
  final ThemeData theme;
  const _StatDivider({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Container(
        width: 4,
        height: 4,
        decoration: BoxDecoration(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

class _FeatureEditorialItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String desc;

  const _FeatureEditorialItem({
    required this.icon,
    required this.title,
    required this.desc,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return RepaintBoundary(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: theme.colorScheme.primary, size: 28),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  desc,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FAQAccordion extends StatefulWidget {
  final List<Map<String, String>> faqs;
  final ThemeData theme;

  const _FAQAccordion({required this.faqs, required this.theme});

  @override
  State<_FAQAccordion> createState() => _FAQAccordionState();
}

class _FAQAccordionState extends State<_FAQAccordion> {
  final ValueNotifier<int?> _expandedNotifier = ValueNotifier<int?>(null);

  @override
  void dispose() {
    _expandedNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(widget.faqs.length, (index) {
        return _FAQItem(
          index: index,
          faq: widget.faqs[index],
          theme: widget.theme,
          expandedNotifier: _expandedNotifier,
        );
      }),
    );
  }
}

class _FAQItem extends StatefulWidget {
  final int index;
  final Map<String, String> faq;
  final ThemeData theme;
  final ValueNotifier<int?> expandedNotifier;

  const _FAQItem({
    required this.index,
    required this.faq,
    required this.theme,
    required this.expandedNotifier,
  });

  @override
  State<_FAQItem> createState() => _FAQItemState();
}

class _FAQItemState extends State<_FAQItem> {
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.expandedNotifier.value == widget.index;
    widget.expandedNotifier.addListener(_onExpandedChanged);
  }

  @override
  void dispose() {
    widget.expandedNotifier.removeListener(_onExpandedChanged);
    super.dispose();
  }

  void _onExpandedChanged() {
    final newValue = widget.expandedNotifier.value == widget.index;
    if (newValue != _isExpanded) {
      if (mounted) setState(() => _isExpanded = newValue);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: RepaintBoundary(
        child: Material(
          clipBehavior: Clip.antiAlias,
          color: _isExpanded
              ? widget.theme.colorScheme.primary.withValues(alpha: 0.05)
              : widget.theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: _isExpanded
                  ? widget.theme.colorScheme.primary.withValues(alpha: 0.3)
                  : widget.theme.colorScheme.outline.withValues(alpha: 0.1),
            ),
          ),
          child: Theme(
            data: widget.theme.copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              title: Text(
                widget.faq['q']!,
                style: widget.theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: _isExpanded
                      ? widget.theme.colorScheme.primary
                      : widget.theme.colorScheme.onSurface,
                ),
              ),
              iconColor: widget.theme.colorScheme.primary,
              collapsedIconColor: widget.theme.colorScheme.onSurface.withValues(alpha: 0.5),
              expandedCrossAxisAlignment: CrossAxisAlignment.start,
              onExpansionChanged: (expanded) {
                widget.expandedNotifier.value = expanded ? widget.index : null;
              },
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  child: SizedBox(
                    width: double.infinity,
                    child: Text(
                      widget.faq['a']!,
                      style: widget.theme.textTheme.bodyLarge?.copyWith(
                        color: widget.theme.colorScheme.onSurface.withValues(alpha: 0.7),
                        height: 1.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CreatorCard extends StatefulWidget {
  final String name;
  final String initials;
  final String role;
  final List<String> responsibilities;
  final String? portfolio;
  final String? github;
  final String? linkedin;
  final String? email;
  final ThemeData theme;
  final String? avatarAsset;
  final AlignmentGeometry? imageAlignment;

  const _CreatorCard({
    required this.name,
    required this.initials,
    required this.role,
    required this.responsibilities,
    this.portfolio,
    this.github,
    this.linkedin,
    this.email,
    required this.theme,
    this.avatarAsset,
    this.imageAlignment,
  });

  @override
  State<_CreatorCard> createState() => _CreatorCardState();
}

class _CreatorCardState extends State<_CreatorCard> {
  bool _isHovered = false;

  Future<void> _launch(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.all(24),
          transform: Matrix4.translationValues(0, _isHovered ? -2 : 0, 0),
          decoration: BoxDecoration(
            color: widget.theme.colorScheme.surfaceContainerHighest.withValues(
              alpha: 0.3,
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: widget.theme.colorScheme.outline.withValues(
                alpha: _isHovered ? 0.3 : 0.1,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: widget.theme.shadowColor.withValues(
                  alpha: _isHovered ? 0.08 : 0.02,
                ),
                blurRadius: _isHovered ? 16 : 8,
                offset: Offset(0, _isHovered ? 8 : 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: widget.theme.colorScheme.primary.withValues(
                        alpha: 0.1,
                      ),
                      image: widget.avatarAsset != null
                          ? DecorationImage(
                              image: AssetImage(widget.avatarAsset!),
                              fit: BoxFit.cover,
                              alignment:
                                  widget.imageAlignment ?? Alignment.center,
                              filterQuality: FilterQuality.high,
                            )
                          : null,
                    ),
                    child: widget.avatarAsset == null
                        ? Center(
                            child: Text(
                              widget.initials,
                              style: widget.theme.textTheme.titleLarge
                                  ?.copyWith(
                                    color: widget.theme.colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.name,
                          style: widget.theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: widget.theme.colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.role,
                          style: widget.theme.textTheme.bodyMedium?.copyWith(
                            color: widget.theme.colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: widget.responsibilities.map((resp) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '•',
                          style: widget.theme.textTheme.bodyLarge?.copyWith(
                            color: widget.theme.colorScheme.onSurface
                                .withValues(alpha: 0.5),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            resp,
                            style: widget.theme.textTheme.bodyMedium?.copyWith(
                              color: widget.theme.colorScheme.onSurface
                                  .withValues(alpha: 0.8),
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  if (widget.portfolio != null)
                    _LinkIcon(
                      icon: Icons.language_rounded,
                      onTap: () => _launch(widget.portfolio!),
                      theme: widget.theme,
                    ),
                  if (widget.github != null)
                    _LinkIcon(
                      svgAsset: 'assets/Icons/Github.svg',
                      onTap: () => _launch(widget.github!),
                      theme: widget.theme,
                    ),
                  if (widget.linkedin != null)
                    _LinkIcon(
                      svgAsset: 'assets/Icons/linkedin.svg',
                      onTap: () => _launch(widget.linkedin!),
                      theme: widget.theme,
                    ),
                  if (widget.email != null)
                    _LinkIcon(
                      icon: Icons.mail_rounded,
                      onTap: () => _launch('mailto:${widget.email}'),
                      theme: widget.theme,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LinkIcon extends StatefulWidget {
  final IconData? icon;
  final String? svgAsset;
  final VoidCallback onTap;
  final ThemeData theme;

  const _LinkIcon({
    this.icon,
    this.svgAsset,
    required this.onTap,
    required this.theme,
  });

  @override
  State<_LinkIcon> createState() => _LinkIconState();
}

class _LinkIconState extends State<_LinkIcon> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 150),
          opacity: _isHovered ? 1.0 : 0.6,
          child: Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: widget.svgAsset != null
                ? SvgPicture.asset(
                    widget.svgAsset!,
                    width: 24,
                    height: 24,
                    colorFilter: ColorFilter.mode(
                      widget.theme.colorScheme.onSurface,
                      BlendMode.srcIn,
                    ),
                  )
                : Icon(
                    widget.icon,
                    size: 24,
                    color: widget.theme.colorScheme.onSurface,
                  ),
          ),
        ),
      ),
    );
  }
}
