import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/models/faq_item.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/faq_provider.dart';

class FaqScreen extends ConsumerStatefulWidget {
  const FaqScreen({super.key});

  @override
  ConsumerState<FaqScreen> createState() => _FaqScreenState();
}

class _FaqScreenState extends ConsumerState<FaqScreen> {
  String? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    final faqAsync = ref.watch(faqItemsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Perguntas Frequentes',
          style: GoogleFonts.inter(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: faqAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline,
                  size: 48, color: AppColors.error),
              const SizedBox(height: 12),
              Text(
                'Não foi possível carregar o FAQ.',
                style: GoogleFonts.inter(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 16),
              FilledButton(
                style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary),
                onPressed: () => ref.invalidate(faqItemsProvider),
                child: const Text('Tentar novamente'),
              ),
            ],
          ),
        ),
        data: (items) {
          if (items.isEmpty) {
            return Center(
              child: Text(
                'Nenhuma pergunta disponível.',
                style: GoogleFonts.inter(color: AppColors.textSecondary),
              ),
            );
          }

          // Extract unique categories
          final categories = items
              .map((i) => i.category)
              .toSet()
              .toList()
            ..sort();

          // Filter items
          final filtered = _selectedCategory == null
              ? items
              : items
                  .where((i) => i.category == _selectedCategory)
                  .toList();

          // Group by category
          final grouped = <String, List<FaqItem>>{};
          for (final item in filtered) {
            grouped.putIfAbsent(item.category, () => []).add(item);
          }

          return Column(
            children: [
              // Category filter chips
              Container(
                color: AppColors.surface,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: const Text('Todos'),
                          selected: _selectedCategory == null,
                          selectedColor:
                              AppColors.primary.withValues(alpha: 0.15),
                          checkmarkColor: AppColors.primary,
                          labelStyle: GoogleFonts.inter(
                            color: _selectedCategory == null
                                ? AppColors.primary
                                : AppColors.textSecondary,
                            fontWeight: _selectedCategory == null
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                          onSelected: (_) =>
                              setState(() => _selectedCategory = null),
                        ),
                      ),
                      ...categories.map(
                        (cat) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: Text(cat),
                            selected: _selectedCategory == cat,
                            selectedColor:
                                AppColors.primary.withValues(alpha: 0.15),
                            checkmarkColor: AppColors.primary,
                            labelStyle: GoogleFonts.inter(
                              color: _selectedCategory == cat
                                  ? AppColors.primary
                                  : AppColors.textSecondary,
                              fontWeight: _selectedCategory == cat
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                            onSelected: (_) =>
                                setState(() => _selectedCategory = cat),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // FAQ list
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.only(bottom: 32),
                  children: [
                    for (final category in grouped.keys) ...[
                      _CategoryHeader(category: category),
                      ...grouped[category]!.map(
                        (item) => _FaqTile(item: item),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _CategoryHeader extends StatelessWidget {
  final String category;
  const _CategoryHeader({required this.category});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      child: Text(
        category.toUpperCase(),
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
          color: AppColors.primary,
        ),
      ),
    );
  }
}

class _FaqTile extends StatelessWidget {
  final FaqItem item;
  const _FaqTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
        ),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
          childrenPadding:
              const EdgeInsets.fromLTRB(16, 0, 16, 16),
          expandedCrossAxisAlignment: CrossAxisAlignment.start,
          iconColor: AppColors.primary,
          collapsedIconColor: AppColors.textSecondary,
          title: Text(
            item.question,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
              height: 1.4,
            ),
          ),
          children: [
            Text(
              item.answer,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
