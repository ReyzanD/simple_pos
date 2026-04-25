import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/neo_brutal_theme.dart';
import '../../../shared/presentation/providers.dart';
import '../widgets/expense_list_tab.dart';
import '../widgets/expense_summary_tab.dart';
import '../widgets/expense_categories_tab.dart';
import '../widgets/expense_form_dialog.dart';

class ExpenseScreen extends ConsumerStatefulWidget {
  const ExpenseScreen({super.key});

  @override
  ConsumerState<ExpenseScreen> createState() => _ExpenseScreenState();
}

class _ExpenseScreenState extends ConsumerState<ExpenseScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentTab = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_handleTabChange);
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    super.dispose();
  }

  void _handleTabChange() {
    if (_tabController.indexIsChanging) {
      setState(() => _currentTab = _tabController.index);
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.watch(expenseControllerProvider);

    return Scaffold(
      backgroundColor: NeoBrutalTheme.background, // ✅ Brutal white background
      appBar: AppBar(
        title: const Text('Pengeluaran'),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            color: NeoBrutalTheme.blockYellow, // ✅ Bold yellow background
            border: Border(
              bottom: BorderSide(
                color: Colors.black,
                width: 6, // ✅ Extra thick bottom border
              ),
            ),
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.black,
          labelColor: Colors.black,
          unselectedLabelColor: Colors.black.withValues(alpha: 0.5),
          indicatorWeight: 4, // ✅ Bold indicator
          labelStyle: NeoBrutalTheme.labelLarge.copyWith(
            fontWeight: FontWeight.w800,
          ),
          tabs: const [
            Tab(text: 'Daftar', icon: Icon(Icons.list)),
            Tab(text: 'Ringkasan', icon: Icon(Icons.bar_chart)),
            Tab(text: 'Kategori', icon: Icon(Icons.category)),
          ],
        ),
      ),
      body: IndexedStack(
        index: _currentTab,
        children: [
          ExpenseListTab(controller: controller),
          ExpenseSummaryTab(controller: controller),
          ExpenseCategoriesTab(controller: controller),
        ],
      ),
      floatingActionButton: _currentTab == 0
          ? FloatingActionButton.extended(
              heroTag: 'expense_fab', // ✅ Unique hero tag
              onPressed: () => _showAddDialog(context),
              icon: const Icon(Icons.add),
              label: const Text('Tambah'),
              backgroundColor: NeoBrutalTheme.secondary, // ✅ Brutal secondary color
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(NeoBrutalTheme.radiusMedium), // ✅ Brutal 8px
                side: BorderSide(
                  color: Colors.black,
                  width: 4, // ✅ Bold 4px border
                ),
              ),
              elevation: 6,
            )
          : null,
    );
  }

  Future<void> _showAddDialog(BuildContext context) async {
    await showExpenseFormDialog(context);
  }
}
