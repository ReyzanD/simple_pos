import 'package:flutter/material.dart';
import '../widgets/promotions_tab_widget.dart';
import '../widgets/discount_presets_tab_widget.dart';
import '../widgets/category_discounts_tab_widget.dart';
import '../../../../core/theme.dart';

/// Discount Management Screen with three tabs:
/// 1. Promotions - Time-limited campaign discounts
/// 2. Discount Presets - Reusable discount templates
/// 3. Category Discounts - Category-wide discounts
class DiscountManagementScreen extends StatefulWidget {
  const DiscountManagementScreen({super.key});

  @override
  State<DiscountManagementScreen> createState() =>
      _DiscountManagementScreenState();
}

class _DiscountManagementScreenState extends State<DiscountManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppTheme.primaryColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Manajemen Diskon'),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white.withValues(alpha: 0.7),
          tabs: const [
            Tab(
              icon: Icon(Icons.campaign),
              text: 'Promosi',
            ),
            Tab(
              icon: Icon(Icons.bookmark),
              text: 'Preset',
            ),
            Tab(
              icon: Icon(Icons.category),
              text: 'Kategori',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          PromotionsTabWidget(),
          DiscountPresetsTabWidget(),
          CategoryDiscountsTabWidget(),
        ],
      ),
    );
  }
}
