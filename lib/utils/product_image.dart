import 'package:flutter/material.dart';

/// Returns an [Image] widget that handles both local asset paths and http URLs.
Widget productImage(String url, {double? height, BoxFit fit = BoxFit.contain}) {
  if (url.startsWith('http')) {
    return Image.network(
      url,
      height: height,
      fit: fit,
      errorBuilder: (_, __, ___) =>
          const Icon(Icons.broken_image, size: 60, color: Colors.grey),
    );
  }
  return Image.asset(url, height: height, fit: fit);
}
