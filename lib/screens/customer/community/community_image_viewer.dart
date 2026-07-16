import 'package:flutter/material.dart';

import '../../../services/cloudinary_upload_service.dart';
import '../../../theme/app_colors.dart';

Future<void> showCommunityImageViewer(
    BuildContext context, {
      required List<String> imageUrls,
      required int initialIndex,
    }) async {
  if (imageUrls.isEmpty) {
    return;
  }

  final safeInitialIndex = initialIndex
      .clamp(0, imageUrls.length - 1)
      .toInt();

  await Navigator.of(
    context,
    rootNavigator: true,
  ).push<void>(
    MaterialPageRoute<void>(
      fullscreenDialog: true,
      builder: (context) {
        return CommunityImageViewer(
          imageUrls: imageUrls,
          initialIndex: safeInitialIndex,
        );
      },
    ),
  );
}

class CommunityImageViewer extends StatefulWidget {
  final List<String> imageUrls;
  final int initialIndex;

  const CommunityImageViewer({
    super.key,
    required this.imageUrls,
    required this.initialIndex,
  });

  @override
  State<CommunityImageViewer> createState() =>
      _CommunityImageViewerState();
}

class _CommunityImageViewerState
    extends State<CommunityImageViewer> {
  late final PageController _pageController;
  late int currentIndex;

  @override
  void initState() {
    super.initState();

    currentIndex = widget.initialIndex;

    _pageController = PageController(
      initialPage: widget.initialIndex,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Text(
          '${currentIndex + 1}/${widget.imageUrls.length}',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Đóng',
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: const Icon(Icons.close_rounded),
          ),
        ],
      ),
      body: PageView.builder(
        controller: _pageController,
        itemCount: widget.imageUrls.length,
        onPageChanged: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        itemBuilder: (context, index) {
          final imageUrl =
          CloudinaryUploadService.optimizedImageUrl(
            widget.imageUrls[index],
          );

          return InteractiveViewer(
            minScale: 1,
            maxScale: 5,
            boundaryMargin: const EdgeInsets.all(80),
            child: Center(
              child: Image.network(
                imageUrl,
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.contain,
                loadingBuilder: (
                    context,
                    child,
                    loadingProgress,
                    ) {
                  if (loadingProgress == null) {
                    return child;
                  }

                  return const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primary,
                    ),
                  );
                },
                errorBuilder: (
                    context,
                    error,
                    stackTrace,
                    ) {
                  return const Center(
                    child: Text(
                      'Không tải được ảnh.',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}