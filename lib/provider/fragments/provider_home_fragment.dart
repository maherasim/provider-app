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

  /// Static "Plans coming soon" banner only. No API, no plan expired / buy now / reminder.
  Widget planBanner(DashboardResponse data) {
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
              onClose: () => setState(() => _hidePlansComingSoonBanner = true),
              isDarkMode: appStore.isDarkMode,
              cardColor: context.cardColor,
              iconColor: context.iconColor,
            ),
    );
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
    with TickerProviderStateMixin {
  late AnimationController _entranceController;
  late Animation<double> _scale;
  late Animation<double> _opacity;

  late AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    // Entrance animation
    _entranceController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 800),
    );
    _scale = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(parent: _entranceController, curve: Curves.elasticOut),
    );
    _opacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _entranceController, curve: Curves.easeIn),
    );
    _entranceController.forward();

    // Loop animation for "Attract Mode" (Shimmer + Pulse)
    _shimmerController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _entranceController,
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
      child: AnimatedBuilder(
        animation: _shimmerController,
        builder: (context, child) {
          final double shimmerValue = _shimmerController.value;
          // Pulse scale for the icon
          final double pulseScale =
              1.0 + (0.08 * (0.5 - (0.5 - shimmerValue).abs()) * 2);

          return Container(
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              // Dynamic gradient background
              gradient: widget.isDarkMode
                  ? LinearGradient(
                      colors: [widget.cardColor, widget.cardColor],
                    )
                  : LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        gradientRed,
                        gradientBlue,
                        gradientRed, // Slight loop back to red for richness
                      ],
                      // Gently shift the gradient alignment or just static is fine if we have the shimmer overlay
                      stops: [0.0, 0.7, 1.0],
                    ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: widget.isDarkMode
                  ? []
                  : [
                      BoxShadow(
                        color: gradientRed.withValues(alpha: 0.35),
                        blurRadius: 15,
                        offset: Offset(0, 8),
                        spreadRadius: -2,
                      ),
                      BoxShadow(
                        color: gradientBlue.withValues(alpha: 0.25),
                        blurRadius: 10,
                        offset: Offset(0, 4),
                        spreadRadius: -1,
                      ),
                    ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                children: [
                  // 1. Moving Background Pattern (Circles)
                  if (!widget.isDarkMode)
                    Positioned(
                      right: -30,
                      top: -30,
                      child: Transform.translate(
                        offset:
                            Offset(0, 15 * (0.5 - (0.5 - shimmerValue).abs())),
                        child: Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.1),
                          ),
                        ),
                      ),
                    ),
                  if (!widget.isDarkMode)
                    Positioned(
                      left: -20,
                      bottom: -40,
                      child: Transform.translate(
                        offset:
                            Offset(0, -10 * (0.5 - (0.5 - shimmerValue).abs())),
                        child: Container(
                          width: 90,
                          height: 90,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.08),
                          ),
                        ),
                      ),
                    ),

                  // 2. Shimmer Light Overlay (sweeps across)
                  if (!widget.isDarkMode)
                    Positioned.fill(
                      child: LayoutBuilder(builder: (context, constraints) {
                        return Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment(-2.5 + (shimmerValue * 5),
                                  -1.0), // Fast sweep
                              end: Alignment(-0.5 + (shimmerValue * 5), 1.0),
                              colors: [
                                Colors.transparent,
                                Colors.white.withValues(alpha: 0.15),
                                Colors.transparent,
                              ],
                              stops: [0.3, 0.5, 0.7],
                            ),
                          ),
                        );
                      }),
                    ),

                  // 3. Main Content
                  Padding(
                    padding: EdgeInsets.fromLTRB(16, 16, 12, 16),
                    child: Row(
                      children: [
                        // Icon with Pulse
                        Transform.scale(
                          scale: pulseScale,
                          child: Container(
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.25),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 8,
                                  offset: Offset(0, 4),
                                )
                              ],
                            ),
                            child: Icon(
                              Icons.auto_awesome_rounded,
                              size: 26,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        14.width,
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                languages.lblPremiumPlansSoon,
                                style: boldTextStyle(
                                  size: 16,
                                  color: Colors.white,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              4.height,
                              Text(
                                languages.lblPremiumPlansSoonSubtitle,
                                style: secondaryTextStyle(
                                  size: 13,
                                  color: Colors.white.withValues(alpha: 0.95),
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        // Close Button
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(24),
                            onTap: widget.onClose,
                            child: Padding(
                              padding: EdgeInsets.all(6),
                              child: Icon(
                                Icons.close_rounded,
                                size: 20,
                                color: Colors.white.withValues(alpha: 0.8),
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
          );
        },
      ),
    );
  }
}
