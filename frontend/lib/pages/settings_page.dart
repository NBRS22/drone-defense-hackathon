import 'package:flutter/material.dart';
import '../main.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(theme),
          const SizedBox(height: 24),
          _buildThemeSection(context, theme),
          const SizedBox(height: 24),
          _buildProfileSection(theme),
          const SizedBox(height: 24),
          _buildNotificationSection(theme),
          const SizedBox(height: 24),
          _buildSystemSection(theme),
        ],
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.secondary,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.settings_rounded,
              color: Colors.white,
              size: 32,
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Paramètres',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Configurez votre application',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeSection(BuildContext context, ThemeData theme) {
    return _buildSection(
      'Apparence',
      Icons.palette_rounded,
      theme.colorScheme.primary,
      theme,
      [
        ListTile(
          leading: Icon(
            theme.brightness == Brightness.dark
                ? Icons.dark_mode_rounded
                : Icons.light_mode_rounded,
          ),
          title: const Text('Mode sombre'),
          subtitle: Text(
            theme.brightness == Brightness.dark
                ? 'Interface sombre activée'
                : 'Interface claire activée',
          ),
          trailing: Switch(
            value: theme.brightness == Brightness.dark,
            onChanged: (value) {
              // Pour le moment, on affiche juste un message
              // TODO: Implémenter le toggle du thème
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Changement de thème - À implémenter'),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildProfileSection(ThemeData theme) {
    return _buildSection(
      'Profil',
      Icons.person_rounded,
      const Color(0xFF10B981),
      theme,
      [
        ListTile(
          leading: CircleAvatar(
            backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
            child: Icon(
              Icons.person_rounded,
              color: theme.colorScheme.primary,
            ),
          ),
          title: const Text('Nom d\'utilisateur'),
          subtitle: const Text('Administrateur Drone'),
          trailing: const Icon(Icons.edit_rounded),
          onTap: () {
            // TODO: Implémenter l'édition du profil
          },
        ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.email_rounded),
          title: const Text('Email'),
          subtitle: const Text('admin@drone-delivery.com'),
          trailing: const Icon(Icons.edit_rounded),
          onTap: () {
            // TODO: Implémenter l'édition de l'email
          },
        ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.security_rounded),
          title: const Text('Mot de passe'),
          subtitle: const Text('Dernière modification il y a 30 jours'),
          trailing: const Icon(Icons.arrow_forward_ios_rounded),
          onTap: () {
            // TODO: Implémenter le changement de mot de passe
          },
        ),
      ],
    );
  }

  Widget _buildNotificationSection(ThemeData theme) {
    return _buildSection(
      'Notifications',
      Icons.notifications_rounded,
      const Color(0xFFF59E0B),
      theme,
      [
        SwitchListTile(
          secondary: const Icon(Icons.notifications_active_rounded),
          title: const Text('Notifications push'),
          subtitle: const Text('Recevoir les notifications importantes'),
          value: true,
          onChanged: (value) {
            // TODO: Implémenter la gestion des notifications
          },
        ),
        const Divider(),
        SwitchListTile(
          secondary: const Icon(Icons.vibration_rounded),
          title: const Text('Vibration'),
          subtitle: const Text('Vibrer lors des notifications'),
          value: true,
          onChanged: (value) {
            // TODO: Implémenter la gestion des vibrations
          },
        ),
        const Divider(),
        SwitchListTile(
          secondary: const Icon(Icons.volume_up_rounded),
          title: const Text('Sons'),
          subtitle: const Text('Jouer un son pour les alertes'),
          value: false,
          onChanged: (value) {
            // TODO: Implémenter la gestion des sons
          },
        ),
      ],
    );
  }

  Widget _buildSystemSection(ThemeData theme) {
    return _buildSection(
      'Système',
      Icons.settings_applications_rounded,
      const Color(0xFF8B5CF6),
      theme,
      [
        ListTile(
          leading: const Icon(Icons.info_rounded),
          title: const Text('Version de l\'application'),
          subtitle: const Text('1.0.0+1'),
          trailing: const Icon(Icons.arrow_forward_ios_rounded),
          onTap: () {
            // TODO: Afficher les détails de la version
          },
        ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.bug_report_rounded),
          title: const Text('Signaler un problème'),
          subtitle: const Text('Nous aider à améliorer l\'application'),
          trailing: const Icon(Icons.arrow_forward_ios_rounded),
          onTap: () {
            // TODO: Implémenter le signalement de bugs
          },
        ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.privacy_tip_rounded),
          title: const Text('Politique de confidentialité'),
          trailing: const Icon(Icons.arrow_forward_ios_rounded),
          onTap: () {
            // TODO: Afficher la politique de confidentialité
          },
        ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.description_rounded),
          title: const Text('Conditions d\'utilisation'),
          trailing: const Icon(Icons.arrow_forward_ios_rounded),
          onTap: () {
            // TODO: Afficher les CGU
          },
        ),
      ],
    );
  }

  Widget _buildSection(String title, IconData icon, Color color, ThemeData theme, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          ...children,
        ],
      ),
    );
  }
}