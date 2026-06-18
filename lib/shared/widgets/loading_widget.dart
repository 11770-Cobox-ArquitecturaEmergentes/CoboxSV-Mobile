import 'package:flutter/material.dart';
import 'package:cobox_sv_mobile/app/colors.dart';

class LoadingWidget extends StatelessWidget {
  const LoadingWidget({
    super.key,
    this.message,
  });

  final String? message;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: AppColors.primary,
            strokeWidth: 3,
          ),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

class SkeletonLoading extends StatelessWidget {
  const SkeletonLoading({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildCardShimmer(),
          const SizedBox(height: 12),
          _buildCardShimmer(),
          const SizedBox(height: 12),
          _buildCardShimmer(),
        ],
      ),
    );
  }

  Widget _buildCardShimmer() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildShimmerBar(width: 40, height: 12),
          const SizedBox(height: 16),
          _buildShimmerBar(width: double.infinity, height: 16),
          const SizedBox(height: 8),
          _buildShimmerBar(width: 160, height: 12),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildShimmerBar(width: 80, height: 10),
              const Spacer(),
              _buildShimmerBar(width: 60, height: 10),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerBar({double? width, double? height}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.gray100,
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}
