import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final currentLocale = context.locale.languageCode;

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
      children: [
        _buildSectionHeader(context, 'language'.tr()),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E24),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0x1AFFFFFF), width: 1),
            boxShadow: const [
              BoxShadow(
                color: Color(0x80000000),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'language'.tr().toUpperCase(),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                  color: Color(0x80FFFFFF),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildLangButton(
                      context,
                      title: 'english'.tr(),
                      isSelected: currentLocale == 'en',
                      onTap: () {
                        context.setLocale(const Locale('en'));
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildLangButton(
                      context,
                      title: 'arabic'.tr(),
                      isSelected: currentLocale == 'ar',
                      onTap: () {
                        context.setLocale(const Locale('ar'));
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(BuildContext context, String text) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 4),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 20,
            decoration: BoxDecoration(
              color: primaryColor,
              borderRadius: BorderRadius.circular(2),
              boxShadow: [
                BoxShadow(color: primaryColor, blurRadius: 8, spreadRadius: 1),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            text.toUpperCase(),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 2.0,
              color: primaryColor,
              shadows: [Shadow(color: primaryColor, blurRadius: 4)],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLangButton(
    BuildContext context, {
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? colorScheme.primary : const Color(0x0DFFFFFF),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? colorScheme.primary : const Color(0x1AFFFFFF),
            width: 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: colorScheme.primary,
                    blurRadius: 12,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
        alignment: Alignment.center,
        child: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: isSelected
                ? const Color(0xFF000000)
                : const Color(0xFFFFFFFF),
          ),
        ),
      ),
    );
  }
}
