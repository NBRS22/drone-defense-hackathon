import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/mission.dart';
import '../services/api_service.dart';

class AddMissionPage extends StatefulWidget {
  const AddMissionPage({super.key});

  @override
  State<AddMissionPage> createState() => _AddMissionPageState();
}

class _AddMissionPageState extends State<AddMissionPage> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final ApiService _apiService = ApiService();
  
  // Controllers
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _departureController = TextEditingController();
  final TextEditingController _arrivalController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();
  
  // Form state
  MissionCategory _selectedCategory = MissionCategory.pochesSang;
  Priority _selectedPriority = Priority.medium;
  Risk _selectedRisk = Risk.low;
  DateTime? _startDate = DateTime.now(); // Planification immédiate par défaut
  bool _isLoading = false;
  
  // Planification
  bool _isImmediateDeparture = true; // Départ immédiat par défaut
  DateTime? _scheduledDate;
  TimeOfDay? _scheduledTime;
  
  // Navigation par étapes
  int _currentStep = 0;
  final PageController _pageController = PageController();
  
  final List<String> _stepTitles = [
    'Type de Mission',
    'Priorité & Planification', 
    'Localisation'
  ];
  
  // Lieux prédéfinis
  String? _selectedDeparture;
  String? _selectedArrival;
  
  // Position actuelle pour GPS
  String? _currentPosition;
  
  // Lieux prédéfinis (avec coordonnées actuelles si disponibles)
  List<String> get _lieux {
    List<String> baseLieux = [
      'Hôpital Central',
      'Clinique Nord',
      'Centre Médical Sud',
      'Pharmacie de la Paix',
      'Urgences CHU',
      'Centre de Soins',
      'Hôpital Régional',
      'Clinique Saint-Joseph',
      'Centre de Traumatologie',
      'Banque du Sang',
      'Laboratoire Médical',
      'Centre de Cardiologie',
    ];
    
    if (_currentPosition != null) {
      return [_currentPosition!, ...baseLieux];
    }
    return baseLieux;
  }
  
  // Animations
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _animationController.forward();
  }

  // Simuler l'obtention de la position GPS actuelle
  Future<void> _getCurrentLocation() async {
    try {
      // Simulation d'une requête GPS
      await Future.delayed(const Duration(seconds: 1));
      
      // Coordonnées fictives pour la démonstration
      // En réalité, on utiliserait geolocator package
      double lat = 48.8566 + (DateTime.now().millisecondsSinceEpoch % 1000) / 100000;
      double lng = 2.3522 + (DateTime.now().millisecondsSinceEpoch % 1000) / 100000;
      
      setState(() {
        _currentPosition = 'Coordonnées actuelles: ${lat.toStringAsFixed(6)}, ${lng.toStringAsFixed(6)}';
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erreur lors de la récupération de la position'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _weightController.dispose();
    _departureController.dispose();
    _arrivalController.dispose();
    _locationController.dispose();
    _durationController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < _stepTitles.length - 1) {
      setState(() {
        _currentStep++;
      });
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      HapticFeedback.lightImpact();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      HapticFeedback.lightImpact();
    }
  }

  bool _canProceedToNext() {
    switch (_currentStep) {
      case 0: // Type de mission
        return _selectedCategory != null;
      case 1: // Priorité & Planification (fusionnés)
        // Vérifier priorité, risque et planification
        bool hasBasicInfo = _selectedPriority != null && _selectedRisk != null;
        if (!_isImmediateDeparture) {
          return hasBasicInfo && _scheduledDate != null && _scheduledTime != null;
        }
        return hasBasicInfo;
      case 2: // Localisation
        if (_selectedCategory == MissionCategory.autres) {
          return _selectedDeparture != null && _selectedArrival != null;
        }
        return _selectedArrival != null;
      default:
        return false;
    }
  }

  Future<void> _submitMission() async {
    setState(() => _isLoading = true);
    HapticFeedback.mediumImpact();

    try {
      // Calculer la date de début selon la planification
      DateTime startDate;
      if (_isImmediateDeparture) {
        startDate = DateTime.now();
      } else {
        startDate = DateTime(
          _scheduledDate!.year,
          _scheduledDate!.month,
          _scheduledDate!.day,
          _scheduledTime!.hour,
          _scheduledTime!.minute,
        );
      }
      
      // Générer automatiquement le titre basé sur la catégorie
      String autoTitle = 'Mission ${_selectedCategory.label} - ${DateTime.now().day}/${DateTime.now().month}';
      
      final mission = Mission(
        title: autoTitle,
        category: _selectedCategory,
        priority: _selectedPriority,
        status: MissionStatus.pending,
        risk: _selectedRisk,
        location: _selectedArrival ?? 'Non défini',
        description: 'Mission automatique de ${_selectedCategory.label.toLowerCase()}',
        estimatedDuration: null,
        weight: null,
        startDate: startDate,
        departure: _selectedDeparture ?? 'Non défini',
        arrival: _selectedArrival ?? 'Non défini',
        createdAt: DateTime.now(),
      );

      await _apiService.createMission(mission);
      
      if (mounted) {
        // Afficher un message de succès
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
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
                const Text(
                  'Mission créée avec succès !',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
            backgroundColor: Theme.of(context).cardColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
        
        // Réinitialiser le formulaire et revenir à la première étape
        setState(() {
          _currentStep = 0;
          _selectedCategory = MissionCategory.pochesSang;
          _selectedPriority = Priority.medium;
          _selectedRisk = Risk.low;
          _selectedDeparture = null;
          _selectedArrival = null;
          _isImmediateDeparture = true;
          _scheduledDate = null;
          _scheduledTime = null;
        });
        _pageController.animateToPage(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la création: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        toolbarHeight: 0, // Masquer complètement l'AppBar
        automaticallyImplyLeading: false, // Pas de flèche de retour
      ),
      body: Column(
        children: [
          // Indicateur de progression
          Container(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 16), // Ajout de padding top
            child: Row(
              children: List.generate(_stepTitles.length, (index) {
                final isCompleted = index < _currentStep;
                final isCurrent = index == _currentStep;
                
                return Expanded(
                  child: Container(
                    height: 4,
                    margin: EdgeInsets.only(right: index < _stepTitles.length - 1 ? 8 : 0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(2),
                      color: isCompleted || isCurrent
                          ? theme.colorScheme.primary
                          : theme.colorScheme.outline.withOpacity(0.2),
                    ),
                  ),
                );
              }),
            ),
          ),
          
          // Contenu des étapes
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(), // Empêche le swipe manuel
              children: [
                _buildCategoryStep(theme),
                _buildPriorityPlanificationStep(theme),
                _buildLocationStep(theme),
              ],
            ),
          ),
          
          // Boutons de navigation
          Container(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                if (_currentStep > 0)
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _previousStep,
                      icon: const Icon(Icons.arrow_back_ios_rounded),
                      label: const Text('Précédent'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                if (_currentStep > 0) const SizedBox(width: 16),
                
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _canProceedToNext() 
                        ? (_currentStep == _stepTitles.length - 1 ? _submitMission : _nextStep)
                        : null,
                    icon: Icon(_currentStep == _stepTitles.length - 1 
                        ? Icons.check_rounded 
                        : Icons.arrow_forward_ios_rounded),
                    label: Text(_currentStep == _stepTitles.length - 1 
                        ? 'Créer Mission' 
                        : 'Suivant'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Étape 1: Sélection du type de mission
  Widget _buildCategoryStep(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCategorySection(theme),
        ],
      ),
    );
  }

  // Étape 2: Priorité, Risque et Planification
  Widget _buildPriorityPlanificationStep(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPriorityAndRiskSection(theme),
          const SizedBox(height: 32),
          _buildPlanificationSection(theme),
        ],
      ),
    );
  }

  // Étape 3: Localisation
  Widget _buildLocationStep(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLocationSection(theme),
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
            theme.colorScheme.primary.withOpacity(0.1),
            theme.colorScheme.secondary.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(0.1),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primary,
                  theme.colorScheme.secondary,
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.primary.withOpacity(0.3),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.add_task_rounded,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Nouvelle Mission',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: -1.0,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Créez et planifiez une mission drone',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySection(ThemeData theme) {
    return _buildSection(
      theme: theme,
      title: 'Catégorie de Mission',
      icon: Icons.medical_services_rounded,
      children: [
        Text(
          'Sélectionnez le type de mission à effectuer',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            // Calculer dynamiquement le nombre de colonnes et la taille optimale
            double availableWidth = constraints.maxWidth - 24; // Marge totale
            double minItemWidth = 120; // Largeur minimale pour chaque élément
            double maxItemWidth = 180; // Largeur maximale pour chaque élément
            
            int crossAxisCount = (availableWidth / minItemWidth).floor();
            crossAxisCount = crossAxisCount.clamp(2, 6); // Entre 2 et 6 colonnes
            
            // Calculer la largeur réelle de chaque élément
            double spacing = 12;
            double totalSpacing = (crossAxisCount - 1) * spacing;
            double itemWidth = (availableWidth - totalSpacing) / crossAxisCount;
            
            // Limiter la largeur si elle dépasse le maximum
            if (itemWidth > maxItemWidth) {
              itemWidth = maxItemWidth;
              double totalItemsWidth = crossAxisCount * itemWidth + totalSpacing;
              availableWidth = totalItemsWidth;
            }
            
            // Calculer l'aspect ratio dynamique pour éviter le débordement
            double aspectRatio = itemWidth / (itemWidth * 0.95); // Hauteur légèrement plus grande
            
            return Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: availableWidth,
                ),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    childAspectRatio: aspectRatio,
                    crossAxisSpacing: spacing,
                    mainAxisSpacing: spacing,
                  ),
                  itemCount: MissionCategory.values.length,
          itemBuilder: (context, index) {
            final category = MissionCategory.values[index];
            final isSelected = _selectedCategory == category;
            
            return GestureDetector(
              onTap: () {
                setState(() => _selectedCategory = category);
                HapticFeedback.lightImpact();
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.outline.withOpacity(0.12),
                    width: isSelected ? 3 : 1,
                  ),
                  boxShadow: [
                    if (isSelected) ...[
                      BoxShadow(
                        color: theme.colorScheme.primary.withOpacity(0.15),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                        spreadRadius: 0,
                      ),
                    ] else ...[
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ],
                ),
                child: Padding(
                  padding: EdgeInsets.all(itemWidth > 150 ? 12 : 8),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Icône
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        padding: EdgeInsets.all(itemWidth > 150 ? 10 : 8),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(itemWidth > 150 ? 16 : 14),
                        ),
                        child: AnimatedScale(
                          scale: isSelected ? 1.05 : 1.0,
                          duration: const Duration(milliseconds: 200),
                          child: Icon(
                            category.icon,
                            size: itemWidth > 150 ? 24 : 20,
                            color: category.color,
                          ),
                        ),
                      ),
                      
                      SizedBox(height: itemWidth > 150 ? 8 : 6),
                      
                      // Nom de la catégorie
                      Flexible(
                        child: AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 200),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.8),
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                            fontSize: itemWidth > 150 
                                ? (isSelected ? 13 : 12)
                                : (isSelected ? 12 : 11),
                            letterSpacing: 0.2,
                          ) ?? const TextStyle(),
                          child: Text(
                            category.label,
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildPriorityAndRiskSection(ThemeData theme) {
    return _buildSection(
      theme: theme,
      title: 'Priorité et Niveau de Risque',
      icon: Icons.priority_high_rounded,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Priorité',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<Priority>(
                    value: _selectedPriority,
                    decoration: InputDecoration(
                      prefixIcon: Container(
                        margin: const EdgeInsets.all(12),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: _selectedPriority.color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.flag_rounded,
                          color: _selectedPriority.color,
                          size: 16,
                        ),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    items: Priority.values.map((priority) {
                      return DropdownMenuItem(
                        value: priority,
                        child: Text(
                          priority.label,
                          style: TextStyle(
                            color: priority.color,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _selectedPriority = value);
                        HapticFeedback.lightImpact();
                      }
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Niveau de risque',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<Risk>(
                    value: _selectedRisk,
                    decoration: InputDecoration(
                      prefixIcon: Container(
                        margin: const EdgeInsets.all(12),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: _selectedRisk.color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.warning_rounded,
                          color: _selectedRisk.color,
                          size: 16,
                        ),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    items: Risk.values.map((risk) {
                      return DropdownMenuItem(
                        value: risk,
                        child: Text(
                          risk.label,
                          style: TextStyle(
                            color: risk.color,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _selectedRisk = value);
                        HapticFeedback.lightImpact();
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLocationSection(ThemeData theme) {
    return _buildSection(
      theme: theme,
      title: 'Localisation',
      icon: Icons.location_on_rounded,
      children: [
        // Point de départ (seulement si "Autres" est sélectionné)
        if (_selectedCategory == MissionCategory.autres) ...[
          Text(
            'Point de départ',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedDeparture,
                  hint: const Text('Sélectionner un lieu'),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.flight_takeoff_rounded),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  items: _lieux.map((lieu) {
                    return DropdownMenuItem(
                      value: lieu,
                      child: Text(lieu),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() => _selectedDeparture = value);
                  },
                  validator: (value) {
                    if (_selectedCategory == MissionCategory.autres && value == null) {
                      return 'Veuillez sélectionner un point de départ';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 12),
              Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: theme.colorScheme.primary.withOpacity(0.3),
                  ),
                ),
                child: IconButton(
                  onPressed: () async {
                    HapticFeedback.lightImpact();
                    await _getCurrentLocation();
                    if (_currentPosition != null) {
                      setState(() {
                        _selectedDeparture = _currentPosition;
                      });
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Position actuelle utilisée comme point de départ')),
                        );
                      }
                    }
                  },
                  icon: Icon(
                    Icons.gps_fixed_rounded,
                    color: theme.colorScheme.primary,
                  ),
                  tooltip: 'Utiliser ma position',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
        
        // Point d'arrivée
        Text(
          "Point d'arrivée",
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                value: _selectedArrival,
                hint: const Text('Sélectionner un lieu'),
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.flight_land_rounded),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: _lieux.map((lieu) {
                  return DropdownMenuItem(
                    value: lieu,
                    child: Text(lieu),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() => _selectedArrival = value);
                },
                validator: (value) => value == null ? "Veuillez sélectionner un point d'arrivée" : null,
              ),
            ),
            const SizedBox(width: 12),
            Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: theme.colorScheme.primary.withOpacity(0.3),
                ),
              ),
              child: IconButton(
                onPressed: () async {
                  HapticFeedback.lightImpact();
                  await _getCurrentLocation();
                  if (_currentPosition != null) {
                    setState(() {
                      _selectedArrival = _currentPosition;
                    });
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Position actuelle utilisée comme point d'arrivée")),
                      );
                    }
                  }
                },
                icon: Icon(
                  Icons.gps_fixed_rounded,
                  color: theme.colorScheme.primary,
                ),
                tooltip: 'Utiliser ma position',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPlanificationSection(ThemeData theme) {
    return _buildSection(
      theme: theme,
      title: 'Planification',
      icon: Icons.schedule_rounded,
      children: [
        // Option départ immédiat
        GestureDetector(
          onTap: () {
            setState(() {
              _isImmediateDeparture = true;
              _scheduledDate = null;
              _scheduledTime = null;
            });
            HapticFeedback.lightImpact();
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _isImmediateDeparture 
                  ? theme.colorScheme.primary.withOpacity(0.15)
                  : theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _isImmediateDeparture
                    ? theme.colorScheme.primary
                    : theme.colorScheme.outline.withOpacity(0.2),
                width: _isImmediateDeparture ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.flash_on_rounded,
                  color: _isImmediateDeparture 
                      ? theme.colorScheme.primary 
                      : theme.colorScheme.onSurface.withOpacity(0.6),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Départ immédiat',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: _isImmediateDeparture 
                              ? theme.colorScheme.primary 
                              : theme.colorScheme.onSurface,
                        ),
                      ),
                      Text(
                        'Mission programmée pour un départ le plus rapidement possible',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                if (_isImmediateDeparture)
                  Icon(
                    Icons.check_circle,
                    color: theme.colorScheme.primary,
                  ),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 12),
        
        // Option départ programmé
        GestureDetector(
          onTap: () {
            setState(() {
              _isImmediateDeparture = false;
              _scheduledDate = DateTime.now();
              _scheduledTime = TimeOfDay.now();
            });
            HapticFeedback.lightImpact();
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: !_isImmediateDeparture 
                  ? theme.colorScheme.primary.withOpacity(0.15)
                  : theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: !_isImmediateDeparture
                    ? theme.colorScheme.primary
                    : theme.colorScheme.outline.withOpacity(0.2),
                width: !_isImmediateDeparture ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.schedule_rounded,
                  color: !_isImmediateDeparture 
                      ? theme.colorScheme.primary 
                      : theme.colorScheme.onSurface.withOpacity(0.6),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Départ programmé',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: !_isImmediateDeparture 
                              ? theme.colorScheme.primary 
                              : theme.colorScheme.onSurface,
                        ),
                      ),
                      Text(
                        'Choisir une date et heure spécifiques',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                if (!_isImmediateDeparture)
                  Icon(
                    Icons.check_circle,
                    color: theme.colorScheme.primary,
                  ),
              ],
            ),
          ),
        ),
        
        // Sélection date/heure si programmé
        if (!_isImmediateDeparture) ...[
          const SizedBox(height: 16),
          Row(
            children: [
              // Sélection date
              Expanded(
                child: GestureDetector(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _scheduledDate ?? DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 30)),
                    );
                    if (date != null) {
                      setState(() => _scheduledDate = date);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: theme.colorScheme.outline.withOpacity(0.2),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          color: theme.colorScheme.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _scheduledDate != null
                                ? '${_scheduledDate!.day}/${_scheduledDate!.month}/${_scheduledDate!.year}'
                                : 'Choisir date',
                            style: theme.textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              
              const SizedBox(width: 12),
              
              // Sélection heure
              Expanded(
                child: GestureDetector(
                  onTap: () async {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: _scheduledTime ?? TimeOfDay.now(),
                    );
                    if (time != null) {
                      setState(() => _scheduledTime = time);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: theme.colorScheme.outline.withOpacity(0.2),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          color: theme.colorScheme.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _scheduledTime != null
                                ? '${_scheduledTime!.hour.toString().padLeft(2, '0')}:${_scheduledTime!.minute.toString().padLeft(2, '0')}'
                                : 'Choisir heure',
                            style: theme.textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildDetailsSection(ThemeData theme) {
    return _buildSection(
      theme: theme,
      title: 'Planification',
      icon: Icons.schedule_rounded,
      children: [
        GestureDetector(
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: _startDate ?? DateTime.now(),
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 365)),
            );
            
            if (date != null) {
              final time = await showTimePicker(
                context: context,
                initialTime: TimeOfDay.now(),
              );
              
              if (time != null) {
                setState(() {
                  _startDate = DateTime(
                    date.year,
                    date.month,
                    date.day,
                    time.hour,
                    time.minute,
                  );
                });
                HapticFeedback.lightImpact();
              }
            }
          },
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: _startDate != null
                  ? theme.colorScheme.primary.withOpacity(0.1)
                  : theme.cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _startDate != null
                    ? theme.colorScheme.primary
                    : theme.colorScheme.outline.withOpacity(0.2),
                width: _startDate != null ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.event_rounded,
                    color: theme.colorScheme.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Date et heure de début',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _startDate != null
                            ? '${_startDate!.day}/${_startDate!.month}/${_startDate!.year} à ${_startDate!.hour}:${_startDate!.minute.toString().padLeft(2, '0')}'
                            : 'Tapez pour sélectionner',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: _startDate != null
                              ? theme.colorScheme.primary
                              : theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: theme.colorScheme.onSurface.withOpacity(0.4),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSection({
    required ThemeData theme,
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Container(
          margin: const EdgeInsets.all(12),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: Theme.of(context).colorScheme.primary,
            size: 20,
          ),
        ),
      ),
    );
  }

  Widget _buildSubmitButton(ThemeData theme) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: Container(
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
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.primary.withOpacity(0.3),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ElevatedButton.icon(
          onPressed: _isLoading ? null : _submitMission,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          icon: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    strokeWidth: 2,
                  ),
                )
              : const Icon(
                  Icons.add_task_rounded,
                  color: Colors.white,
                ),
          label: Text(
            _isLoading ? 'Création...' : 'Créer la mission',
            style: theme.textTheme.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}