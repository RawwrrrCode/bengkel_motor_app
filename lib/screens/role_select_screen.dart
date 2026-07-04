import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/app_provider.dart';
import '../theme/app_colors.dart';

class RoleSelectScreen extends StatelessWidget {
  const RoleSelectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pageBgBottom,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(18),
                ),
                alignment: Alignment.center,
                child: const Text('B',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 28)),
              ),
              const SizedBox(height: 16),
              const Text('BengkelKu',
                  style: TextStyle(
                      fontWeight: FontWeight.w800, fontSize: 22, color: AppColors.textPrimary)),
              const SizedBox(height: 6),
              const Text('Mau masuk sebagai apa hari ini?',
                  style: TextStyle(fontSize: 13.5, color: AppColors.textSecondary)),
              const SizedBox(height: 32),
              _RoleCard(
                icon: Icons.two_wheeler,
                title: 'Pengguna Motor',
                subtitle: 'Cari bengkel, booking servis, dan pantau riwayat perawatan motormu.',
                onTap: () => context.read<AppProvider>().chooseRole(UserRole.user),
              ),
              const SizedBox(height: 14),
              _RoleCard(
                icon: Icons.store,
                title: 'Pemilik Bengkel',
                subtitle: 'Kelola pengajuan servis masuk, stok sparepart, dan riwayat pelanggan.',
                onTap: () => context.read<AppProvider>().chooseRole(UserRole.bengkel),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _RoleCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.cardBorder),
            borderRadius: BorderRadius.circular(18),
          ),
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.primaryTint(0.1),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(icon, color: AppColors.primary, size: 27),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            fontWeight: FontWeight.w800, fontSize: 15.5, color: AppColors.textPrimary)),
                    const SizedBox(height: 3),
                    Text(subtitle,
                        style: const TextStyle(
                            fontSize: 12.5, color: AppColors.textSecondary, height: 1.4)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.textFaint),
            ],
          ),
        ),
      ),
    );
  }
}
