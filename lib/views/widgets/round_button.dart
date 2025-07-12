import 'package:flutter/material.dart';

class RoundButton extends StatelessWidget {
  final String title;
  final VoidCallback onPressed;
  final IconData? icon;
  final Color bgcolor;   
  final Color color1;     
  final bool isOutlined;

  const RoundButton({
    super.key,
    required this.title,
    required this.onPressed,
    this.icon,
    required this.bgcolor,
    required this.color1,
    this.isOutlined = false,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      onPressed: onPressed,
      height: 60,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(19),
        side: isOutlined ? BorderSide(color: bgcolor, width: 2) : BorderSide.none,
      ),
      minWidth: double.maxFinite,
      elevation: 0.1,
      color: isOutlined ? Colors.white : bgcolor, 
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Icon(icon, color: color1, size: 30),
          const SizedBox(width: 20),
          Text(
            title,
            style: TextStyle(
              color: color1,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
