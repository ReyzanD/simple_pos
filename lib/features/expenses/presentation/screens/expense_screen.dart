import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../controllers/expense_controller.dart';
import '../widgets/expense_list_tab.dart';
import '../widgets/expense_summary_tab.dart';
import '../widgets/expense_categories_tab.dart';
import '../widgets/expense_form_dialog.dart';

class ExpenseScreen extends StatefulWidget {
  const ExpenseScreen({super.key});

  @override
  State<ExpenseScreen> createState() => _ExpenseScreenState();
}

class _ExpenseScreenState extends State<ExpenseScreen>
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
    final controller = context.watch<ExpenseController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengeluaran'),
        bottom: TabBar(
          controller: _tabController,
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
              onPressed: () => _showAddDialog(context),
              icon: const Icon(Icons.add),
              label: const Text('Tambah'),
              backgroundColor: AppTheme.primaryColor,
            )
          : null,
    );
  }

  Future<void> _showAddDialog(BuildContext context) async {
    await showExpenseFormDialog(context);
  }
}
