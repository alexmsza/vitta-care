import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:vitta/core/theme/app_colors.dart';

class UserProfileScreen extends StatelessWidget {
  const UserProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 40),
        child: Column(
          children: [
            // Header with Gradient
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(
                  top: 60, bottom: 40, left: 24, right: 24),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.vittaPetrol, AppColors.vittaPetrolLight],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
              ),
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: const CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.person,
                          size: 50, color: AppColors.primary),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Maria Silva',
                    style: GoogleFonts.inter(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'maria.silva@email.com',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Settings Sections
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  _buildSectionTitle('Minha Saúde'),
                  const SizedBox(height: 16),
                  _buildSettingsTile(
                    context,
                    icon: Icons.medical_information,
                    title: 'Anamnese Digital',
                    subtitle: 'Alergias, medicamentos e rotina',
                    onTap: () => context.push('/clinical-record'),
                  ),
                  const SizedBox(height: 12),
                  _buildSettingsTile(
                    context,
                    icon: Icons.history,
                    title: 'Histórico de Atendimentos',
                    subtitle: 'Ver consultas passadas',
                    onTap: () => context.push('/history'),
                  ),

                  const SizedBox(height: 32),
                  _buildSectionTitle('Conta'),
                  const SizedBox(height: 16),
                  _buildSettingsTile(
                    context,
                    icon: Icons.verified_user,
                    title: 'Validação de Identidade',
                    subtitle: 'Envie seus documentos',
                    onTap: () => context.push('/document-upload'),
                  ),
                  const SizedBox(height: 12),
                  _buildSettingsTile(
                    context,
                    icon: Icons.person_outline,
                    title: 'Dados Pessoais',
                    subtitle: 'Nome, telefone, endereço',
                    onTap: () {},
                  ),
                  const SizedBox(height: 12),
                  _buildSettingsTile(
                    context,
                    icon: Icons.credit_card,
                    title: 'Pagamentos',
                    subtitle: 'Cartões e faturas',
                    onTap: () {},
                  ),
                  const SizedBox(height: 12),
                  _buildSettingsTile(
                    context,
                    icon: Icons.notifications_outlined,
                    title: 'Notificações',
                    subtitle: 'Alertas e mensagens',
                    onTap: () {},
                    trailing: Switch(
                      value: true,
                      onChanged: (val) {},
                      activeThumbColor: AppColors.primary,
                    ),
                  ),

                  const SizedBox(height: 48),

                  // Logout Button
                  InkWell(
                    onTap: () => context.go('/login'),
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: AppColors.error.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                        border:
                            Border.all(color: AppColors.error.withValues(alpha: 0.2)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.logout, color: AppColors.error),
                          const SizedBox(width: 8),
                          Text(
                            'Sair da Conta',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.error,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Versão 1.0.0 (Build 42)',
                    style: GoogleFonts.inter(
                        fontSize: 12, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildSettingsTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Widget? trailing,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.vittaSageLight.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppColors.primary, size: 24),
        ),
        title: Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: GoogleFonts.inter(
            fontSize: 13,
            color: AppColors.textSecondary,
          ),
        ),
        trailing: trailing ??
            const Icon(Icons.chevron_right, color: AppColors.textSecondary),
      ),
    );
  }
}
