import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  const CustomButton({
    Key? key,
    required this.label,
    required this.onPressed,
    this.disabled = false,
  }) : super(key: key);

  final String label;
  final bool? disabled;
  final void Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: disabled == false ? onPressed : null,
      style: ElevatedButton.styleFrom(
        primary: disabled == false ? Colors.orange[900] : Colors.grey[400],
        minimumSize: const Size.fromHeight(50),
      ),
      child: Text(label),
    );
  }
}
