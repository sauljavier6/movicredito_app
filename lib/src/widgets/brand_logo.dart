import 'package:flutter/material.dart';

const moviCreditoLogoUrl =
    'https://raw.githubusercontent.com/sauljavier6/movicredito_frontend/main/public/logo.jpg';

class BrandLogo extends StatelessWidget {
  const BrandLogo({super.key, this.size = 64, this.borderRadius = 18});

  final double size;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Container(
        width: size,
        height: size,
        color: Colors.white,
        child: Image.network(
          moviCreditoLogoUrl,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => const Icon(
            Icons.phone_iphone_rounded,
            color: Color(0xFF175CD3),
          ),
        ),
      ),
    );
  }
}
