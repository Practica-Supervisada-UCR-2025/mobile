import 'package:flutter/material.dart';

class SecondaryButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isLoading;
  final String text;
  final bool isEnabled;
  final double height;
  final double width;

  const SecondaryButton({
    super.key,
    required this.onPressed,
    required this.isLoading,
    required this.text,
    required this.isEnabled,
    required this.height,
    required this.width,
  });

  @override
Widget build(BuildContext context) {
  return SizedBox(
    height: height,
    width: width,
    child: ElevatedButton(
      onPressed: (isLoading || !isEnabled) ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Theme.of(context).colorScheme.onPrimary,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        minimumSize: const Size(32, 32), 
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Center(
        child: isLoading
            ? const SizedBox(
                height: 10,
                width: 10,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Text(
                text,
                style: Theme.of(context).textTheme.labelMedium, // Estilo más pequeño
              ),
      ),
    ),
  );
}
}
