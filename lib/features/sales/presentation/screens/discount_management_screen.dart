import 'package:flutter/material.dart';
import '../widgets/promotions_tab_widget.dart';
import '../widgets/discount_presets_tab_widget.dart';
import '../widgets/category_discounts_tab_widget.dart';
import '../../../../core/theme/neo_brutal_theme.dart';

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
      backgroundColor: NeoBrutalTheme.background, // ✅ Brutal white background
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Manajemen Diskon'),
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
