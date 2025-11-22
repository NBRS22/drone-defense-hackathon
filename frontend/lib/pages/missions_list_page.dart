import 'package:flutter/material.dart';
import '../models/mission.dart';
import '../services/api_service.dart';

class MissionsListPage extends StatefulWidget {
  const MissionsListPage({super.key});

  @override
  State<MissionsListPage> createState() => _MissionsListPageState();
}

class _MissionsListPageState extends State<MissionsListPage> with TickerProviderStateMixin {
  final ApiService _apiService = ApiService();
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  
  List<Mission> _missions = [];
  List<Mission> _filteredMissions = [];
  bool _isLoading = true;
  String _searchQuery = '';
  MissionCategory? _selectedCategory;
  Priority? _selectedPriority;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _loadMissions();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadMissions() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final missions = await _apiService.getMissions();
      if (!mounted) return;
      setState(() {
        _missions = missions;
        _filteredMissions = missions;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      if (mounted) {
        _showError('Erreur de chargement: ${e.toString()}');
      }
    }
  }

  void _filterMissions() {
    if (!mounted) return;
    setState(() {
      _filteredMissions = _missions.where((mission) {
        // Recherche textuelle
        bool matchesSearch = _searchQuery.isEmpty ||
            mission.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            (mission.description?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);

        // Filtre par catégorie
        bool matchesCategory = _selectedCategory == null || mission.category == _selectedCategory;

        // Filtre par priorité
        bool matchesPriority = _selectedPriority == null || mission.priority == _selectedPriority;

        // Filtre par onglet de statut
        bool matchesTab = _getStatusForTab(_tabController.index).contains(mission.status);

        return matchesSearch && matchesCategory && matchesPriority && matchesTab;
      }).toList();
    });
  }

  List<MissionStatus> _getStatusForTab(int tabIndex) {
    switch (tabIndex) {
      case 0: // Toutes
        return MissionStatus.values;
      case 1: // Pending
        return [MissionStatus.pending];
      case 2: // In Progress
        return [MissionStatus.inProgress];
      case 3: // Completed
        return [MissionStatus.completed];
      case 4: // Cancelled/Failed
        return [MissionStatus.cancelled, MissionStatus.failed];
      default:
        return MissionStatus.values;
    }
  }

  void _searchMissions(String query) {
    if (!mounted) return;
    setState(() => _searchQuery = query);
    _filterMissions();
  }

  Future<void> _updateMissionStatus(Mission mission, MissionStatus newStatus) async {
    try {
      final updatedMission = Mission(
        missionId: mission.missionId,
        title: mission.title,
        category: mission.category,
        priority: mission.priority,
        status: newStatus,
        risk: mission.risk,
        location: mission.location,
        description: mission.description,
        weight: mission.weight,
        startDate: mission.startDate,
        departure: mission.departure,
        arrival: mission.arrival,
        createdAt: mission.createdAt,
      );

      await _apiService.updateMission(mission.missionId!, updatedMission);
      await _loadMissions();
      _showSuccess('Statut de la mission mis à jour');
    } catch (e) {
      _showError('Erreur lors de la mise à jour: ${e.toString()}');
    }
  }

  Future<void> _deleteMission(Mission mission) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange),
            SizedBox(width: 12),
            Text('Confirmer la suppression'),
          ],
        ),
        content: Text('Êtes-vous sûr de vouloir supprimer la mission "${mission.title}" ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Supprimer', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _apiService.deleteMission(mission.missionId!);
        await _loadMissions();
        _showSuccess('Mission supprimée avec succès');
      } catch (e) {
        _showError('Erreur lors de la suppression: ${e.toString()}');
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      body: Column(
        children: [
          _buildHeader(theme),
          _buildSearchAndFilters(theme),
          _buildTabBar(theme),
          Expanded(child: _buildMissionsList(theme)),
        ],
      ),
      floatingActionButton: _buildAddButton(theme),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.secondary,
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Missions',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Gérez toutes vos missions de drone',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  onPressed: _loadMissions,
                  icon: const Icon(Icons.refresh_rounded, color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildStatsCards(theme),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildStatsCards(ThemeData theme) {
    final totalMissions = _missions.length;
    final pendingMissions = _missions.where((m) => m.status == MissionStatus.pending).length;
    final inProgressMissions = _missions.where((m) => m.status == MissionStatus.inProgress).length;
    final completedMissions = _missions.where((m) => m.status == MissionStatus.completed).length;

    return Row(
      children: [
        _buildStatCard('Total', totalMissions, Icons.assignment_rounded, Colors.white),
        const SizedBox(width: 12),
        _buildStatCard('En attente', pendingMissions, Icons.pending_actions_rounded, Colors.orange.shade100),
        const SizedBox(width: 12),
        _buildStatCard('En cours', inProgressMissions, Icons.flight_rounded, Colors.blue.shade100),
        const SizedBox(width: 12),
        _buildStatCard('Terminées', completedMissions, Icons.check_circle_rounded, Colors.green.shade100),
      ],
    );
  }

  Widget _buildStatCard(String label, int count, IconData icon, Color bgColor) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: bgColor == Colors.white ? Colors.purple : Colors.purple.shade700, size: 24),
            const SizedBox(height: 8),
            Text(
              count.toString(),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: bgColor == Colors.white ? Colors.purple : Colors.purple.shade700,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: bgColor == Colors.white ? Colors.purple : Colors.purple.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchAndFilters(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      color: theme.cardColor,
      child: Column(
        children: [
          // Barre de recherche
          TextField(
            controller: _searchController,
            onChanged: _searchMissions,
            decoration: InputDecoration(
              hintText: 'Rechercher par titre ou description...',
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      onPressed: () {
                        _searchController.clear();
                        _searchMissions('');
                      },
                      icon: const Icon(Icons.clear_rounded),
                    )
                  : null,
              filled: true,
              fillColor: theme.colorScheme.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Filtres
          Row(
            children: [
              Expanded(
                child: _buildFilterChip(
                  'Catégorie',
                  _selectedCategory?.label ?? 'Toutes',
                  Icons.category_rounded,
                  () => _showCategoryFilter(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildFilterChip(
                  'Priorité',
                  _selectedPriority?.label ?? 'Toutes',
                  Icons.priority_high_rounded,
                  () => _showPriorityFilter(),
                ),
              ),
              const SizedBox(width: 12),
              IconButton(
                onPressed: _clearFilters,
                icon: const Icon(Icons.filter_alt_off_rounded),
                tooltip: 'Effacer les filtres',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Theme.of(context).colorScheme.outline.withOpacity(0.2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  Text(
                    value,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const Icon(Icons.expand_more_rounded, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar(ThemeData theme) {
    return Container(
      color: theme.cardColor,
      child: TabBar(
        controller: _tabController,
        onTap: (_) => _filterMissions(),
        isScrollable: true,
        indicatorColor: theme.colorScheme.primary,
        labelColor: theme.colorScheme.primary,
        unselectedLabelColor: theme.colorScheme.onSurface.withOpacity(0.6),
        tabs: const [
          Tab(text: 'Toutes'),
          Tab(text: 'En attente'),
          Tab(text: 'En cours'),
          Tab(text: 'Terminées'),
          Tab(text: 'Annulées'),
        ],
      ),
    );
  }

  Widget _buildMissionsList(ThemeData theme) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_filteredMissions.isEmpty) {
      return _buildEmptyState(theme);
    }

    return RefreshIndicator(
      onRefresh: _loadMissions,
      child: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: _filteredMissions.length,
        itemBuilder: (context, index) {
          final mission = _filteredMissions[index];
          return _buildMissionCard(mission, theme);
        },
      ),
    );
  }

  Widget _buildMissionCard(Mission mission, ThemeData theme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            offset: const Offset(0, 2),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        children: [
          // En-tête de la carte
          Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Icône de catégorie
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: mission.category.color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        mission.category.icon,
                        size: 20,
                        color: mission.category.color,
                      ),
                    ),
                    const SizedBox(width: 16),
                    
                    // Informations principales
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            mission.title,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            mission.category.label,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: mission.category.color,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Menu d'actions
                    PopupMenuButton<String>(
                      onSelected: (value) {
                        switch (value) {
                          case 'edit':
                            // TODO: Implémenter l'édition
                            break;
                          case 'delete':
                            _deleteMission(mission);
                            break;
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit_rounded),
                              SizedBox(width: 12),
                              Text('Modifier'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete_rounded, color: Colors.red),
                              SizedBox(width: 12),
                              Text('Supprimer', style: TextStyle(color: Colors.red)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Badges de priorité, risque et statut
                Row(
                  children: [
                    _buildBadge(
                      mission.priority.label,
                      mission.priority.color,
                      Icons.priority_high_rounded,
                    ),
                    const SizedBox(width: 8),
                    _buildBadge(
                      mission.risk.label,
                      mission.risk.color,
                      Icons.warning_rounded,
                    ),
                    const Spacer(),
                    _buildStatusBadge(mission.status),
                  ],
                ),
                
                if (mission.description?.isNotEmpty == true) ...[
                  const SizedBox(height: 16),
                  Text(
                    mission.description!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                
                const SizedBox(height: 16),
                
                // Informations de localisation
                Row(
                  children: [
                    const Icon(Icons.flight_takeoff_rounded, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        mission.departure,
                        style: theme.textTheme.bodySmall,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Icon(Icons.flight_land_rounded, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        mission.arrival,
                        style: theme.textTheme.bodySmall,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                
                if (mission.weight != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.scale_rounded, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        '${mission.weight!.toStringAsFixed(1)} kg',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          
          // Actions rapides
          if (mission.status == MissionStatus.pending || mission.status == MissionStatus.inProgress)
            Container(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Row(
                children: [
                  if (mission.status == MissionStatus.pending) ...[
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _updateMissionStatus(mission, MissionStatus.inProgress),
                        icon: const Icon(Icons.play_arrow_rounded),
                        label: const Text('Démarrer'),
                      ),
                    ),

                  ] else if (mission.status == MissionStatus.inProgress) ...[
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _updateMissionStatus(mission, MissionStatus.completed),
                        icon: const Icon(Icons.check_rounded),
                        label: const Text('Terminer'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    OutlinedButton.icon(
                      onPressed: () => _updateMissionStatus(mission, MissionStatus.failed),
                      icon: const Icon(Icons.error_rounded),
                      label: const Text('Échec'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                      ),
                    ),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBadge(String text, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(MissionStatus status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: status.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: status.color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(status.icon, size: 12, color: status.color),
          const SizedBox(width: 4),
          Text(
            status.label,
            style: TextStyle(
              color: status.color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 200),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.assignment_outlined,
                  size: 64,
                  color: theme.colorScheme.onSurface.withOpacity(0.5),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Aucune mission trouvée',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Créez votre première mission ou modifiez vos filtres',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => Navigator.pushNamed(context, '/add_mission'),
            icon: const Icon(Icons.add_rounded),
            label: const Text('Créer une mission'),
          ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddButton(ThemeData theme) {
    return FloatingActionButton.extended(
      onPressed: () => Navigator.pushNamed(context, '/add_mission'),
      icon: const Icon(Icons.add_rounded),
      label: const Text('Nouvelle mission'),
      backgroundColor: theme.colorScheme.primary,
    );
  }

  void _showCategoryFilter() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.primary,
                    Theme.of(context).colorScheme.secondary,
                  ],
                ),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.category_rounded, color: Colors.white),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Filtrer par catégorie',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded, color: Colors.white),
                  ),
                ],
              ),
            ),
            
            ListTile(
              leading: const Icon(Icons.all_inclusive_rounded),
              title: const Text('Toutes les catégories'),
              onTap: () {
                if (!mounted) return;
                setState(() => _selectedCategory = null);
                _filterMissions();
                Navigator.pop(context);
              },
              trailing: _selectedCategory == null ? const Icon(Icons.check_rounded) : null,
            ),
            
            ...MissionCategory.values.map((category) => ListTile(
              leading: Icon(category.icon, size: 20, color: category.color),
              title: Text(category.label),
              onTap: () {
                if (!mounted) return;
                setState(() => _selectedCategory = category);
                _filterMissions();
                Navigator.pop(context);
              },
              trailing: _selectedCategory == category ? const Icon(Icons.check_rounded) : null,
            )),
          ],
        ),
      ),
    );
  }

  void _showPriorityFilter() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.primary,
                    Theme.of(context).colorScheme.secondary,
                  ],
                ),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.priority_high_rounded, color: Colors.white),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Filtrer par priorité',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded, color: Colors.white),
                  ),
                ],
              ),
            ),
            
            ListTile(
              leading: const Icon(Icons.all_inclusive_rounded),
              title: const Text('Toutes les priorités'),
              onTap: () {
                if (!mounted) return;
                setState(() => _selectedPriority = null);
                _filterMissions();
                Navigator.pop(context);
              },
              trailing: _selectedPriority == null ? const Icon(Icons.check_rounded) : null,
            ),
            
            ...Priority.values.map((priority) => ListTile(
              leading: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: priority.color,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              title: Text(priority.label),
              onTap: () {
                if (!mounted) return;
                setState(() => _selectedPriority = priority);
                _filterMissions();
                Navigator.pop(context);
              },
              trailing: _selectedPriority == priority ? const Icon(Icons.check_rounded) : null,
            )),
          ],
        ),
      ),
    );
  }

  void _clearFilters() {
    if (!mounted) return;
    setState(() {
      _selectedCategory = null;
      _selectedPriority = null;
      _searchQuery = '';
    });
    _searchController.clear();
    _filterMissions();
  }
}