import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/settings_service.dart';
import '../services/sms_capture.dart';
import '../theme/app_theme.dart';
import '../theme/theme_controller.dart';
import 'package:provider/provider.dart';
import 'sms_parser_test_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late TextEditingController _apiKeyController;
  late TextEditingController _modelController;
  late TextEditingController _baseUrlController;
  bool _obscureKey = true;
  bool _hasChanges = false;
  int _smsImportDays = 30;

  @override
  void initState() {
    super.initState();
    _apiKeyController = TextEditingController(text: SettingsService.nvidiaApiKey);
    _modelController = TextEditingController(text: SettingsService.nvidiaModel);
    _baseUrlController = TextEditingController(text: SettingsService.nvidiaBaseUrl);
    _smsImportDays = SettingsService.get<int>('sms_import_days', defaultValue: 30);
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    _modelController.dispose();
    _baseUrlController.dispose();
    super.dispose();
  }

  void _markChanged() {
    if (!_hasChanges) setState(() => _hasChanges = true);
  }

  Future<void> _saveSettings() async {
    SettingsService.nvidiaApiKey = _apiKeyController.text.trim();
    SettingsService.nvidiaModel = _modelController.text.trim();
    SettingsService.nvidiaBaseUrl = _baseUrlController.text.trim();
    await SettingsService.set<int>('sms_import_days', _smsImportDays);
    setState(() => _hasChanges = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Settings saved'), behavior: SnackBarBehavior.floating),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeController>();
    final isDark = AppTheme.isDark(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        if (_hasChanges)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            color: AppTheme.brandPrimary.withValues(alpha: 0.1),
            child: Row(
              children: [
                Icon(Icons.info_outline_rounded, size: 18, color: AppTheme.brandPrimary),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text('Unsaved changes', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                ),
                GestureDetector(
                  onTap: _saveSettings,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [AppTheme.brandPrimary, AppTheme.brandSecondary]),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check_rounded, size: 16, color: Colors.white),
                        SizedBox(width: 6),
                        Text('Save', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
            children: [
              _ProfileHeader(isDark: isDark),
              const SizedBox(height: 24),

              _IOSSection(
                title: 'APPEARANCE',
                children: [
                  _IOSSwitchRow(
                    icon: Icons.dark_mode_rounded,
                    iconColor: AppTheme.brandPrimary,
                    title: 'Dark Mode',
                    subtitle: theme.mode == ThemeMode.dark ? 'On' : 'Off',
                    value: theme.mode == ThemeMode.dark,
                    onChanged: (_) => theme.toggle(),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              _IOSSection(
                title: 'AI CONFIGURATION',
                children: [
                  _IOSInputRow(
                    icon: Icons.key_rounded,
                    iconColor: AppTheme.brandAccent,
                    title: 'API Key',
                    controller: _apiKeyController,
                    obscure: _obscureKey,
                    onChanged: (_) => _markChanged(),
                    suffix: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(
                            _obscureKey ? Icons.visibility_rounded : Icons.visibility_off_rounded,
                            size: 20,
                            color: AppTheme.brandMuted,
                          ),
                          onPressed: () => setState(() => _obscureKey = !_obscureKey),
                        ),
                        IconButton(
                          icon: const Icon(Icons.content_paste_rounded, size: 20, color: AppTheme.brandMuted),
                          onPressed: () async {
                            final data = await Clipboard.getData(Clipboard.kTextPlain);
                            if (data?.text != null) {
                              _apiKeyController.text = data!.text!;
                              _markChanged();
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  _IOSInputRow(
                    icon: Icons.memory_rounded,
                    iconColor: AppTheme.brandPrimary,
                    title: 'Model',
                    hint: 'thinkingmachines/inkling',
                    controller: _modelController,
                    onChanged: (_) => _markChanged(),
                  ),
                  _IOSInputRow(
                    icon: Icons.link_rounded,
                    iconColor: AppTheme.brandSecondary,
                    title: 'Base URL',
                    hint: 'https://integrate.api.nvidia.com/v1',
                    controller: _baseUrlController,
                    onChanged: (_) => _markChanged(),
                    showDivider: false,
                  ),
                ],
              ),
              const SizedBox(height: 8),

              _StatusBadge(
                configured: SettingsService.isNvidiaConfigured,
              ),

              _InfoTip(
                text: 'Get your API key from build.nvidia.com',
              ),
              const SizedBox(height: 24),

              _IOSSection(
                title: 'SMS PARSING',
                children: [
                  _SegmentedDaysSelector(
                    selectedDays: _smsImportDays,
                    onChanged: (days) {
                      setState(() {
                        _smsImportDays = days;
                        _markChanged();
                      });
                    },
                    isDark: isDark,
                  ),
                  _IOSButtonRow(
                    icon: Icons.refresh_rounded,
                    iconColor: AppTheme.brandPrimary,
                    title: 'Re-import SMS',
                    subtitle: 'Scan inbox again with current settings',
                    onPressed: () async {
                      await SmsCaptureService.reimportInbox();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('SMS re-import complete'),
                            backgroundColor: AppTheme.brandPrimary,
                          ),
                        );
                      }
                    },
                  ),
                  _IOSButtonRow(
                    icon: Icons.science_rounded,
                    iconColor: AppTheme.brandPrimary,
                    title: 'Test Parser',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SmsParserTestScreen()),
                      );
                    },
                    showDivider: false,
                  ),
                ],
              ),
              const SizedBox(height: 24),

              _IOSSection(
                title: 'DATA',
                children: [
                  _IOSButtonRow(
                    icon: Icons.delete_sweep_rounded,
                    iconColor: colorScheme.error,
                    title: 'Clear All Data',
                    subtitle: 'Remove all transactions and settings',
                    isDestructive: true,
                    onPressed: () => _showClearDialog(context),
                    showDivider: false,
                  ),
                ],
              ),
              const SizedBox(height: 24),

              _IOSSection(
                title: 'ABOUT',
                children: [
                  _IOSInfoRow(label: 'Version', value: '2.0.0'),
                  _IOSInfoRow(label: 'Storage', value: 'Local (Hive)'),
                  _IOSInfoRow(label: 'AI Provider', value: 'NVIDIA NIM', showDivider: false),
                ],
              ),

              const SizedBox(height: 20),
              Text(
                ' ',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.brandMuted,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showClearDialog(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = AppTheme.isDark(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: colorScheme.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.warning_amber_rounded, color: colorScheme.error, size: 22),
            ),
            const SizedBox(width: 14),
            const Text('Clear All Data?'),
          ],
        ),
        content: const Text(
          'This will permanently delete all your transactions, reports, and settings. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: colorScheme.error),
            onPressed: () async {
              await SettingsService.clearAll();
              if (ctx.mounted) {
                Navigator.pop(ctx);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('All data cleared'), behavior: SnackBarBehavior.floating),
                  );
                }
              }
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Widgets
// ══════════════════════════════════════════════════════════════════════════════

class _ProfileHeader extends StatelessWidget {
  final bool isDark;
  const _ProfileHeader({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  AppTheme.brandSecondary.withValues(alpha: 0.3),
                  AppTheme.brandPrimary.withValues(alpha: 0.15),
                  AppTheme.brandDark,
                ]
              : [
                  AppTheme.brandPrimary,
                  AppTheme.brandSecondary,
                  AppTheme.brandDark,
                ],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppTheme.brandAccent.withValues(alpha: 0.3),
                width: 1.5,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Image.asset(
                'assets/images/moneta-logo.png',
                width: 56,
                height: 56,
                errorBuilder: (_, __, ___) => const Center(
                  child: Icon(Icons.account_balance_wallet_rounded, color: AppTheme.brandAccent, size: 28),
                ),
              ),
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Moneta',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'v2.0.0',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.brandAccent,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Smart Personal Finance',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: AppTheme.brandAccent,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppTheme.brandAccent.withValues(alpha: 0.5),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _IOSSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _IOSSection({
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            title,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppTheme.brandMuted,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.8,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }
}

class _IOSSwitchRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _IOSSwitchRow({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onChanged(!value),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500)),
                    const SizedBox(height: 2),
                    Text(subtitle, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppTheme.brandMuted)),
                  ],
                ),
              ),
              _IOSSwitch(value: value, onChanged: onChanged),
            ],
          ),
        ),
      ),
    );
  }
}

class _IOSSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const _IOSSwitch({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 51,
        height: 31,
        decoration: BoxDecoration(
          color: value ? AppTheme.brandPrimary : const Color(0xFFE5E5EA),
          borderRadius: BorderRadius.circular(15.5),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 200),
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 27,
            height: 27,
            margin: const EdgeInsets.symmetric(horizontal: 2),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(13.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _IOSInputRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String? hint;
  final TextEditingController controller;
  final bool obscure;
  final Widget? suffix;
  final void Function(String)? onChanged;
  final bool showDivider;

  const _IOSInputRow({
    required this.icon,
    required this.iconColor,
    required this.title,
    this.hint,
    required this.controller,
    this.obscure = false,
    this.suffix,
    this.onChanged,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Container(
                  height: 44,
                  alignment: Alignment.centerLeft,
                  child: TextField(
                    controller: controller,
                    obscureText: obscure,
                    onChanged: onChanged,
                    style: Theme.of(context).textTheme.bodyMedium,
                    decoration: InputDecoration(
                      hintText: hint,
                      hintStyle: TextStyle(color: AppTheme.brandMuted.withValues(alpha: 0.5), fontSize: 14),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
              ),
              if (suffix != null) suffix!,
            ],
          ),
        ),
        if (showDivider)
          Divider(height: 0.5, thickness: 0.5, indent: 66, color: Theme.of(context).dividerColor.withValues(alpha: 0.3)),
      ],
    );
  }
}

class _IOSButtonRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final bool isDestructive;
  final VoidCallback onPressed;
  final bool showDivider;

  const _IOSButtonRow({
    required this.icon,
    required this.iconColor,
    required this.title,
    this.subtitle,
    this.isDestructive = false,
    required this.onPressed,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDestructive ? Colors.red : iconColor;
    return Column(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, color: color, size: 18),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: isDestructive ? Colors.red : null,
                        )),
                        if (subtitle != null) ...[
                          const SizedBox(height: 2),
                          Text(subtitle!, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppTheme.brandMuted)),
                        ],
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right_rounded, color: AppTheme.brandMuted.withValues(alpha: 0.4), size: 20),
                ],
              ),
            ),
          ),
        ),
        if (showDivider)
          Divider(height: 0.5, thickness: 0.5, indent: 60, color: Theme.of(context).dividerColor.withValues(alpha: 0.3)),
      ],
    );
  }
}

class _IOSInfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool showDivider;

  const _IOSInfoRow({required this.label, required this.value, this.showDivider = true});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.brandMuted)),
              Text(value, style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppTheme.brandSecondary,
              )),
            ],
          ),
        ),
        if (showDivider)
          Divider(height: 0.5, thickness: 0.5, indent: 16, color: Theme.of(context).dividerColor.withValues(alpha: 0.3)),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final bool configured;

  const _StatusBadge({required this.configured});

  @override
  Widget build(BuildContext context) {
    final color = configured ? AppTheme.brandPrimary : Colors.orange;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 10),
          Text(
            configured ? 'API Key Configured' : 'API Key Not Set',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoTip extends StatelessWidget {
  final String text;

  const _InfoTip({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.brandPrimary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline_rounded, size: 16, color: AppTheme.brandPrimary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.brandMuted,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SegmentedDaysSelector extends StatelessWidget {
  final int selectedDays;
  final ValueChanged<int> onChanged;
  final bool isDark;

  const _SegmentedDaysSelector({
    required this.selectedDays,
    required this.onChanged,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final options = [7, 14, 30, 60, 90];
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Import from the last $selectedDays days',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppTheme.brandMuted),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withValues(alpha: 0.06) : const Color(0xFFF2F2F7),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: options.map((days) {
                final isSelected = days == selectedDays;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => onChanged(days),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.white : Colors.transparent,
                        borderRadius: BorderRadius.circular(6),
                        boxShadow: isSelected
                            ? [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 3, offset: const Offset(0, 1))]
                            : [],
                      ),
                      child: Center(
                        child: Text(
                          '${days}d',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                            color: isSelected ? AppTheme.brandPrimary : AppTheme.brandMuted,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
