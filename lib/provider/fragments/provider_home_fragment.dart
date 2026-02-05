import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:handyman_provider_flutter/main.dart';
import 'package:handyman_provider_flutter/models/dashboard_response.dart';
import 'package:handyman_provider_flutter/networks/rest_apis.dart';
import 'package:handyman_provider_flutter/provider/components/chart_component.dart';
import 'package:handyman_provider_flutter/provider/components/handyman_list_component.dart';
import 'package:handyman_provider_flutter/provider/components/handyman_recently_online_component.dart';
import 'package:handyman_provider_flutter/provider/components/job_list_component.dart';
import 'package:handyman_provider_flutter/provider/components/services_list_component.dart';
import 'package:handyman_provider_flutter/provider/components/total_component.dart';
import 'package:handyman_provider_flutter/provider/fragments/shimmer/provider_dashboard_shimmer.dart';
import 'package:handyman_provider_flutter/provider/subscription/pricing_plan_screen.dart';
import 'package:handyman_provider_flutter/screens/cash_management/component/today_cash_component.dart';
import 'package:handyman_provider_flutter/utils/colors.dart';
import 'package:handyman_provider_flutter/utils/common.dart';
import 'package:handyman_provider_flutter/utils/constant.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../components/app_widgets.dart';
import '../../components/empty_error_state_widget.dart';
import '../components/upcoming_booking_component.dart';

class ProviderHomeFragment extends StatefulWidget {
  @override
  _ProviderHomeFragmentState createState() => _ProviderHomeFragmentState();
}

class _ProviderHomeFragmentState extends State<ProviderHomeFragment> {
  int page = 1;

  int currentIndex = 0;

  late Future<DashboardResponse> future;

  /// User can dismiss "Plans coming soon" for this session; shows again on next app open.
  bool _hidePlansComingSoonBanner = false;

  @override
  void initState() {
    super.initState();
    init();
  }

  void init({bool forceSyncAppConfigurations = false}) async {
    future = providerDashboard(
            forceSyncAppConfigurations: forceSyncAppConfigurations)
        .whenComplete(() {
      setState(() {});
    });
  }

  Widget _buildHeaderWidget(DashboardResponse data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        16.height,
        Text("${languages.lblHello}, ${appStore.userFullName}",
                style: boldTextStyle(size: 16))
            .paddingLeft(16),
        8.height,
        Text(languages.lblWelcomeBack, style: secondaryTextStyle(size: 14))
            .paddingLeft(16),
        16.height,
      ],
    );
  }

  Widget planBanner(DashboardResponse data) {
    if (data.isPlanExpired.validate()) {
      return subSubscriptionPlanWidget(
        planBgColor:
            appStore.isDarkMode ? context.cardColor : Colors.red.shade50,
        planTitle: languages.lblPlanExpired,
        planSubtitle: languages.lblPlanSubTitle,
        planButtonTxt: languages.btnTxtBuyNow,
        btnColor: Colors.red,
        onTap: () {
          PricingPlanScreen().launch(context);
        },
      );
    } else if (data.userNeverPurchasedPlan.validate()) {
      return AnimatedSwitcher(
        duration: Duration(milliseconds: 320),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        transitionBuilder: (Widget child, Animation<double> animation) {
          return FadeTransition(
            opacity: animation,
            child: SizeTransition(
              sizeFactor: animation,
              axisAlignment: -1,
              child: child,
            ),
          );
        },
        child: _hidePlansComingSoonBanner
            ? SizedBox.shrink(key: ValueKey('hidden'))
            : _PlansComingSoonBanner(
                key: ValueKey('visible'),
                onClose: () =>
                    setState(() => _hidePlansComingSoonBanner = true),
                isDarkMode: appStore.isDarkMode,
                cardColor: context.cardColor,
                iconColor: context.iconColor,
              ),
      );
    } else if (data.isPlanAboutToExpire.validate()) {
      int days = getRemainingPlanDays();

      if (days != 0 && days <= PLAN_REMAINING_DAYS) {
        return subSubscriptionPlanWidget(
          planBgColor:
              appStore.isDarkMode ? context.cardColor : Colors.orange.shade50,
          planTitle: languages.lblReminder,
          planSubtitle: languages.planAboutToExpire(days),
          planButtonTxt: languages.lblRenew,
          btnColor: Colors.orange,
          onTap: () {
            PricingPlanScreen().launch(context);
          },
        );
      } else {
        return Offstage();
      }
    } else {
      return Offstage();
    }
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          FutureBuilder<DashboardResponse>(
            initialData: cachedProviderDashboardResponse,
            future: future,
            builder: (context, snap) {
              if (snap.hasData) {
                return AnimatedScrollView(
                  padding: EdgeInsets.only(bottom: 16),
                  physics: AlwaysScrollableScrollPhysics(),
                  crossAxisAlignment: CrossAxisAlignment.start,
                  listAnimationType: ListAnimationType.FadeIn,
                  fadeInConfiguration: FadeInConfiguration(duration: 2.seconds),
                  children: [
                    // if (appStore.earningTypeSubscription)
                      planBanner(snap.data!),
                    _buildHeaderWidget(snap.data!),
                    TodayCashComponent(
                        totalCashInHand: snap.data!.totalCashInHand.validate()),
                    TotalComponent(snap: snap.data!),
                    ChartComponent(),
                    HandymanRecentlyOnlineComponent(
                        images: snap.data!.onlineHandyman.validate()),
                    HandymanListComponent(
                      list: snap.data!.handyman.validate(),
                      totalActiveHandyman:
                          snap.data!.totalActiveHandyman.validate(),
                      onRefresh: init,
                    ),
                    UpcomingBookingComponent(
                        bookingData: snap.data!.upcomingBookings.validate()),
                    JobListComponent(list: snap.data!.myPostJobData.validate())
                        .paddingOnly(left: 16, right: 16, top: 8)
                        .visible(rolesAndPermissionStore.postJobList),
                    ServiceListComponent(
                      list: snap.data!.service.validate(),
                      totalBookings: snap.data?.totalBooking ?? 0,
                    ).visible(
                      rolesAndPermissionStore.serviceList,
                    ),
                  ],
                  onSwipeRefresh: () async {
                    page = 1;
                    appStore.setLoading(true);

                    init(forceSyncAppConfigurations: true);
                    setState(() {});

                    return await 2.seconds.delay;
                  },
                );
              }

              return snapWidgetHelper(
                snap,
                loadingWidget: ProviderDashboardShimmer(),
                errorBuilder: (error) {
                  return NoDataWidget(
                    title: error,
                    imageWidget: ErrorStateWidget(),
                    retryText: languages.reload,
                    onRetry: () {
                      page = 1;
                      appStore.setLoading(true);

                      init();
                      setState(() {});
                    },
                  );
                },
              );
            },
          ),
          Observer(
              builder: (context) => LoaderWidget().visible(appStore.isLoading))
        ],
      ),
    );
  }
}

/// Eye-catching "Plans coming soon" banner with gradient, entrance animation, and close.
class _PlansComingSoonBanner extends StatefulWidget {
  final VoidCallback onClose;
  final bool isDarkMode;
  final Color cardColor;
  final Color iconColor;

  const _PlansComingSoonBanner({
    Key? key,
    required this.onClose,
    required this.isDarkMode,
    required this.cardColor,
    required this.iconColor,
  }) : super(key: key);

  @override
  State<_PlansComingSoonBanner> createState() => _PlansComingSoonBannerState();
}

class _PlansComingSoonBannerState extends State<_PlansComingSoonBanner>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );
    _scale = Tween<double>(begin: 0.92, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
    _opacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _opacity.value,
          child: Transform.scale(
            scale: _scale.value,
            alignment: Alignment.center,
            child: child,
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          gradient: widget.isDarkMode
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    widget.cardColor,
                    widget.cardColor,
                  ],
                )
              : kAppPrimaryGradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: widget.isDarkMode
              ? []
              : [
                  BoxShadow(
                    color: gradientRed.withValues(alpha: 0.35),
                    blurRadius: 12,
                    offset: Offset(0, 4),
                    spreadRadius: 0,
                  ),
                  BoxShadow(
                    color: gradientBlue.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                    spreadRadius: 0,
                  ),
                ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              // Subtle pattern / shine overlay
              if (!widget.isDarkMode)
                Positioned(
                  right: -24,
                  top: -24,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.12),
                    ),
                  ),
                ),
              Padding(
                padding: EdgeInsets.fromLTRB(18, 14, 10, 14),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.auto_awesome_rounded,
                        size: 26,
                        color: Colors.white,
                      ),
                    ),
                    14.width,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Plans coming soon',
                            style: boldTextStyle(
                              size: 16,
                              color: Colors.white,
                              letterSpacing: 0.3,
                            ),
                          ),
                          4.height,
                          Text(
                            'We\'re building something great for you. Stay tuned.',
                            style: secondaryTextStyle(
                              size: 12,
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(24),
                        onTap: widget.onClose,
                        child: Padding(
                          padding: EdgeInsets.all(8),
                          child: Icon(
                            Icons.close_rounded,
                            size: 22,
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
