import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vitta/core/theme/app_colors.dart';

class LiveTrackingScreen extends StatelessWidget {
  const LiveTrackingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Acompanhamento',
            style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Mock Map
          Expanded(
            child: Container(
              width: double.infinity,
              color: Colors.grey[200],
              child: Stack(
                children: [
                  Center(
                    child: Icon(Icons.map, size: 100, color: Colors.grey[400]),
                  ),
                  Center(
                    child: Text(
                      'Mapa em Tempo Real (Mock)',
                      style: GoogleFonts.inter(color: Colors.grey[500]),
                    ),
                  ),
                  // Mock Driver Location
                  const Positioned(
                    top: 150,
                    left: 100,
                    child: CircleAvatar(
                      backgroundColor: AppColors.primary,
                      radius: 20,
                      child:
                          Icon(Icons.motorcycle, color: Colors.white, size: 20),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Status Sheet
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(30)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 20,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    const CircleAvatar(
                      radius: 30,
                      backgroundImage: NetworkImage(
                          'https://i.pravatar.cc/150?u=a042581f4e29026024d'), // Mock image
                      backgroundColor: Colors.grey,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Carlos Santos',
                            style: GoogleFonts.inter(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary),
                          ),
                          Text(
                            'Cuidador',
                            style: GoogleFonts.inter(
                                color: AppColors.textSecondary),
                          ),
                          Row(
                            children: [
                              const Icon(Icons.star,
                                  size: 14, color: Colors.amber),
                              Text(' 4.8',
                                  style: GoogleFonts.inter(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Column(
                      children: [
                        Text(
                          '15 min',
                          style: GoogleFonts.inter(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: AppColors.primary),
                        ),
                        Text(
                          'chegada',
                          style: GoogleFonts.inter(
                              fontSize: 12, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Timeline
                Row(
                  children: [
                    _buildStatusStep('Confirmado', true, true),
                    _buildLine(true),
                    _buildStatusStep('A caminho', true, true),
                    _buildLine(false),
                    _buildStatusStep('Chegou', false, false),
                    _buildLine(false),
                    _buildStatusStep('Iniciado', false, false),
                  ],
                ),
                const SizedBox(height: 32),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.phone),
                        label: const Text('Ligar'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.chat),
                        label: const Text('Chat'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusStep(String label, bool isActive, bool isCompleted) {
    return Column(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: isCompleted ? AppColors.primary : Colors.grey[300],
            shape: BoxShape.circle,
            border: isActive
                ? Border.all(
                    color: AppColors.primary.withValues(alpha: 0.3), width: 4)
                : null,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 10,
            color:
                isCompleted ? AppColors.textPrimary : AppColors.textSecondary,
            fontWeight: isCompleted ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildLine(bool isActive) {
    return Expanded(
      child: Container(
        height: 2,
        color: isActive ? AppColors.primary : Colors.grey[300],
        margin: const EdgeInsets.symmetric(
            horizontal: 4, vertical: 10), // Adjust alignment to circle
      ),
    );
  }
}
