import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:sixam_mart_store/features/dashboard/widgets/out_of_stock_warning_bottom_sheet.dart';
import 'package:sixam_mart_store/features/profile/controllers/profile_controller.dart';
import 'package:sixam_mart_store/features/subscription/controllers/subscription_controller.dart';
import 'package:sixam_mart_store/features/disbursement/helper/disbursement_helper.dart';
import 'package:sixam_mart_store/util/dimensions.dart';
import 'package:sixam_mart_store/util/images.dart';
import 'package:sixam_mart_store/features/payment/screens/wallet_screen.dart';
import 'package:sixam_mart_store/features/dashboard/widgets/bottom_nav_item_widget.dart';
import 'package:sixam_mart_store/features/home/screens/home_screen.dart';
import 'package:sixam_mart_store/features/menu/screens/menu_screen.dart';
import 'package:sixam_mart_store/features/order/screens/order_history_screen.dart';
import 'package:sixam_mart_store/features/store/screens/store_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';

class DashboardScreen extends StatefulWidget {
  final int pageIndex;
  const DashboardScreen({super.key, required this.pageIndex});

  @override
  DashboardScreenState createState() => DashboardScreenState();
}

class DashboardScreenState extends State<DashboardScreen> {
  PageController? _pageController;
  int _pageIndex = 0;
  late List<Widget> _screens;
  FlutterLocalNotificationsPlugin? flutterLocalNotificationsPlugin;
  DisbursementHelper disbursementHelper = DisbursementHelper();
  bool _canExit = false;

  @override
  void initState() {
    super.initState();

    _pageIndex = widget.pageIndex;

    _pageController = PageController(initialPage: widget.pageIndex);

    _screens = [
      const HomeScreen(),
      const OrderHistoryScreen(),
      const StoreScreen(),
      const WalletScreen(),
      Container(),
    ];

    Future.delayed(const Duration(seconds: 1), () {
      setState(() {});
    });

    showDisbursementWarningMessage();

    Get.find<SubscriptionController>().trialEndBottomSheet();

    outOfStockBottomSheet();

  }

  showDisbursementWarningMessage() async{
    disbursementHelper.enableDisbursementWarningMessage(true);
  }

  Future<void> outOfStockBottomSheet() async {
    Future.delayed(const Duration(seconds: 1), () {
      if(Get.find<ProfileController>().profileModel != null && Get.find<ProfileController>().profileModel!.outOfStockCount! > 0 && Get.find<ProfileController>().showLowStockWarning) {
        showModalBottomSheet(
          context: Get.context!, isScrollControlled: true, backgroundColor: Colors.transparent,
          builder: (con) => const OutOfStockWarningBottomSheet(),
        ).then((v) {
          Get.find<ProfileController>().hideLowStockWarning();
        });
      }
    });
  }



  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async{
        if(_pageIndex != 0) {
          _setPage(0);
        }else {
          if(_canExit) {
            if (GetPlatform.isAndroid) {
              SystemNavigator.pop();
            } else if (GetPlatform.isIOS) {
              exit(0);
            }
          }
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('back_press_again_to_exit'.tr, style: const TextStyle(color: Colors.white)),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
            margin: const EdgeInsets.all(Dimensions.paddingSizeSmall),
          ));
          _canExit = true;

          Timer(const Duration(seconds: 2), () {
            _canExit = false;
          });
        }
      },
      child: Scaffold(

        floatingActionButton: !GetPlatform.isMobile ? null : Material(
          elevation: 5,
          shape: const CircleBorder(),
          child: FloatingActionButton(
            backgroundColor: _pageIndex == 2 ? Theme.of(context).primaryColor : Theme.of(context).cardColor,
            onPressed: () {
              _setPage(2);
            },
            child: Image.asset(
              Images.restaurant, height: 20, width: 20,
              color: _pageIndex == 2 ? Theme.of(context).cardColor : Theme.of(context).disabledColor,
            ),
          ),
        ),
        floatingActionButtonLocation: !GetPlatform.isMobile ? null : FloatingActionButtonLocation.centerDocked,

        bottomNavigationBar: !GetPlatform.isMobile ? const SizedBox() : BottomAppBar(
          elevation: 5,
          notchMargin: 5,
          surfaceTintColor: Theme.of(context).primaryColor,
          shape: const CircularNotchedRectangle(),

          child: Padding(
            padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
            child: Row(children: [
              BottomNavItemWidget(iconData: Icons.home, isSelected: _pageIndex == 0, onTap: () => _setPage(0)),
              BottomNavItemWidget(iconData: Icons.shopping_bag, isSelected: _pageIndex == 1, onTap: () => _setPage(1)),
              const Expanded(child: SizedBox()),
              BottomNavItemWidget(iconData: Icons.monetization_on, isSelected: _pageIndex == 3, onTap: () => _setPage(3)),
              BottomNavItemWidget(iconData: Icons.menu, isSelected: _pageIndex == 4, onTap: () {
                Get.bottomSheet(const MenuScreen(), backgroundColor: Colors.transparent, isScrollControlled: true);
              }),
            ]),
          ),
        ),
        body: PageView.builder(
          controller: _pageController,
          itemCount: _screens.length,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            return _screens[index];
          },
        ),
      ),
    );
  }

  void _setPage(int pageIndex) {
    Get.find<SubscriptionController>().trialEndBottomSheet().then((trialEnd) {
      if(trialEnd) {
        setState(() {
          _pageController!.jumpToPage(pageIndex);
          _pageIndex = pageIndex;
        });
      }
    });
  }
}
