import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../core/providers/platform_provider.dart';
import '../../../core/localization/localization_provider.dart';
import '../../../core/models/shortcut_model.dart';
import '../providers/shortcuts_providers.dart';

class KeyRecorderWidget extends ConsumerStatefulWidget {
  final List<ShortcutModel>? customShortcuts;
  final String? initialQuery;
  final ValueChanged<String>? onQueryChanged;

  const KeyRecorderWidget({
    super.key,
    this.customShortcuts,
    this.initialQuery,
    this.onQueryChanged,
  });

  @override
  ConsumerState<KeyRecorderWidget> createState() => _KeyRecorderWidgetState();
}

class _KeyRecorderWidgetState extends ConsumerState<KeyRecorderWidget> {
  final FocusNode _focusNode = FocusNode();
  final Set<String> _recordedKeys = {};

  @override
  void initState() {
    super.initState();
    
    // Initialize with initial query if provided
    if (widget.initialQuery != null && widget.initialQuery!.isNotEmpty) {
      final keys = widget.initialQuery!.split(' ').where((k) => k.isNotEmpty);
      _recordedKeys.addAll(keys);
    }
    
    // Auto-focus when mounted
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  String _normalizeRawKey(String rawLabel) {
    final lower = rawLabel.toLowerCase();
    if (lower.contains('control')) return 'Ctrl';
    if (lower.contains('shift')) return 'Shift';
    if (lower.contains('alt')) return 'Alt';
    if (lower.contains('meta')) return 'Cmd';
    if (lower.contains('arrow up')) return 'Up';
    if (lower.contains('arrow down')) return 'Down';
    if (lower.contains('arrow left')) return 'Left';
    if (lower.contains('arrow right')) return 'Right';
    if (lower.contains('escape')) return 'Esc';
    if (lower.contains('space')) return 'Space';
    if (lower.contains('enter')) return 'Enter';
    
    // For single letters or numbers, uppercase them
    if (rawLabel.length == 1) return rawLabel.toUpperCase();
    
    return rawLabel;
  }

  void _updateSearchQuery() {
    final query = _recordedKeys.join(' ');
    if (widget.onQueryChanged != null) {
      widget.onQueryChanged!(query);
    } else {
      ref.read(searchQueryProvider.notifier).update(query);
      ref.read(displayLimitProvider.notifier).reset();
    }
  }

  void _addKey(String key) {
    if (!_recordedKeys.contains(key)) {
      setState(() {
        _recordedKeys.add(key);
        _updateSearchQuery();
      });
    }
  }

  void _removeKey(String key) {
    setState(() {
      _recordedKeys.remove(key);
      _updateSearchQuery();
    });
    _focusNode.requestFocus();
  }

  void _clearKeys() {
    setState(() {
      _recordedKeys.clear();
      _updateSearchQuery();
    });
    _focusNode.requestFocus();
  }

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.backspace) {
        if (_recordedKeys.isNotEmpty) {
          setState(() {
            final last = _recordedKeys.last;
            _recordedKeys.remove(last);
            _updateSearchQuery();
          });
        }
        return KeyEventResult.handled;
      }

      final keyLabel = event.logicalKey.keyLabel;
      final normalized = _normalizeRawKey(keyLabel);

      // Ignore generic/unidentified keys
      if (normalized.isNotEmpty && normalized != 'Unidentified' && !normalized.contains('Scroll')) {
        _addKey(normalized);
      }
    }
    
    // Always return handled to intercept and prevent browser defaults (e.g. Ctrl+S)
    // Some OS-level shortcuts like Ctrl+W/Cmd+W or F12 cannot be intercepted by browsers.
    return KeyEventResult.handled;
  }

  List<String> _getSmartSuggestions() {
    if (_recordedKeys.isEmpty) return [];

    final platform = ref.watch(platformProvider);
    final allShortcutsAsync = widget.customShortcuts != null
        ? AsyncData(widget.customShortcuts!)
        : ref.read(allShortcutsProvider);
    
    if (allShortcutsAsync.value == null) return [];
    
    final allShortcuts = allShortcutsAsync.value!;
    final suggestions = <String>{};

    for (final shortcut in allShortcuts) {
      String keysToSearch = '';
      if (platform == 'windows' || platform == 'both' || platform == null) {
        keysToSearch += ' ${shortcut.windows}';
      }
      if (platform == 'macOS' || platform == 'both' || platform == null) {
        keysToSearch += ' ${shortcut.mac}';
      }

      final normalizedTokens = keysToSearch.toLowerCase()
          .replaceAll('+', ' ')
          .replaceAll('-', ' ')
          .split(RegExp(r'\s+'))
          .where((t) => t.isNotEmpty)
          .toSet();

      // Check if this shortcut contains ALL recorded keys
      bool containsAll = true;
      for (final rk in _recordedKeys) {
        if (!normalizedTokens.contains(rk.toLowerCase())) {
          containsAll = false;
          break;
        }
      }

      if (containsAll) {
        // Add the other keys from this shortcut to suggestions
        for (final token in normalizedTokens) {
          final isAlreadyRecorded = _recordedKeys.any((rk) => rk.toLowerCase() == token);
          if (!isAlreadyRecorded) {
            // Capitalize first letter for nice UI
            if (token.length > 1) {
              suggestions.add(token[0].toUpperCase() + token.substring(1));
            } else {
              suggestions.add(token.toUpperCase());
            }
          }
        }
      }
    }

    // Sort alphabetically and return top 10
    final list = suggestions.toList()..sort();
    return list.take(10).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final strings = ref.watch(appStringsProvider);
    final suggestions = _getSmartSuggestions();

    return Column(
      children: [
        Focus(
          focusNode: _focusNode,
          onKeyEvent: _handleKeyEvent,
          child: GestureDetector(
            onTap: () => _focusNode.requestFocus(),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 600, minHeight: 64),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: _focusNode.hasFocus 
                    ? theme.colorScheme.primary 
                    : theme.colorScheme.outline.withValues(alpha: 0.2),
                  width: _focusNode.hasFocus ? 2 : 1,
                ),
                boxShadow: [
                  if (_focusNode.hasFocus)
                    BoxShadow(
                      color: theme.colorScheme.primary.withValues(alpha: 0.1),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  SvgPicture.asset(
                    'assets/Icons/keyboard.svg',
                    width: 20,
                    height: 20,
                    colorFilter: ColorFilter.mode(
                      _focusNode.hasFocus ? theme.colorScheme.primary : theme.colorScheme.onSurface.withValues(alpha: 0.5),
                      BlendMode.srcIn
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _recordedKeys.isEmpty
                        ? Text(
                            strings.keyRecorderPlaceholder,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                            ),
                          )
                        : Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _recordedKeys.map((key) {
                              return Chip(
                                label: Text(
                                  key,
                                  style: theme.textTheme.labelLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                deleteIcon: const Icon(Icons.close, size: 14),
                                onDeleted: () => _removeKey(key),
                                backgroundColor: theme.colorScheme.onSurface.withValues(alpha: 0.05),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                side: BorderSide(color: theme.colorScheme.outline.withValues(alpha: 0.1)),
                              );
                            }).toList(),
                          ),
                  ),
                  if (_recordedKeys.isNotEmpty)
                    IconButton(
                      icon: Icon(Icons.clear_all, color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
                      onPressed: _clearKeys,
                      tooltip: strings.clearKeys,
                    ),
                ],
              ),
            ),
          ),
        ),

        // Smart Suggestions
        if (suggestions.isNotEmpty)
          Container(
            constraints: const BoxConstraints(maxWidth: 600),
            padding: const EdgeInsets.only(top: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  strings.suggestionsBasedOnKeys,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: suggestions.map((suggestion) {
                    return InkWell(
                      onTap: () => _addKey(suggestion),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.1)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.add, size: 12, color: theme.colorScheme.primary),
                            const SizedBox(width: 4),
                            Text(
                              suggestion,
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
