import 'package:flutter/material.dart';
import '../models/mission.dart';
import '../services/api_service.dart';

class MissionsListPage extends StatefulWidget {
  const MissionsListPage({super.key});

  @override
  State<MissionsListPage> createState() => _MissionsListPageState();
}

class _MissionsListPageState extends State<MissionsListPage> {
  final ApiService _apiService = ApiService();
  List<Mission> _missions = [];
  List<Mission> _filteredMissions = [];
  bool _isLoading = true;
  String _searchQuery = '';
  Urgence? _selectedUrgence;

  @override
  void initState() {
    super.initState();
    _loadMissions();
  }

  Future<void> _loadMissions() async {
    setState(() => _isLoading = true);
    try {
      final missions = await _apiService.getMissions();
      setState(() {
        _missions = missions;
        _filteredMissions = missions;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${e.toString()}'),
            backgroundColor: Colors.red.shade600,
          ),
        );
      }
    }
  }

  void _filterMissions() {
    setState(() {
      _filteredMissions = _missions.where((mission) {
        final matchesSearch = _searchQuery.isEmpty ||
            mission.typeMateriel.label.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            (mission.destinataire?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);
        
        final matchesUrgence = _selectedUrgence == null ||
            mission.urgence == _selectedUrgence;

        return matchesSearch && matchesUrgence;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Missions'),
        actions: [
          IconButton(
            onPressed: _loadMissions,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchAndFilters(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildMissionsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return Container(
      padding: const EdgeInsets.all(20),
      color: Colors.white,
      child: Column(
        children: [
          // Barre de recherche
          TextField(
            onChanged: (value) {
              _searchQuery = value;
              _filterMissions();
            },
            decoration: InputDecoration(
              hintText: 'Rechercher une mission...',
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      onPressed: () {
                        setState(() => _searchQuery = '');
                        _filterMissions();
                      },
                      icon: const Icon(Icons.clear_rounded),
                    )
                  : null,
            ),
          ),
          const SizedBox(height: 16),
          // Filtres par urgence
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildUrgenceFilter(null, 'Toutes'),
                const SizedBox(width: 8),
                ...Urgence.values.map((urgence) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _buildUrgenceFilter(urgence, urgence.label),
                )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUrgenceFilter(Urgence? urgence, String label) {
    final isSelected = _selectedUrgence == urgence;
    final color = urgence?.color ?? Theme.of(context).colorScheme.primary;

    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedUrgence = selected ? urgence : null;
        });
        _filterMissions();
      },
      backgroundColor: Colors.grey.shade100,
      selectedColor: color.withOpacity(0.1),
      checkmarkColor: color,
      labelStyle: TextStyle(
        color: isSelected ? color : Colors.grey.shade700,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
      ),
      side: BorderSide(
        color: isSelected ? color : Colors.grey.shade300,
        width: isSelected ? 2 : 1,
      ),
    );
  }

  Widget _buildMissionsList() {
    if (_filteredMissions.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _loadMissions,
      child: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: _filteredMissions.length,
        separatorBuilder: (context, index) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          return _buildMissionCard(_filteredMissions[index]);
        },
      ),
    );
  }

  Widget _buildMissionCard(Mission mission) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            offset: const Offset(0, 4),
            blurRadius: 12,
          ),
        ],
      ),
      child: Column(
        children: [
          // En-tête de la carte
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: mission.urgence.color.withOpacity(0.05),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: mission.urgence.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    _getTypeIcon(mission.typeMateriel),
                    color: mission.urgence.color,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Mission #${mission.id}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF64748B),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: mission.urgence.color.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: mission.urgence.color.withOpacity(0.3)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: mission.urgence.color,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  mission.urgence.label,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: mission.urgence.color,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        mission.typeMateriel.label,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Détails de la mission
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoItem(
                        Icons.scale_rounded,
                        'Poids',
                        '${mission.poidsKg} kg',
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 40,
                      color: Colors.grey.shade200,
                    ),
                    Expanded(
                      child: _buildInfoItem(
                        Icons.person_rounded,
                        'Destinataire',
                        mission.destinataire ?? 'Non spécifié',
                      ),
                    ),
                  ],
                ),
                if (mission.description != null && mission.description!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.description_rounded,
                              size: 16,
                              color: Colors.grey.shade600,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Description',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          mission.description!,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF475569),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                // Coordonnées
                Row(
                  children: [
                    Expanded(
                      child: _buildLocationInfo(
                        'Départ',
                        mission.latitudeDepart,
                        mission.longitudeDepart,
                        Colors.blue,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      child: Icon(
                        Icons.arrow_forward_rounded,
                        color: Colors.grey.shade400,
                      ),
                    ),
                    Expanded(
                      child: _buildLocationInfo(
                        'Arrivée',
                        mission.latitudeArrivee,
                        mission.longitudeArrivee,
                        Colors.green,
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

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, size: 20, color: Colors.grey.shade600),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1E293B),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildLocationInfo(String label, double lat, double lng, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(Icons.location_on_rounded, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '${lat.toStringAsFixed(4)}, ${lng.toStringAsFixed(4)}',
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF64748B),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.search_off_rounded,
              size: 64,
              color: Colors.grey.shade400,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Aucune mission trouvée',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Color(0xFF475569),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Essayez de modifier vos filtres de recherche',
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF64748B),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  IconData _getTypeIcon(TypeMateriel type) {
    switch (type) {
      case TypeMateriel.pocheSang:
        return Icons.bloodtype_rounded;
      case TypeMateriel.defibrillateur:
        return Icons.monitor_heart_rounded;
      case TypeMateriel.medicament:
        return Icons.medication_rounded;
      case TypeMateriel.pieceMecanique:
        return Icons.build_rounded;
      case TypeMateriel.autre:
        return Icons.inventory_2_rounded;
    }
  }
}