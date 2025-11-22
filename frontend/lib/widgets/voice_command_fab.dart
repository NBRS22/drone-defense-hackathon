import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class VoiceCommandFab extends StatefulWidget {
  const VoiceCommandFab({super.key});

  @override
  State<VoiceCommandFab> createState() => _VoiceCommandFabState();
}

class _VoiceCommandFabState extends State<VoiceCommandFab> 
    with TickerProviderStateMixin {
  bool _isListening = false;
  bool _isProcessing = false;
  String _lastCommand = '';

  late AnimationController _pulseController;
  late AnimationController _scaleController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.15,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOutSine,
    ));

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeOutQuart,
    ));
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  void _toggleListening() async {
    HapticFeedback.mediumImpact();
    
    if (_isListening) {
      _stopListening();
    } else {
      _startListening();
    }
  }

  void _startListening() async {
    if (!mounted) return;
    
    setState(() {
      _isListening = true;
      _isProcessing = false;
    });

    _pulseController.repeat(reverse: true);

    // Simuler l'écoute vocale - délai réduit pour moins de lag
    await Future.delayed(const Duration(seconds: 2));
    
    if (mounted && _isListening) {
      setState(() {
        _isListening = false;
        _isProcessing = true;
      });

      // Simuler le traitement - délai réduit
      await Future.delayed(const Duration(milliseconds: 800));

      if (mounted) {
        setState(() {
          _isProcessing = false;
          _lastCommand = 'Mission créée: Surveillance zone industrielle';
        });

        _showCommandResult();
      }
    }
  }

  void _stopListening() {
    setState(() {
      _isListening = false;
      _isProcessing = false;
    });
    _pulseController.stop();
  }

  void _showCommandResult() {
    if (_lastCommand.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.check_circle_rounded,
                    color: Colors.green,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _lastCommand,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          backgroundColor: Theme.of(context).cardColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  void _showVoiceModal() {
    HapticFeedback.lightImpact();
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _VoiceCommandModal(
        isListening: _isListening,
        isProcessing: _isProcessing,
        onToggleListening: _toggleListening,
        onClose: () => Navigator.pop(context),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Optimisation: cache des couleurs pour éviter les recalculs
    final gradientColors = _getGradientColors(theme);
    
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _isListening ? _pulseAnimation.value : 1.0,
            child: AnimatedBuilder(
              animation: _scaleAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: gradientColors,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: gradientColors[0].withOpacity(0.4),
                          blurRadius: _isListening ? 24 : 16,
                          offset: const Offset(0, 8),
                          spreadRadius: _isListening ? 4 : 2,
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      shape: const CircleBorder(),
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: _showVoiceModal,
                        onLongPress: _toggleListening,
                        child: Center(
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 200),
                            child: _buildIcon(),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildIcon() {
    if (_isProcessing) {
      return const SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          strokeWidth: 2,
        ),
      );
    } else if (_isListening) {
      return const Icon(
        Icons.mic_rounded,
        color: Colors.white,
        size: 28,
      );
    } else {
      return const Icon(
        Icons.mic_none_rounded,
        color: Colors.white,
        size: 28,
      );
    }
  }

  List<Color> _getGradientColors(ThemeData theme) {
    if (_isListening) {
      return [Colors.red.shade400, Colors.red.shade600];
    } else if (_isProcessing) {
      return [Colors.orange.shade400, Colors.orange.shade600];
    } else {
      return [theme.colorScheme.primary, theme.colorScheme.secondary];
    }
  }
}

class _VoiceCommandModal extends StatelessWidget {
  final bool isListening;
  final bool isProcessing;
  final VoidCallback onToggleListening;
  final VoidCallback onClose;

  const _VoiceCommandModal({
    required this.isListening,
    required this.isProcessing,
    required this.onToggleListening,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return Container(
      height: size.height * 0.6,
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.outline.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Commande Vocale',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: onClose,
                  icon: Icon(
                    Icons.close_rounded,
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
          
          // Status Section
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    _getStatusColor().withOpacity(0.1),
                    _getStatusColor().withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _getStatusColor().withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  // Status Icon
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: _getStatusColor().withOpacity(0.1),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Icon(
                      _getStatusIcon(),
                      size: 30,
                      color: _getStatusColor(),
                    ),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Status Text
                  Text(
                    _getStatusText(),
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: _getStatusColor(),
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Status Subtext
                  Text(
                    _getStatusSubtext(),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          
          // Action Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: isProcessing ? null : onToggleListening,
                icon: Icon(
                  isListening ? Icons.stop_rounded : Icons.mic_rounded,
                  size: 24,
                ),
                label: Text(
                  isListening ? 'Arrêter l\'écoute' : 'Commencer l\'écoute',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isListening 
                      ? Colors.red.shade500 
                      : theme.colorScheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Examples
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Exemples de commandes:',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface.withOpacity(0.8),
                  ),
                ),
                
                const SizedBox(height: 12),
                
                Text(
                  '• "Créer une mission de surveillance"\n'
                  '• "Afficher le statut des drones"\n'
                  '• "Lancer mission urgente zone A"',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.5),
                  ),
                  textAlign: TextAlign.left,
                ),
                
                const SizedBox(height: 24),
              ],
            ),
          ),
          ],
        ),
      ),
    );
  }

  IconData _getStatusIcon() {
    if (isProcessing) return Icons.psychology_rounded;
    if (isListening) return Icons.mic_rounded;
    return Icons.mic_none_rounded;
  }

  Color _getStatusColor() {
    if (isProcessing) return Colors.orange.shade500;
    if (isListening) return Colors.red.shade500;
    return Colors.grey.shade500;
  }

  String _getStatusText() {
    if (isProcessing) return 'Traitement en cours...';
    if (isListening) return 'En écoute';
    return 'Prêt à écouter';
    }

  String _getStatusSubtext() {
    if (isProcessing) return 'Analyse de votre commande vocale';
    if (isListening) return 'Parlez maintenant';
    return 'Appuyez pour commencer une commande vocale';
  }
}