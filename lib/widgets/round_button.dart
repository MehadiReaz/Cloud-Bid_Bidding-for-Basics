import 'package:flutter/material.dart';

class RoundButton extends StatelessWidget {
  final VoidCallback onTap;
  final String title;
  final bool isBidOver;
  final bool isLoading;

  const RoundButton({
    super.key,
    required this.onTap,
    required this.title,
    this.isBidOver = false,
    this.isLoading = false, // Default value is false
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isBidOver ? null : onTap, // Disable button if bid is over
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.deepPurple,
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
      ),
      child: Text(
        isBidOver ? 'Bid is over' : title,
        style: TextStyle(
          color: isBidOver ? Colors.red : Colors.white,
        ),
      ),
    );
  }
}
