import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:food_delivery_customer/constants/colors.dart';
import 'package:food_delivery_customer/views/screens/cart.dart';
import 'package:food_delivery_customer/views/screens/Home_view/homescreen.dart';

class MainTabView extends StatefulWidget {
  const MainTabView({super.key});

  @override
  State<MainTabView> createState() => _MainTabViewState();
}

class _MainTabViewState extends State<MainTabView>
    with SingleTickerProviderStateMixin {
  TabController? controller;
  int selectTab = 0;

  @override
  void initState() {
    controller = TabController(length: 4, vsync: this);
    controller?.addListener(() {
      selectTab = controller?.index ?? 0;
      setState(() {});
    });
    super.initState();
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: TabBarView(controller: controller, children: [
        HomePage(),
        CartPage(),
        Container(),
        Container(),
      ]),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(15), topRight: Radius.circular(15)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 3,
                    offset: Offset(0, -2)
                  )
                ]),
        child: BottomAppBar(
          color: Colors.transparent,
          elevation: 0,
          child: TabBar(
              controller: controller,
              indicatorColor: Colors.transparent,
              indicatorWeight: 1,
              labelColor: TColor.primary,
              labelStyle: TextStyle(
                  color: TColor.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.bold),
              unselectedLabelColor: TColor.primaryText.withOpacity(0.6),
              unselectedLabelStyle: TextStyle(
                  color: TColor.primaryText,
                  fontSize: 10,
                  fontWeight: FontWeight.w200),
              tabs: [
                Tab(
                  text: 'Shop',
                  icon: Icon(Icons.store),
                ),
                Tab(
                  text: 'Cart',
                  icon: Icon(Icons.shopping_cart),
                ),
                Tab(
                  text: 'Favorite',
                  icon: Icon(Icons.favorite),
                ),
                Tab(
                  text: 'Account',
                  icon: Icon(Icons.person),
                ),
              ]),
        ),
      ),
    );
  }
}
