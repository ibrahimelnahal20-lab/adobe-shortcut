import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/widgets/shared_empty_state.dart';
import '../../../shared/widgets/shared_error_state.dart';
import '../../../shared/widgets/shared_translation_notice.dart';
import 'providers/app_details_provider.dart';
import 'widgets/app_hero_section.dart';
import 'widgets/app_search_section.dart';
import 'widgets/app_category_filter.dart';
import 'widgets/app_featured_shortcuts.dart';
import 'widgets/app_main_grid.dart';
import 'widgets/app_related_apps.dart';

class AppDetailsPage extends ConsumerStatefulWidget {
  final String appSlug;
  final String? initialSearchQuery;

  const AppDetailsPage({
    super.key,
    required this.appSlug,
    this.initialSearchQuery,
  });

  @override
  ConsumerState<AppDetailsPage> createState() => _AppDetailsPageState();
}

class _AppDetailsPageState extends ConsumerState<AppDetailsPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.initialSearchQuery != null && widget.initialSearchQuery!.isNotEmpty) {
      _searchController.text = widget.initialSearchQuery!;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(appSearchQueryProvider.notifier).update(widget.initialSearchQuery!);
      });
    }
  }

  @override
  void didUpdateWidget(covariant AppDetailsPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.appSlug != widget.appSlug) {
      _searchController.clear();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(appSearchQueryProvider.notifier).update('');
        ref.read(appCategoryProvider.notifier).update('all');
      });
    } else if (oldWidget.initialSearchQuery != widget.initialSearchQuery) {
      if (ref.read(appSearchQueryProvider) != (widget.initialSearchQuery ?? '')) {
        _searchController.text = widget.initialSearchQuery ?? '';
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ref.read(appSearchQueryProvider.notifier).update(widget.initialSearchQuery ?? '');
        });
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Setup URL Sync
    ref.listen<String>(appSearchQueryProvider, (previous, next) {
      if (previous != next && next != (widget.initialSearchQuery ?? '')) {
        final uri = GoRouterState.of(context).uri;
        
        // Build new query parameters map, explicitly removing 'q' if empty
        final Map<String, dynamic> newParams = Map.from(uri.queryParameters);
        if (next.isNotEmpty) {
          newParams['q'] = next;
        } else {
          newParams.remove('q');
        }
        
        final newUri = uri.replace(queryParameters: newParams.isEmpty ? null : newParams);
        context.replace(newUri.toString());
      }
    });

    // Watch the current app future. Since it's a FutureProvider, it will show loading initially.
    final appAsync = ref.watch(currentAppProvider(widget.appSlug));

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: appAsync.when(
        data: (app) {
          if (app == null) {
            return Center(
              child: SharedEmptyState(
                message: 'Application not found.',
                iconData: Icons.app_blocking_outlined,
              ),
            );
          }
          
          return CustomScrollView(
            slivers: [
              const SliverPadding(padding: EdgeInsets.only(top: 120)),
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    AppHeroSection(app: app),
                    AppSearchSection(app: app, searchController: _searchController),
                    const SharedTranslationNotice(),
                    AppCategoryFilter(appSlug: app.slug),
                  ],
                ),
              ),
              AppFeaturedShortcuts(appSlug: app.slug),
              AppMainGrid(appSlug: app.slug),
              SliverToBoxAdapter(
                child: AppRelatedApps(currentApp: app),
              ),
              const SliverPadding(padding: EdgeInsets.only(bottom: 120)),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: SharedErrorState(
            message: 'Failed to load app details',
            onRetry: () => ref.invalidate(currentAppProvider(widget.appSlug)),
          ),
        ),
      ),
    );
  }
}
