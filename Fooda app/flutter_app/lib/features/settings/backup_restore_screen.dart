import 'package:flutter/material.dart';
import '../../core/services/backup_service.dart';
import '../../l10n/app_localizations.dart';

import '../../features/auth/auth_service.dart';
import 'package:provider/provider.dart';
import '../../features/membership/providers/membership_provider.dart';
import '../../features/membership/membership_screen.dart';

class BackupRestoreScreen extends StatefulWidget {
  const BackupRestoreScreen({super.key});

  @override
  State<BackupRestoreScreen> createState() => _BackupRestoreScreenState();
}

class _BackupRestoreScreenState extends State<BackupRestoreScreen> {
  bool _isLoading = false;
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final loggedIn = await AuthService.isLoggedIn();
    if (mounted) {
      setState(() => _isLoggedIn = loggedIn);
    }
  }

  Future<void> _handleBackup() async {
    setState(() => _isLoading = true);
    
    // 顯示載入指示器
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.creatingBackup),
          duration: const Duration(seconds: 1),
        ),
      );
    }

    final success = await BackupService.exportData(context);
    
    if (mounted) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success 
            ? AppLocalizations.of(context)!.backupSuccess 
            : AppLocalizations.of(context)!.backupFailed),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    }
  }

  Future<void> _handleRestore() async {
    // 顯示確認對話框
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.restoreConfirmTitle),
        content: Text(AppLocalizations.of(context)!.restoreConfirmMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(AppLocalizations.of(context)!.confirm),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isLoading = true);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.restoringData),
          duration: const Duration(seconds: 1),
        ),
      );
    }

    if (!mounted) return;

    final success = await BackupService.importData(context);
    
    if (mounted) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success 
            ? AppLocalizations.of(context)!.restoreSuccess 
            : AppLocalizations.of(context)!.restoreFailed),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
      
      if (success) {
        // 還原成功後，可以選擇返回上一頁或重啟應用
        // 這裡選擇返回上一頁
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.backupAndRestore),
      ),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // CloudKit section removed

              _buildSectionTitle(context, l10n.dataManagement),
              const SizedBox(height: 8),
              _buildCard(
                context,
                title: l10n.backupData,
                description: l10n.backupDesc,
                icon: Icons.save_alt,
                onTap: _handleBackup,
                buttonText: l10n.backupData,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(height: 16),
              _buildCard(
                context,
                title: l10n.restoreData,
                description: l10n.restoreDesc,
                icon: Icons.restore_page,
                onTap: _handleRestore,
                buttonText: l10n.restoreData,
                color: Colors.orange,
                isDestructive: true,
              ),
            ],
          ),
          if (_isLoading)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
        ),
      ),
    );
  }

  Widget _buildCard(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required VoidCallback onTap,
    required String buttonText,
    required Color color,
    bool isDestructive = false,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 32, color: color),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              description,
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.8),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onTap,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDestructive ? Colors.red.shade50 : color.withOpacity(0.1),
                  foregroundColor: isDestructive ? Colors.red : color,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  buttonText,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
