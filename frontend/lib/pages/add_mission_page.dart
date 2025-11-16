import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/mission.dart';
import '../services/api_service.dart';

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
  TypeMateriel? _selectedTypeMateriel;
  Urgence? _selectedUrgence;
  final TextEditingController _poidsController = TextEditingController();
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

    if (_selectedTypeMateriel == null || _selectedUrgence == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.error_outline, color: Colors.white),
              SizedBox(width: 12),
              Expanded(child: Text('Veuillez remplir tous les champs obligatoires')),
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
        typeMateriel: _selectedTypeMateriel!,
        urgence: _selectedUrgence!,
        poidsKg: double.parse(_poidsController.text),
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
                    'Mission créée avec succès (ID: ${createdMission.id})',
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
        _selectedTypeMateriel = null;
        _selectedUrgence = null;
        _poidsController.clear();
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

  Widget _buildSectionHeader(String title, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildUrgencyBadge(Urgence urgence) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: urgence.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: urgence.color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: urgence.color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            urgence.label,
            style: TextStyle(
              color: urgence.color,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Header avec gradient
          SliverAppBar(
            expandedHeight: 180,
            floating: false,
            pinned: true,
            elevation: 0,
            backgroundColor: Colors.transparent,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                'Nouvelle Mission',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              centerTitle: true,
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFF1E88E5),
                      const Color(0xFF1565C0),
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      top: -50,
                      right: -50,
                      child: Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.1),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: -30,
                      left: -30,
                      child: Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.1),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Contenu du formulaire
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Section Matériel
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionHeader(
                              'Informations du matériel',
                              Icons.inventory_2,
                              const Color(0xFF1E88E5),
                            ),
                            const SizedBox(height: 8),
                            
                            // Type de matériel
                            DropdownButtonFormField<TypeMateriel>(
                              value: _selectedTypeMateriel,
                              decoration: InputDecoration(
                                labelText: 'Type de matériel *',
                                prefixIcon: const Icon(Icons.local_shipping),
                                suffixIcon: _selectedTypeMateriel != null
                                    ? Icon(Icons.check_circle, 
                                        color: Colors.green.shade600, size: 20)
                                    : null,
                              ),
                              items: TypeMateriel.values.map((type) {
                                return DropdownMenuItem(
                                  value: type,
                                  child: Row(
                                    children: [
                                      Icon(_getMaterialIcon(type), 
                                          color: Colors.grey.shade700, size: 20),
                                      const SizedBox(width: 12),
                                      Text(type.label),
                                    ],
                                  ),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedTypeMateriel = value;
                                });
                              },
                              validator: (value) {
                                if (value == null) {
                                  return 'Veuillez sélectionner un type de matériel';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 20),
                            
                            // Urgence
                            DropdownButtonFormField<Urgence>(
                              value: _selectedUrgence,
                              decoration: InputDecoration(
                                labelText: 'Niveau d\'urgence *',
                                prefixIcon: const Icon(Icons.priority_high),
                                suffixIcon: _selectedUrgence != null
                                    ? _buildUrgencyBadge(_selectedUrgence!)
                                    : null,
                              ),
                              items: Urgence.values.map((urgence) {
                                return DropdownMenuItem(
                                  value: urgence,
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 12,
                                        height: 12,
                                        decoration: BoxDecoration(
                                          color: urgence.color,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Text(urgence.label),
                                    ],
                                  ),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedUrgence = value;
                                });
                              },
                              validator: (value) {
                                if (value == null) {
                                  return 'Veuillez sélectionner un niveau d\'urgence';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 20),
                            
                            // Poids
                            TextFormField(
                              controller: _poidsController,
                              decoration: const InputDecoration(
                                labelText: 'Poids (kg) *',
                                prefixIcon: Icon(Icons.scale),
                                hintText: 'Ex: 2.5',
                                suffixText: 'kg',
                              ),
                              keyboardType: TextInputType.numberWithOptions(decimal: true),
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                              ],
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Veuillez entrer le poids';
                                }
                                final poids = double.tryParse(value);
                                if (poids == null || poids <= 0) {
                                  return 'Le poids doit être un nombre positif';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    // Section Départ
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionHeader(
                              'Point de départ',
                              Icons.flight_takeoff,
                              const Color(0xFF43A047),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: _latitudeDepartController,
                                    decoration: const InputDecoration(
                                      labelText: 'Latitude *',
                                      prefixIcon: Icon(Icons.location_on),
                                      hintText: 'Ex: 48.8566',
                                    ),
                                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                                    inputFormatters: [
                                      FilteringTextInputFormatter.allow(
                                        RegExp(r'^-?\d+\.?\d{0,6}'),
                                      ),
                                    ],
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Latitude requise';
                                      }
                                      final lat = double.tryParse(value);
                                      if (lat == null || lat < -90 || lat > 90) {
                                        return 'Latitude invalide (-90 à 90)';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: TextFormField(
                                    controller: _longitudeDepartController,
                                    decoration: const InputDecoration(
                                      labelText: 'Longitude *',
                                      prefixIcon: Icon(Icons.explore),
                                      hintText: 'Ex: 2.3522',
                                    ),
                                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                                    inputFormatters: [
                                      FilteringTextInputFormatter.allow(
                                        RegExp(r'^-?\d+\.?\d{0,6}'),
                                      ),
                                    ],
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Longitude requise';
                                      }
                                      final lon = double.tryParse(value);
                                      if (lon == null || lon < -180 || lon > 180) {
                                        return 'Longitude invalide (-180 à 180)';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    // Section Arrivée
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionHeader(
                              'Point d\'arrivée',
                              Icons.flight_land,
                              Colors.orange,
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: _latitudeArriveeController,
                                    decoration: const InputDecoration(
                                      labelText: 'Latitude *',
                                      prefixIcon: Icon(Icons.location_on),
                                      hintText: 'Ex: 48.8566',
                                    ),
                                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                                    inputFormatters: [
                                      FilteringTextInputFormatter.allow(
                                        RegExp(r'^-?\d+\.?\d{0,6}'),
                                      ),
                                    ],
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Latitude requise';
                                      }
                                      final lat = double.tryParse(value);
                                      if (lat == null || lat < -90 || lat > 90) {
                                        return 'Latitude invalide (-90 à 90)';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: TextFormField(
                                    controller: _longitudeArriveeController,
                                    decoration: const InputDecoration(
                                      labelText: 'Longitude *',
                                      prefixIcon: Icon(Icons.explore),
                                      hintText: 'Ex: 2.3522',
                                    ),
                                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                                    inputFormatters: [
                                      FilteringTextInputFormatter.allow(
                                        RegExp(r'^-?\d+\.?\d{0,6}'),
                                      ),
                                    ],
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Longitude requise';
                                      }
                                      final lon = double.tryParse(value);
                                      if (lon == null || lon < -180 || lon > 180) {
                                        return 'Longitude invalide (-180 à 180)';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    // Section Informations complémentaires
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionHeader(
                              'Informations complémentaires',
                              Icons.info_outline,
                              Colors.purple,
                            ),
                            const SizedBox(height: 8),
                            
                            TextFormField(
                              controller: _destinataireController,
                              decoration: const InputDecoration(
                                labelText: 'Destinataire',
                                prefixIcon: Icon(Icons.person),
                                hintText: 'Nom du destinataire',
                              ),
                              textCapitalization: TextCapitalization.words,
                            ),
                            const SizedBox(height: 16),
                            
                            TextFormField(
                              controller: _telephoneController,
                              decoration: const InputDecoration(
                                labelText: 'Téléphone de contact',
                                prefixIcon: Icon(Icons.phone),
                                hintText: 'Ex: +33 6 12 34 56 78',
                              ),
                              keyboardType: TextInputType.phone,
                            ),
                            const SizedBox(height: 16),
                            
                            TextFormField(
                              controller: _descriptionController,
                              decoration: const InputDecoration(
                                labelText: 'Description',
                                prefixIcon: Icon(Icons.description),
                                hintText: 'Informations supplémentaires...',
                                alignLabelWithHint: true,
                              ),
                              maxLines: 3,
                              textCapitalization: TextCapitalization.sentences,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    
                    // Bouton de soumission
                    Container(
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFF1E88E5),
                            const Color(0xFF1565C0),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF1E88E5).withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _submitForm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.send, color: Colors.white),
                                  SizedBox(width: 12),
                                  Text(
                                    'Créer la mission',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getMaterialIcon(TypeMateriel type) {
    switch (type) {
      case TypeMateriel.pocheSang:
        return Icons.bloodtype;
      case TypeMateriel.defibrillateur:
        return Icons.medical_services;
      case TypeMateriel.medicament:
        return Icons.medication;
      case TypeMateriel.pieceMecanique:
        return Icons.build;
      case TypeMateriel.autre:
        return Icons.category;
    }
  }
}
