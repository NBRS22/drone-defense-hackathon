import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../main.dart';
import 'dashboard_page.dart';
import 'add_mission_page.dart';
import 'missions_list_page.dart';
import 'settings_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 1; // Index 1 = Ajouter Mission
  late PageController _pageController;

  final List<NavigationItem> _navigationItems = [
    NavigationItem(
      icon: Icons.dashboard_outlined,
      activeIcon: Icons.dashboard_rounded,
      label: 'Dashboard',
      color: const Color(0xFF2563EB),
    ),
    NavigationItem(
      icon: Icons.add_circle_outline_rounded,
      activeIcon: Icons.add_circle_rounded,
      label: 'Nouvelle Mission',
      color: const Color(0xFF00D4AA),
    ),
    NavigationItem(
      icon: Icons.assignment_outlined,
      activeIcon: Icons.assignment_rounded,
      label: 'Missions',
      color: const Color(0xFF64748B),
    ),
    NavigationItem(
      icon: Icons.settings_outlined,
      activeIcon: Icons.settings_rounded,
      label: 'Paramètres',
      color: const Color(0xFF6B7280),
    ),
  ];

  final List<Widget> _pages = const [
    RepaintBoundary(child: DashboardPage()),
    RepaintBoundary(child: AddMissionPage()),
    RepaintBoundary(child: MissionsListPage()),
    RepaintBoundary(child: SettingsPage()),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 1); // Démarrer sur la page "Ajouter Mission"
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    if (index == _selectedIndex) {
      // Double tap pour retourner en haut de la page
      HapticFeedback.mediumImpact();
      return;
    }
    
    // Optimisation: Update state une seule fois
    HapticFeedback.selectionClick();
    
    setState(() {
      _selectedIndex = index;
    });
    
    // Animation optimisée sans rebuild
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeProvider = ThemeProvider.of(context);
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Column(
        children: [
          _buildModernAppBar(theme, themeProvider),
          Expanded(
            child: RepaintBoundary(
              child: PageView(
                controller: _pageController,
                physics: const ClampingScrollPhysics(),
                clipBehavior: Clip.hardEdge,
                allowImplicitScrolling: false,
                pageSnapping: true,
                onPageChanged: (index) {
                  if (mounted) {
                    HapticFeedback.lightImpact();
                    setState(() {
                      _selectedIndex = index;
                    });
                  }
                },
                children: _pages,
              ),
            ),
          ),
        ],
      ),
      
      // Navigation bottom moderne avec design épuré
      bottomNavigationBar: _buildModernBottomNav(theme),
    );
  }

  Widget _buildModernAppBar(ThemeData theme, ThemeProvider? themeProvider) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 8, 20, 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 3),
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Logo et titre avec animation améliorés
          Expanded(
            child: Row(
              children: [
                // Logo moderne simplifié
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.primary.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.flight_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                // Texte avec typographie améliorée
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'CrisisDrone',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                          color: theme.colorScheme.onSurface,
                          fontSize: 16,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Livraison d\'urgence par drone',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                          fontWeight: FontWeight.w500,
                          fontSize: 11,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Actions modernes optimisées
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Switch thème moderne avec animation améliorée
              Container(
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: theme.colorScheme.outline.withOpacity(0.12),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 3),
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () {
                      HapticFeedback.lightImpact();
                      themeProvider?.toggleTheme();
                    },
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 400),
                        transitionBuilder: (child, animation) {
                          return RotationTransition(
                            turns: animation,
                            child: FadeTransition(
                              opacity: animation,
                              child: child,
                            ),
                          );
                        },
                        child: Icon(
                          themeProvider?.isDarkMode == true
                              ? Icons.wb_sunny_rounded
                              : Icons.dark_mode_rounded,
                          key: ValueKey(themeProvider?.isDarkMode),
                          color: themeProvider?.isDarkMode == true
                              ? Colors.amber.shade500
                              : theme.colorScheme.primary,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              
              const SizedBox(width: 10),
              
              // Bouton vocal harmonisé
              Container(
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: theme.colorScheme.outline.withOpacity(0.12),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 3),
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () {
                      HapticFeedback.mediumImpact();
                      _showVoiceRecordingModal(context, theme);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      child: Icon(
                        Icons.mic_rounded,
                        color: theme.colorScheme.primary,
                        size: 18,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildModernBottomNav(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      height: 64, // Hauteur fixe pour éviter les variations entre modes
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 30,
            offset: const Offset(0, 12),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(0.1),
            blurRadius: 60,
            offset: const Offset(0, 20),
            spreadRadius: 0,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: _navigationItems.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            final isSelected = index == _selectedIndex;
            
            return Expanded(
              child: GestureDetector(
                onTap: () => _onItemTapped(index),
                child: Container(
                  height: 64,
                  decoration: BoxDecoration(
                    gradient: isSelected 
                        ? LinearGradient(
                            colors: [
                              item.color.withOpacity(0.15),
                              item.color.withOpacity(0.05),
                            ],
                          )
                        : null,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        isSelected ? item.activeIcon : item.icon,
                        color: isSelected 
                            ? item.color
                            : theme.colorScheme.onSurface.withOpacity(0.4),
                        size: isSelected ? 22 : 20,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.label,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: isSelected ? 10 : 9,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected 
                              ? item.color
                              : theme.colorScheme.onSurface.withOpacity(0.4),
                          letterSpacing: -0.2,
                          height: 1.0,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  // Modal d'enregistrement vocal avec micro géant
  void _showVoiceRecordingModal(BuildContext context, ThemeData theme) {
    bool isRecording = false;
    
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.8),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              backgroundColor: Colors.transparent,
              child: Container(
                width: MediaQuery.of(context).size.width * 0.8,
                height: MediaQuery.of(context).size.height * 0.6,
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 30,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Titre
                    Text(
                      isRecording ? 'Enregistrement en cours...' : 'Commande Vocale',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 40),
                    
                    // Micro géant avec animation
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.mediumImpact();
                        setState(() {
                          isRecording = !isRecording;
                        });
                        
                        if (isRecording) {
                          // Démarrer l'enregistrement
                          _startRecording();
                        } else {
                          // Arrêter l'enregistrement
                          _stopRecording();
                        }
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: isRecording 
                                ? [Colors.red.shade400, Colors.red.shade600]
                                : [theme.colorScheme.primary, theme.colorScheme.primary.withOpacity(0.7)],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: isRecording 
                                  ? Colors.red.withOpacity(0.4)
                                  : theme.colorScheme.primary.withOpacity(0.4),
                              blurRadius: isRecording ? 30 : 20,
                              spreadRadius: isRecording ? 10 : 5,
                            ),
                          ],
                        ),
                        child: AnimatedScale(
                          scale: isRecording ? 1.1 : 1.0,
                          duration: const Duration(milliseconds: 300),
                          child: Icon(
                            Icons.mic,
                            size: 100,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 40),
                    
                    // Instructions
                    Text(
                      isRecording 
                          ? 'Appuyez à nouveau pour arrêter'
                          : 'Appuyez sur le micro pour commencer',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    
                    const SizedBox(height: 30),
                    
                    // Bouton Fermer
                    TextButton(
                      onPressed: () {
                        if (isRecording) {
                          _stopRecording();
                        }
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        'Fermer',
                        style: TextStyle(
                          color: theme.colorScheme.primary,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // Méthodes d'enregistrement (à implémenter avec un package audio)
  void _startRecording() {
    // TODO: Implémenter l'enregistrement audio
    print('🎤 Démarrage de l\'enregistrement...');
  }

  void _stopRecording() {
    // TODO: Arrêter l'enregistrement et traiter l'audio
    print('🛑 Arrêt de l\'enregistrement...');
  }
}

class NavigationItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final Color color;

  NavigationItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.color,
  });
}
