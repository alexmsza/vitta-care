import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:vitta/core/theme/app_colors.dart';

class DocumentUploadScreen extends StatefulWidget {
  final bool isProfessional;

  const DocumentUploadScreen({required this.isProfessional, super.key});

  @override
  State<DocumentUploadScreen> createState() => _DocumentUploadScreenState();
}

class _DocumentUploadScreenState extends State<DocumentUploadScreen> {
  // Mock status: 'pending', 'uploaded', 'verified', 'rejected'
  final Map<String, String> _docStatus = {
    'identity': 'verified',
    'residence': 'pending',
    'professional_license': 'rejected', // COREN for pros
    'background_check': 'uploaded',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Validação de Documentos',
            style: GoogleFonts.inter(
                fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 32),
            _buildDocItem(
                'Documento de Identidade (RG/CNH)', 'identity', Icons.badge),
            const SizedBox(height: 16),
            _buildDocItem('Comprovante de Residência', 'residence', Icons.home),
            const SizedBox(height: 16),
            if (widget.isProfessional) ...[
              _buildDocItem('Registro Profissional (COREN/CRM)',
                  'professional_license', Icons.workspace_premium),
              const SizedBox(height: 16),
              _buildDocItem(
                  'Antecedentes Criminais', 'background_check', Icons.policy),
            ] else ...[
              _buildDocItem('Laudo Médico (Opcional)', 'medical_report',
                  Icons.medical_services),
            ],
            const SizedBox(height: 40),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: AppColors.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Seus documentos são criptografados e acessíveis apenas pela equipe de validação da Vitta.',
                      style: GoogleFonts.inter(
                          fontSize: 12, color: AppColors.textPrimary),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Verificação de Segurança',
          style: GoogleFonts.inter(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary),
        ),
        const SizedBox(height: 8),
        Text(
          'Para garantir a segurança de todos na plataforma, precisamos validar alguns documentos.',
          style:
              GoogleFonts.inter(fontSize: 14, color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildDocItem(String title, String key, IconData icon) {
    String status = _docStatus[key] ?? 'pending';
    Color statusColor;
    String statusText;

    switch (status) {
      case 'verified':
        statusColor = AppColors.success;
        statusText = 'Verificado';
        break;
      case 'uploaded':
        statusColor = Colors.blue;
        statusText = 'Em Análise';
        break;
      case 'rejected':
        statusColor = AppColors.error;
        statusText = 'Recusado';
        break;
      default:
        statusColor = AppColors.textSecondary;
        statusText = 'Pendente';
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.textPrimary, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary),
                ),
                Text(
                  statusText,
                  style: GoogleFonts.inter(
                      fontSize: 12,
                      color: statusColor,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _uploadDocument(key),
            icon: Icon(
              status == 'verified'
                  ? Icons.visibility
                  : Icons.cloud_upload_outlined,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  void _uploadDocument(String key) {
    if (_docStatus[key] == 'verified') {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Documento já verificado.')));
      return;
    }

    // Mock upload Action
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Enviar Documento',
                style: GoogleFonts.inter(
                    fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: AppColors.primary),
              title: const Text('Tirar Foto'),
              onTap: () {
                Navigator.pop(ctx);
                setState(() => _docStatus[key] = 'uploaded');
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Foto enviada para análise!')));
              },
            ),
            ListTile(
              leading: const Icon(Icons.image, color: AppColors.primary),
              title: const Text('Escolher da Galeria'),
              onTap: () {
                Navigator.pop(ctx);
                setState(() => _docStatus[key] = 'uploaded');
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Arquivo enviado para análise!')));
              },
            ),
          ],
        ),
      ),
    );
  }
}
