import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class FullScreenImage extends StatelessWidget {
  final String imageUrl;

  const FullScreenImage({
    super.key,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Center(
        child: InteractiveViewer(
          minScale: 1,
          maxScale: 2,
          panEnabled: true,
          child: CachedNetworkImage(
            imageUrl: imageUrl,
            fit: BoxFit.fitWidth,
            placeholder: (_, __) {
              return _imagePlaceholder(loading: true);
            },
          ),
        ),
      ),
    );
  }

  Widget _imagePlaceholder({
    bool loading = false,
  }) {
    return Container(
      color: const Color(0xfff5f5f5),
      child: Center(
        child: loading
            ? const SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(
            strokeWidth: 1.8,
          ),
        )
            : const Icon(
          Icons.image_outlined,
          color: Colors.grey,
          size: 32,
        ),
      ),
    );
  }
}