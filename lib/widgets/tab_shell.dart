import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class TabItemConfig {
  final IconData icon;
  final String label;
  final WidgetBuilder rootBuilder;

  const TabItemConfig({required this.icon, required this.label, required this.rootBuilder});
}

/// Lets descendant screens switch the enclosing [TabShell]'s active tab
/// (e.g. a "lihat semua" button jumping to another bottom-nav tab).
class TabIndexController extends ValueNotifier<int> {
  TabIndexController() : super(0);
}

class TabIndexScope extends InheritedNotifier<TabIndexController> {
  const TabIndexScope({super.key, required TabIndexController controller, required super.child})
      : super(notifier: controller);

  static TabIndexController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<TabIndexScope>();
    assert(scope != null, 'TabIndexScope not found in context');
    return scope!.notifier!;
  }
}

/// Shared shell: bottom nav + one nested [Navigator] per tab, so each tab
/// keeps its own back-stack and scroll position independently (matches the
/// design's separate User/Bengkel tab trees).
class TabShell extends StatefulWidget {
  final List<TabItemConfig> tabs;
  final TabIndexController controller;

  const TabShell({super.key, required this.tabs, required this.controller});

  @override
  State<TabShell> createState() => _TabShellState();
}

class _TabShellState extends State<TabShell> {
  late final List<GlobalKey<NavigatorState>> _navKeys =
      List.generate(widget.tabs.length, (_) => GlobalKey<NavigatorState>());

  int get _index => widget.controller.value;

  void _onTapTab(int i) {
    if (i == _index) {
      _navKeys[i].currentState?.popUntil((route) => route.isFirst);
    } else {
      widget.controller.value = i;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) {
            if (didPop) return;
            final nav = _navKeys[_index].currentState;
            if (nav != null && nav.canPop()) nav.pop();
          },
          child: Scaffold(
            backgroundColor: const Color(0xFFF4F6FB),
            body: IndexedStack(
              index: _index,
              children: List.generate(widget.tabs.length, (i) {
                return Navigator(
                  key: _navKeys[i],
                  onGenerateRoute: (settings) => MaterialPageRoute(
                    builder: widget.tabs[i].rootBuilder,
                    settings: settings,
                  ),
                );
              }),
            ),
            bottomNavigationBar: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: AppColors.cardBorderLight)),
              ),
              padding: const EdgeInsets.fromLTRB(6, 8, 6, 12),
              child: SafeArea(
                top: false,
                child: Row(
                  children: List.generate(widget.tabs.length, (i) {
                    final tab = widget.tabs[i];
                    final active = i == _index;
                    final color = active ? AppColors.primary : const Color(0xFF9AA4B4);
                    return Expanded(
                      child: InkWell(
                        onTap: () => _onTapTab(i),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(tab.icon, size: 23, color: color),
                              const SizedBox(height: 4),
                              Text(tab.label,
                                  style: TextStyle(
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w700,
                                      color: color)),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
