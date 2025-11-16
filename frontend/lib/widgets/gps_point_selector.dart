import 'package:flutter/material.dart';
import '../models/gps_point.dart';

class GpsPointSelector extends StatefulWidget {
  final String title;
  final Color color;
  final IconData icon;
  final Function(double lat, double lng, String? name) onPointSelected;
  final double? initialLatitude;
  final double? initialLongitude;

  const GpsPointSelector({
    super.key,
    required this.title,
    required this.color,
    required this.icon,
    required this.onPointSelected,
    this.initialLatitude,
    this.initialLongitude,
  });

  @override
  State<GpsPointSelector> createState() => _GpsPointSelectorState();
}

class _GpsPointSelectorState extends State<GpsPointSelector> {
  GpsPointType? _selectedType;
  GpsPoint? _selectedPoint;
  bool _showCustomInput = false;
  final TextEditingController _latController = TextEditingController();
  final TextEditingController _lngController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.initialLatitude != null && widget.initialLongitude != null) {
      _latController.text = widget.initialLatitude.toString();
      _lngController.text = widget.initialLongitude.toString();
    }
  }

  @override
  void dispose() {
    _latController.dispose();
    _lngController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
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
          // En-tête
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: widget.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(widget.icon, color: widget.color, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  widget.title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Sélection du type de point
          const Text(
            'Sélectionnez un type de lieu',
            style: TextStyle(color: Color(0xFF64748B), fontSize: 14),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ...GpsPointType.values.where((type) => type != GpsPointType.custom).map((type) => 
                FilterChip(
                  label: Text(type.label),
                  selected: _selectedType == type,
                  onSelected: (selected) {
                    setState(() {
                      _selectedType = selected ? type : null;
                      _selectedPoint = null;
                      _showCustomInput = false;
                    });
                  },
                  backgroundColor: Colors.grey.shade50,
                  selectedColor: widget.color.withOpacity(0.1),
                  checkmarkColor: widget.color,
                  labelStyle: TextStyle(
                    color: _selectedType == type ? widget.color : Colors.grey.shade700,
                    fontWeight: _selectedType == type ? FontWeight.w600 : FontWeight.w500,
                  ),
                  side: BorderSide(
                    color: _selectedType == type ? widget.color : Colors.grey.shade300,
                    width: _selectedType == type ? 2 : 1,
                  ),
                ),
              ),
              FilterChip(
                label: const Text('Point personnalisé'),
                selected: _showCustomInput,
                onSelected: (selected) {
                  setState(() {
                    _showCustomInput = selected;
                    _selectedType = null;
                    _selectedPoint = null;
                  });
                },
                backgroundColor: Colors.grey.shade50,
                selectedColor: widget.color.withOpacity(0.1),
                checkmarkColor: widget.color,
                labelStyle: TextStyle(
                  color: _showCustomInput ? widget.color : Colors.grey.shade700,
                  fontWeight: _showCustomInput ? FontWeight.w600 : FontWeight.w500,
                ),
                side: BorderSide(
                  color: _showCustomInput ? widget.color : Colors.grey.shade300,
                  width: _showCustomInput ? 2 : 1,
                ),
              ),
            ],
          ),
          
          if (_selectedType != null) ...[
            const SizedBox(height: 20),
            _buildPointsList(),
          ],
          
          if (_showCustomInput) ...[
            const SizedBox(height: 20),
            _buildCustomInput(),
          ],
          
          if (_selectedPoint != null || (_showCustomInput && _areCustomFieldsValid())) ...[
            const SizedBox(height: 20),
            _buildSelectedPointInfo(),
          ],
        ],
      ),
    );
  }

  Widget _buildPointsList() {
    final points = PredefinedGpsPoints.getPointsByType(_selectedType!);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Choisissez un ${_selectedType!.label.toLowerCase()}',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          constraints: const BoxConstraints(maxHeight: 200),
          child: SingleChildScrollView(
            child: Column(
              children: points.map((point) => 
                Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: _selectedPoint?.id == point.id 
                        ? widget.color.withOpacity(0.1)
                        : Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _selectedPoint?.id == point.id 
                          ? widget.color 
                          : Colors.grey.shade300,
                      width: _selectedPoint?.id == point.id ? 2 : 1,
                    ),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _getTypeColor(point.type).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        _getTypeIcon(point.type),
                        color: _getTypeColor(point.type),
                        size: 20,
                      ),
                    ),
                    title: Text(
                      point.name,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: _selectedPoint?.id == point.id 
                            ? widget.color 
                            : const Color(0xFF1E293B),
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          point.description,
                          style: const TextStyle(fontSize: 12),
                        ),
                        Text(
                          '${point.latitude.toStringAsFixed(4)}, ${point.longitude.toStringAsFixed(4)}',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade600,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ],
                    ),
                    onTap: () {
                      setState(() {
                        _selectedPoint = point;
                      });
                      widget.onPointSelected(
                        point.latitude,
                        point.longitude,
                        point.name,
                      );
                    },
                  ),
                ),
              ).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCustomInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Coordonnées personnalisées',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _nameController,
          decoration: const InputDecoration(
            labelText: 'Nom du lieu',
            hintText: 'Ex: Clinique Saint-Martin',
            prefixIcon: Icon(Icons.location_city_rounded),
          ),
          textCapitalization: TextCapitalization.words,
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _latController,
                decoration: const InputDecoration(
                  labelText: 'Latitude *',
                  hintText: '48.8566',
                  prefixIcon: Icon(Icons.my_location_rounded),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                onChanged: (_) {
                  setState(() {});
                  _updateCustomPoint();
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: _lngController,
                decoration: const InputDecoration(
                  labelText: 'Longitude *',
                  hintText: '2.3522',
                  prefixIcon: Icon(Icons.place_rounded),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                onChanged: (_) {
                  setState(() {});
                  _updateCustomPoint();
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSelectedPointInfo() {
    String name;
    double lat, lng;
    
    if (_selectedPoint != null) {
      name = _selectedPoint!.name;
      lat = _selectedPoint!.latitude;
      lng = _selectedPoint!.longitude;
    } else {
      name = _nameController.text.isNotEmpty ? _nameController.text : 'Point personnalisé';
      lat = double.parse(_latController.text);
      lng = double.parse(_lngController.text);
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: widget.color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: widget.color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.check_circle_rounded, color: widget.color, size: 20),
              const SizedBox(width: 8),
              Text(
                'Point sélectionné',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: widget.color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            name,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E293B),
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Coordonnées: ${lat.toStringAsFixed(6)}, ${lng.toStringAsFixed(6)}',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }

  bool _areCustomFieldsValid() {
    if (_latController.text.isEmpty || _lngController.text.isEmpty) return false;
    final lat = double.tryParse(_latController.text);
    final lng = double.tryParse(_lngController.text);
    return lat != null && lng != null && lat >= -90 && lat <= 90 && lng >= -180 && lng <= 180;
  }

  void _updateCustomPoint() {
    if (_areCustomFieldsValid()) {
      final lat = double.parse(_latController.text);
      final lng = double.parse(_lngController.text);
      widget.onPointSelected(lat, lng, _nameController.text.isNotEmpty ? _nameController.text : null);
    }
  }

  Color _getTypeColor(GpsPointType type) {
    switch (type) {
      case GpsPointType.hospital:
        return const Color(0xFFDC2626);
      case GpsPointType.pharmacy:
        return const Color(0xFF059669);
      case GpsPointType.fireStation:
        return const Color(0xFFEA580C);
      case GpsPointType.policeStation:
        return const Color(0xFF2563EB);
      case GpsPointType.airport:
        return const Color(0xFF7C3AED);
      case GpsPointType.warehouse:
        return const Color(0xFF65A30D);
      case GpsPointType.custom:
        return const Color(0xFF6B7280);
    }
  }

  IconData _getTypeIcon(GpsPointType type) {
    switch (type) {
      case GpsPointType.hospital:
        return Icons.local_hospital_rounded;
      case GpsPointType.pharmacy:
        return Icons.local_pharmacy_rounded;
      case GpsPointType.fireStation:
        return Icons.fire_truck_rounded;
      case GpsPointType.policeStation:
        return Icons.local_police_rounded;
      case GpsPointType.airport:
        return Icons.flight_rounded;
      case GpsPointType.warehouse:
        return Icons.warehouse_rounded;
      case GpsPointType.custom:
        return Icons.place_rounded;
    }
  }
}