import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:food_delivery_customer/constants/colors.dart';
import 'package:food_delivery_customer/views/screens/cart.dart';
import 'package:food_delivery_customer/views/screens/homescreen.dart';

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
      body: TabBarView(controller: controller, children: [
        HomePage(),
        CartPage(),
        Container(),
        Container(),
      ]),
      bottomNavigationBar: BottomAppBar(
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
                // icon: FaIcon(FontAwesomeIcons.store,),
                icon: Icon(Icons.store),
              ),
              Tab(
                text: 'Cart',
                // icon: FaIcon(FontAwesomeIcons.cartShopping),
                icon: Icon(Icons.shopping_cart),
              ),
              Tab(
                text: 'Favorite',
                // icon: FaIcon(FontAwesomeIcons.heart),
                icon: Icon(Icons.favorite),
              ),
              Tab(
                text: 'Account',
                // icon: FaIcon(FontAwesomeIcons.user),
                icon: Icon(Icons.person),
              ),
            ]),
      ),
    );
  }
}
