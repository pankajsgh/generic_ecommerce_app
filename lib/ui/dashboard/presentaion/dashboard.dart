import 'package:flutter/material.dart';
import 'package:flutter_ecom/ui/dashboard/data/controller/dashboard_controller.dart';
import 'package:flutter_ecom/ui/dashboard/data/model/dashboard_model.dart';
import 'package:flutter_ecom/ui/dashboard/presentaion/widget/dashboard_banner.dart';
import 'package:flutter_ecom/ui/dashboard/presentaion/widget/dashboard_categories.dart';
import 'package:flutter_ecom/ui/dashboard/presentaion/widget/dashboard_header.dart';
import 'package:flutter_ecom/ui/dashboard/presentaion/widget/dashboard_product_section.dart';


class DashboardPage extends StatefulWidget {
  const DashboardPage({
    super.key,
  });

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  late final DashboardController controller;

  final PageController bannerController = PageController();

  @override
  void initState() {
    super.initState();

    controller = DashboardController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.loadDashboard();
    });
  }

  @override
  void dispose() {
    bannerController.dispose();
    controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        if (controller.isLoading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (controller.errorMessage != null) {
          return Scaffold(
            body: Center(
              child: Text(
                controller.errorMessage!,
              ),
            ),
          );
        }

        final data = controller.dashboard;

        if (data == null) {
          return const Scaffold(
            body: Center(
              child: Text('No data found'),
            ),
          );
        }

        return Scaffold(
          body: SafeArea(
            child: RefreshIndicator(
              onRefresh: controller.loadDashboard,
              child: _buildContent(data),
            ),
          ),
        );
      },
    );
  }

  Widget _buildContent(DashboardModel data) {
    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        // Header
        SliverToBoxAdapter(
          child: DashboardHeader(
            data: data,
            controller: controller,
          ),
        ),

        // Categories
        SliverToBoxAdapter(
          child: DashboardCategories(
            sections: data.sections,
            controller: controller,
          ),
        ),

        // Banner
        SliverToBoxAdapter(
          child: DashboardBanner(
            banners: data.banners,
            controller: bannerController,
            currentIndex: controller.currentBanner,
            onPageChanged: controller.changeBanner,
          ),
        ),



        // New Arrivals
        DashboardProductSection(
          title: 'New Arrivals',
          products: data.newArrival,
          controller: controller,
          sort: 'NewArrival',
        ),

        // Top Collection
        DashboardProductSection(
          title: 'Top Collection',
          products: data.topCollection,
          controller: controller,
          sort: 'TopCollection',
        ),

        // Recently Viewed
        DashboardProductSection(
          title: 'Recently Viewed',
          products: data.recentlyViewed,
          controller: controller,
        ),

        const SliverToBoxAdapter(
          child: SizedBox(height: 50),
        ),
      ],
    );
  }
}

