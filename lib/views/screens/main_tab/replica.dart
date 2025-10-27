import 'package:flutter/material.dart';
import 'package:food_delivery_customer/constants/colors.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FocusNode _focusNode = FocusNode();
  final TextEditingController _controller = TextEditingController();
  bool _isFocused = false;

  @override
  void initState() {
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _unfocusSearch() {
    _focusNode.unfocus();
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: media.height * 0.05,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.location_on, color: Colors.green),
                  SizedBox(width: media.width * 0.03),
                  Text(
                    "Kampala, Uganda",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(width: media.width * 0.03),
                  const Icon(Icons.arrow_drop_down, color: Colors.black54),
                ],
              ),
              const SizedBox(height: 20),

              
              Row(
                children: [
                  if (_isFocused)
                    IconButton(
                      icon: Icon(Icons.arrow_back_ios, color: TColor.primary,),
                      onPressed: _unfocusSearch,
                    ),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      focusNode: _focusNode,
                      textAlign: _isFocused ? TextAlign.start : TextAlign.center,
                      decoration: InputDecoration(
                        hintText: 'What are you craving today?',
                        hintStyle: const TextStyle(color: Colors.grey),
                        prefixIcon: Padding(
                          padding: const EdgeInsets.only(left: 12),
                          child: Icon(Icons.search, color: Colors.grey[600]),
                        ),
                        prefixIconConstraints: const BoxConstraints(
                          minWidth: 40,
                          minHeight: 40,
                        ),
                        filled: true,
                        fillColor: Colors.grey[100],
                        contentPadding: const EdgeInsets.symmetric(vertical: 16),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: const BorderSide(color: Colors.green),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // You can add more widgets here...
            ],
          ),
        ),
      ),
    );
  }
}
