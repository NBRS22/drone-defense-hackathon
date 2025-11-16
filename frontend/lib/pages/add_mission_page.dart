import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/mission.dart';
import '../services/api_service.dart';
import '../widgets/gps_point_selector.dart';

class AddMissionPage extends StatefulWidget {
  const AddMissionPage({super.key});

  @override
  State<AddMissionPage> createState() => _AddMissionPageState();
}

class _AddMissionPageState extends State<AddMissionPage> {
  final _formKey = GlobalKey<FormState>();
  final ApiService _apiService = ApiService();
  bool _isLoading = false;

  // Contrôleurs pour les champs du formulaire
  TypeCargaison? _selectedTypeCargaison;
  final TextEditingController _poidsController = TextEditingController();
  final TextEditingController _risqueController = TextEditingController();
  final TextEditingController _latitudeDepartController = TextEditingController();
  final TextEditingController _longitudeDepartController = TextEditingController();
  final TextEditingController _latitudeArriveeController = TextEditingController();
  final TextEditingController _longitudeArriveeController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _destinataireController = TextEditingController();
  final TextEditingController _telephoneController = TextEditingController();

  @override
  void dispose() {
    _poidsController.dispose();
    _risqueController.dispose();
    _latitudeDepartController.dispose();
    _longitudeDepartController.dispose();
    _latitudeArriveeController.dispose();
    _longitudeArriveeController.dispose();
    _descriptionController.dispose();
    _destinataireController.dispose();
    _telephoneController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedTypeCargaison == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.error_outline, color: Colors.white),
              SizedBox(width: 12),
              Expanded(child: Text('Veuillez sélectionner un type de cargaison')),
            ],
          ),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final mission = Mission(
        poids: double.parse(_poidsController.text),
        risque: int.parse(_risqueController.text),
        typeCargaison: _selectedTypeCargaison!.value,
        statut: 'en_attente',
        latitudeDepart: double.parse(_latitudeDepartController.text),
        longitudeDepart: double.parse(_longitudeDepartController.text),
        latitudeArrivee: double.parse(_latitudeArriveeController.text),
        longitudeArrivee: double.parse(_longitudeArriveeController.text),
        description: _descriptionController.text.isEmpty
            ? null
            : _descriptionController.text,
        destinataire: _destinataireController.text.isEmpty
            ? null
            : _destinataireController.text,
        telephoneContact: _telephoneController.text.isEmpty
            ? null
            : _telephoneController.text,
      );

      final createdMission = await _apiService.createMission(mission);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Mission créée avec succès (ID: ${createdMission.missionId})',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.green.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            duration: const Duration(seconds: 3),
          ),
        );

        // Réinitialiser le formulaire
        _formKey.currentState!.reset();
        setState(() {
          _selectedTypeCargaison = null;
        });
        _poidsController.clear();
        _risqueController.clear();
        _latitudeDepartController.clear();
        _longitudeDepartController.clear();
        _latitudeArriveeController.clear();
        _longitudeArriveeController.clear();
        _descriptionController.clear();
        _destinataireController.clear();
        _telephoneController.clear();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(child: Text('Erreur: ${e.toString().split('\n').first}')),
              ],
            ),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Nouvelle Mission'),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E293B),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildWelcomeHeader(),
                    const SizedBox(height: 32),
                    _buildMaterialSection(),
                    const SizedBox(height: 24),
                    _buildRisqueSection(),
                    const SizedBox(height: 24),
                    _buildWeightSection(),
                    const SizedBox(height: 24),
                    _buildLocationSection(),
                    const SizedBox(height: 24),
                    _buildContactSection(),
                    const SizedBox(height: 24),
                    _buildDescriptionSection(),
                    const SizedBox(height: 100), // Espace pour le bouton flottant
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _buildSubmitButton(),
    );
  }

  Widget _buildWelcomeHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.primary.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
            offset: const Offset(0, 8),
            blurRadius: 24,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.add_task_rounded,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Mission d\'urgence',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Créez une nouvelle mission de livraison critique par drone',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMaterialSection() {
    return _buildSection(
      'Type de matériel',
      Icons.inventory_2_rounded,
      Theme.of(context).colorScheme.primary,
      [
        const Text(
          'Sélectionnez le type de matériel à livrer',
          style: TextStyle(color: Color(0xFF64748B), fontSize: 14),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
        children: TypeCargaison.values.map((type) {
          final isSelected = _selectedTypeCargaison == type;
          return GestureDetector(
            onTap: () => setState(() => _selectedTypeCargaison = type),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected 
                      ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                      : Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected 
                        ? Theme.of(context).colorScheme.primary 
                        : Colors.grey.shade300,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _getTypeIcon(type),
                      color: isSelected 
                          ? Theme.of(context).colorScheme.primary
                          : Colors.grey.shade600,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      type.label,
                      style: TextStyle(
                        color: isSelected 
                            ? Theme.of(context).colorScheme.primary
                            : Colors.grey.shade700,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildRisqueSection() {
    return _buildSection(
      'Niveau de risque',
      Icons.warning_amber_rounded,
      const Color(0xFFDC2626),
      [
        const Text(
          'Définissez le niveau de risque de cette mission (1-5)',
          style: TextStyle(color: Color(0xFF64748B), fontSize: 14),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _risqueController,
          decoration: const InputDecoration(
            labelText: 'Niveau de risque',
            hintText: 'Entrez un niveau de 1 à 5',
            prefixIcon: Icon(Icons.trending_up),
          ),
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Veuillez entrer un niveau de risque';
            }
            final risque = int.tryParse(value);
            if (risque == null || risque < 1 || risque > 5) {
              return 'Le niveau de risque doit être entre 1 et 5';
            }
            return null;
          },
        ),
        if (_risqueController.text.isNotEmpty) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  _getRisqueDescription(int.tryParse(_risqueController.text) ?? 0),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildWeightSection() {
    return _buildSection(
      'Poids du matériel',
      Icons.scale_rounded,
      const Color(0xFF059669),
      [
        const Text(
          'Spécifiez le poids pour l\'attribution du drone',
          style: TextStyle(color: Color(0xFF64748B), fontSize: 14),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _poidsController,
          decoration: const InputDecoration(
            labelText: 'Poids en kilogrammes *',
            prefixIcon: Icon(Icons.scale_rounded),
            suffixText: 'kg',
            hintText: 'Ex: 2.5',
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
          ],
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Poids requis';
            }
            final weight = double.tryParse(value);
            if (weight == null || weight <= 0) {
              return 'Poids invalide';
            }
            if (weight > 50) {
              return 'Poids maximum: 50 kg';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildLocationSection() {
    return Column(
      children: [
        // Point de départ
        GpsPointSelector(
          title: 'Point de départ',
          color: Colors.blue,
          icon: Icons.flight_takeoff_rounded,
          initialLatitude: _latitudeDepartController.text.isNotEmpty 
              ? double.tryParse(_latitudeDepartController.text) 
              : null,
          initialLongitude: _longitudeDepartController.text.isNotEmpty 
              ? double.tryParse(_longitudeDepartController.text) 
              : null,
          onPointSelected: (lat, lng, name) {
            setState(() {
              _latitudeDepartController.text = lat.toString();
              _longitudeDepartController.text = lng.toString();
            });
          },
        ),
        const SizedBox(height: 24),
        
        // Point d'arrivée
        GpsPointSelector(
          title: 'Point d\'arrivée',
          color: Colors.green,
          icon: Icons.flight_land_rounded,
          initialLatitude: _latitudeArriveeController.text.isNotEmpty 
              ? double.tryParse(_latitudeArriveeController.text) 
              : null,
          initialLongitude: _longitudeArriveeController.text.isNotEmpty 
              ? double.tryParse(_longitudeArriveeController.text) 
              : null,
          onPointSelected: (lat, lng, name) {
            setState(() {
              _latitudeArriveeController.text = lat.toString();
              _longitudeArriveeController.text = lng.toString();
            });
          },
        ),
        
        // Validation cachée pour les coordonnées
        Offstage(
          child: Column(
            children: [
              TextFormField(
                controller: _latitudeDepartController,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Point de départ requis';
                  final lat = double.tryParse(value);
                  if (lat == null || lat < -90 || lat > 90) {
                    return 'Latitude de départ invalide';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _longitudeDepartController,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Point de départ requis';
                  final lng = double.tryParse(value);
                  if (lng == null || lng < -180 || lng > 180) {
                    return 'Longitude de départ invalide';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _latitudeArriveeController,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Point d\'arrivée requis';
                  final lat = double.tryParse(value);
                  if (lat == null || lat < -90 || lat > 90) {
                    return 'Latitude d\'arrivée invalide';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _longitudeArriveeController,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Point d\'arrivée requis';
                  final lng = double.tryParse(value);
                  if (lng == null || lng < -180 || lng > 180) {
                    return 'Longitude d\'arrivée invalide';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildContactSection() {
    return _buildSection(
      'Informations de contact',
      Icons.contact_phone_rounded,
      const Color(0xFFF59E0B),
      [
        const Text(
          'Coordonnées du destinataire (optionnel)',
          style: TextStyle(color: Color(0xFF64748B), fontSize: 14),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _destinataireController,
          decoration: const InputDecoration(
            labelText: 'Nom du destinataire',
            prefixIcon: Icon(Icons.person_rounded),
            hintText: 'Dr. Martin Dubois',
          ),
          textCapitalization: TextCapitalization.words,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _telephoneController,
          decoration: const InputDecoration(
            labelText: 'Téléphone de contact',
            prefixIcon: Icon(Icons.phone_rounded),
            hintText: '+33 6 12 34 56 78',
          ),
          keyboardType: TextInputType.phone,
        ),
      ],
    );
  }

  Widget _buildDescriptionSection() {
    return _buildSection(
      'Description de la mission',
      Icons.description_rounded,
      const Color(0xFF8B5CF6),
      [
        const Text(
          'Ajoutez des détails supplémentaires (optionnel)',
          style: TextStyle(color: Color(0xFF64748B), fontSize: 14),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _descriptionController,
          decoration: const InputDecoration(
            labelText: 'Informations supplémentaires',
            hintText: 'Patient en arrêt cardiaque, livraison urgente...',
            alignLabelWithHint: true,
          ),
          maxLines: 4,
          textCapitalization: TextCapitalization.sentences,
        ),
      ],
    );
  }

  Widget _buildSection(String title, IconData icon, Color color, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(24),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 16),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
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

  Widget _buildSubmitButton() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: FloatingActionButton.extended(
        onPressed: _isLoading ? null : _submitForm,
        backgroundColor: _isLoading 
            ? Colors.grey.shade400 
            : Theme.of(context).colorScheme.primary,
        elevation: 8,
        extendedPadding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        label: _isLoading
            ? const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: 12),
                  Text('Création en cours...'),
                ],
              )
            : const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.send_rounded),
                  SizedBox(width: 8),
                  Text(
                    'Créer la mission',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  IconData _getTypeIcon(TypeCargaison type) {
    switch (type) {
      case TypeCargaison.pocheSang:
        return Icons.bloodtype_rounded;
      case TypeCargaison.defibrillateur:
        return Icons.monitor_heart_rounded;
      case TypeCargaison.medicament:
        return Icons.medication_rounded;
      case TypeCargaison.pieceMecanique:
        return Icons.build_rounded;
      case TypeCargaison.fragile:
        return Icons.warning_rounded;
      case TypeCargaison.perissable:
        return Icons.access_time_rounded;
      case TypeCargaison.autre:
        return Icons.inventory_2_rounded;
    }
  }

  String _getRisqueDescription(int risque) {
    switch (risque) {
      case 1:
        return 'Très faible';
      case 2:
        return 'Faible';
      case 3:
        return 'Moyen';
      case 4:
        return 'Élevé';
      case 5:
        return 'Critique';
      default:
        return 'Non défini';
    }
  }
}