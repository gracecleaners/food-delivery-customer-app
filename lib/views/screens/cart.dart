import 'package:flutter/material.dart';
import 'package:food_delivery_customer/constants/colors.dart';
// For additional icons

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  List<Map<String, dynamic>> cartItems = [
    {
      'name': 'Cheese Burger',
      'restaurant': 'Burger King',
      'price': 8.99,
      'quantity': 2,
      'image': 'assets/asian.png',
    },
    {
      'name': 'Pepperoni Pizza',
      'restaurant': 'Pizza Hut',
      'price': 12.99,
      'quantity': 1,
      'image': 'assets/pizza.png',
    },
    {
      'name': 'Chicken Wings',
      'restaurant': 'KFC',
      'price': 9.50,
      'quantity': 1,
      'image': 'assets/pizza.png',
    },
    {
      'name': 'Chicken Wings',
      'restaurant': 'KFC',
      'price': 9.50,
      'quantity': 1,
      'image': 'assets/pizza.png',
    },
  ]; // Empty cart for demonstration

  double get subtotal => cartItems.fold(0, (sum, item) => sum + (item['price'] * item['quantity']));
  double deliveryFee = 2.99;
  double get total => subtotal + deliveryFee;

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Column(
          children: [
            // Header (same as before)
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, top: 60, bottom: 20),
              child: Column(
                children: [
                  Text(
                    'My Cart',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: TColor.primaryText,
                    ),
                  ),
                ],
              ),
            ),
            
            // Cart Content (updated for empty state)
            if (cartItems.isEmpty)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.shopping_cart_outlined,
                        size: 80,
                        color: Colors.green, // Big green icon
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'No items in cart',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: TColor.primaryText,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Your favorite foods are waiting!',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 30),
                      SizedBox(
                        width: media.width * 0.6,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: TColor.primary,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () {
                            // Navigate to home or menu
                          },
                          child: const Text(
                            'Browse Menu',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else            
            // Cart Items List
            Expanded(
              child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: cartItems.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                  final item = cartItems[index];
                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        // Food Image
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(12),
                            image: DecorationImage(
                              image: AssetImage(item['image']),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        
                        // Food Details
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item['name'],
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: TColor.primaryText,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                item['restaurant'],
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '\$${item['price'].toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: TColor.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        // Quantity Controls
                        Container(
                          decoration: BoxDecoration(
                            color: TColor.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              IconButton(
                                icon: Icon(Icons.remove, size: 18, color: TColor.primary),
                                onPressed: () {
                                  setState(() {
                                    if (item['quantity'] > 1) {
                                      item['quantity']--;
                                    } else {
                                      cartItems.removeAt(index);
                                    }
                                  });
                                },
                              ),
                              Text(
                                item['quantity'].toString(),
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: TColor.primaryText,
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.add, size: 18, color: TColor.primary),
                                onPressed: () {
                                  setState(() {
                                    item['quantity']++;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            
            // Order Summary
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Summary Items
                  _buildSummaryRow('Subtotal', '\$${subtotal.toStringAsFixed(2)}'),
                  const SizedBox(height: 8),
                  _buildSummaryRow('Delivery Fee', '\$${deliveryFee.toStringAsFixed(2)}'),
                  const SizedBox(height: 12),
                  Divider(color: Colors.grey[300]),
                  const SizedBox(height: 12),
                  _buildSummaryRow(
                    'Total',
                    '\$${total.toStringAsFixed(2)}',
                    isTotal: true,
                  ),
                  const SizedBox(height: 20),
                  
                  // Checkout Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: TColor.primary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        // Handle checkout
                      },
                      child: Text(
                        'Proceed to Checkout',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
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
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 18 : 16,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: isTotal ? TColor.primaryText : Colors.grey[600],
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 18 : 16,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: isTotal ? TColor.primary : Colors.grey[600],
          ),
        ),
      ],
    );
  }
}





    
    // {
    //   'name': 'Chicken Wings',
    //   'restaurant': 'KFC',
    //   'price': 9.50,
    //   'quantity': 1,
    //   'image': 'assets/images/wings.png',
    // },
    // {
    //   'name': 'Chicken Wings',
    //   'restaurant': 'KFC',
    //   'price': 9.50,
    //   'quantity': 1,
    //   'image': 'assets/images/wings.png',
    // },
    // {
    //   'name': 'Chicken Wings',
    //   'restaurant': 'KFC',
    //   'price': 9.50,
    //   'quantity': 1,
    //   'image': 'assets/images/wings.png',
    // },