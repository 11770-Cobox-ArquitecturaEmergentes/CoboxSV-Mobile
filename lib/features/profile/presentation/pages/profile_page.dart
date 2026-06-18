import 'package:flutter/material.dart';
import 'package:cobox_sv_mobile/app/colors.dart';
import 'package:cobox_sv_mobile/shared/widgets/avatar_widget.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Perfil'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileHeader(textTheme),
            const SizedBox(height: 24),
            _buildSectionTitle(textTheme, 'Informaci\u00f3n Personal'),
            const SizedBox(height: 8),
            _buildInfoCard(textTheme, const [
              _InfoData(Icons.person, 'Nombre', 'Carlos Rodr\u00edguez'),
              _InfoData(Icons.email, 'Email', 'carlos@coboxsv.com'),
              _InfoData(Icons.phone, 'Tel\u00e9fono', '+54 11 1234-5678'),
              _InfoData(Icons.badge, 'Licencia', 'LIC-2026-12345'),
            ]),
            const SizedBox(height: 16),
            _buildSectionTitle(textTheme, 'Veh\u00edculo'),
            const SizedBox(height: 8),
            _buildInfoCard(textTheme, const [
              _InfoData(Icons.local_shipping, 'Marca/Modelo', 'Ford F-350'),
              _InfoData(Icons.settings, 'Tipo', 'Cami\u00f3n'),
              _InfoData(Icons.speed, 'Capacidad', '3.5 toneladas'),
            ]),
            const SizedBox(height: 16),
            _buildSectionTitle(textTheme, 'Configuraci\u00f3n'),
            const SizedBox(height: 8),
            _buildSettingsCard(),
            const SizedBox(height: 16),
            Center(child: _buildLogoutButton()),
            const SizedBox(height: 8),
            Center(
              child: Text(
                'Versi\u00f3n 1.0.0',
                style: textTheme.bodySmall?.copyWith(color: AppColors.gray400),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(TextTheme textTheme) {
    return Center(
      child: Column(
        children: [
          const AvatarWidget(name: 'Carlos', size: 80),
          const SizedBox(height: 12),
          Text(
            'Carlos Rodr\u00edguez',
            style: textTheme.titleLarge,
          ),
          const SizedBox(height: 2),
          Text(
            'Conductor',
            style: textTheme.bodyMedium?.copyWith(color: AppColors.gray500),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.directions_car, size: 16, color: AppColors.gray500),
                const SizedBox(width: 6),
                Text(
                  'ABC-1234',
                  style: textTheme.bodySmall?.copyWith(color: AppColors.gray600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(TextTheme textTheme, String title) {
    return Text(
      title,
      style: textTheme.titleSmall?.copyWith(color: AppColors.gray500),
    );
  }

  Widget _buildInfoCard(TextTheme textTheme, List<_InfoData> items) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: List.generate(items.length * 2 - 1, (index) {
            if (index.isOdd) {
              return const Divider(height: 1, color: AppColors.divider);
            }
            final item = items[index ~/ 2];
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Row(
                children: [
                  Icon(item.icon, size: 24, color: AppColors.gray500),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.label,
                          style: textTheme.bodySmall?.copyWith(color: AppColors.gray500),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          item.value,
                          style: textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildSettingsCard() {
    return Card(
      margin: EdgeInsets.zero,
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.notifications_outlined, color: AppColors.gray500),
            title: const Text('Notificaciones'),
            trailing: const Switch(value: true, onChanged: null),
          ),
          const Divider(height: 1, indent: 72, color: AppColors.divider),
          ListTile(
            leading: const Icon(Icons.language, color: AppColors.gray500),
            title: const Text('Idioma'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Espa\u00f1ol', style: TextStyle(color: AppColors.gray500)),
                const SizedBox(width: 4),
                Icon(Icons.chevron_right, color: AppColors.gray400),
              ],
            ),
          ),
          const Divider(height: 1, indent: 72, color: AppColors.divider),
          ListTile(
            leading: const Icon(Icons.dark_mode, color: AppColors.gray500),
            title: const Text('Tema Oscuro'),
            trailing: const Switch(value: false, onChanged: null),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton() {
    return OutlinedButton(
      onPressed: () {},
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.danger,
        side: const BorderSide(color: AppColors.danger),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        minimumSize: const Size(double.infinity, 48),
      ),
      child: const Text('Cerrar Sesi\u00f3n'),
    );
  }
}

class _InfoData {
  final IconData icon;
  final String label;
  final String value;

  const _InfoData(this.icon, this.label, this.value);
}
