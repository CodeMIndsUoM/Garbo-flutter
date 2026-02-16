import 'package:flutter/material.dart';
import 'package:garbo_swms/core/theme/colors.dart';

class BinListSection extends StatelessWidget {
  const BinListSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(Icons.delete_outline, color: AppColors.grey900, size: 24),
                const SizedBox(width: 8),
                const Text(
                  'Bins to Check Today',
                  style: TextStyle(
                    fontFamily: 'Arimo',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.grey900,
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.blue50,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                '2 PENDING',
                style: TextStyle(
                  fontFamily: 'Arimo',
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.blue600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildBinItem(
          id: 'BIN-001',
          location: 'Main Street Plaza',
          address: '123 Main St',
        ),
        const SizedBox(height: 12),
        _buildBinItem(
          id: 'BIN-007',
          location: 'Hospital',
          address: '200 Health Ave',
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildBinItem({required String id, required String location, required String address}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(width: 1.27, color: AppColors.grey200),
        boxShadow: const [
          BoxShadow(
            color: Color(0x19000000),
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.grey100,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  id,
                  style: const TextStyle(
                    fontFamily: 'Arimo',
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppColors.grey600,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.blue50,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'NOT CHECKED',
                  style: TextStyle(
                    fontFamily: 'Arimo',
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppColors.blue600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            location,
            style: const TextStyle(
              fontFamily: 'Arimo',
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.grey900,
            ),
          ),
          Text(
            address,
            style: const TextStyle(
              fontFamily: 'Arimo',
              fontSize: 12,
              fontWeight: FontWeight.normal,
              color: AppColors.grey600,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.green700,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x19000000),
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.send_outlined, color: Colors.white, size: 16),
                const SizedBox(width: 8),
                const Text(
                  'Report Fill Level',
                  style: TextStyle(
                    fontFamily: 'Arimo',
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
