import 'package:flutter/material.dart';
import 'package:noor_energy/core/services/city_service.dart';
import 'package:noor_energy/l10n/app_localizations.dart';

class CityPickerField extends StatefulWidget {
  final String? selectedCityId;
  final ValueChanged<String?> onCityIdChanged;
  final TextEditingController otherCityController;
  final VoidCallback? onChanged;
  final Color fillColor;
  final Color outlineColor;

  const CityPickerField({
    super.key,
    required this.selectedCityId,
    required this.onCityIdChanged,
    required this.otherCityController,
    this.onChanged,
    required this.fillColor,
    required this.outlineColor,
  });

  @override
  State<CityPickerField> createState() => _CityPickerFieldState();
}

class _CityPickerFieldState extends State<CityPickerField> {
  bool _isLoading = true;
  List<MoroccanCity> _cities = const [];

  @override
  void initState() {
    super.initState();
    widget.otherCityController.addListener(_notifyChanged);
    _loadCities();
  }

  @override
  void dispose() {
    widget.otherCityController.removeListener(_notifyChanged);
    super.dispose();
  }

  void _notifyChanged() {
    widget.onChanged?.call();
    setState(() {});
  }

  Future<void> _loadCities() async {
    await CityService.instance.ensureLoaded();
    if (!mounted) return;
    final locale = Localizations.localeOf(context).languageCode;
    setState(() {
      _cities = CityService.instance.getCitiesSorted(locale);
      _isLoading = false;
    });
  }

  bool get _isOtherSelected => widget.selectedCityId == CityService.otherCityId;

  InputDecoration _fieldDecoration({
    required String label,
    required String? hint,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      filled: true,
      fillColor: widget.fillColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: widget.outlineColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: widget.outlineColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFF3A80BA), width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      prefixIcon: Icon(icon),
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).languageCode;

    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DropdownButtonFormField<String>(
          key: ValueKey<String?>(widget.selectedCityId),
          initialValue: widget.selectedCityId,
          decoration: _fieldDecoration(
            label: '${localizations.city} *',
            hint: localizations.cityHint,
            icon: Icons.location_city,
          ),
          items: [
            ..._cities.map(
              (city) => DropdownMenuItem<String>(
                value: city.id,
                child: Text(city.displayName(locale)),
              ),
            ),
            DropdownMenuItem<String>(
              value: CityService.otherCityId,
              child: Text(localizations.otherLocation),
            ),
          ],
          onChanged: (value) {
            widget.onCityIdChanged(value);
            widget.onChanged?.call();
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return localizations.validationPleaseEnterCity;
            }
            return null;
          },
        ),
        if (_isOtherSelected) ...[
          const SizedBox(height: 12),
          TextFormField(
            controller: widget.otherCityController,
            decoration: _fieldDecoration(
              label: localizations.otherLocation,
              hint: localizations.cityHint,
              icon: Icons.edit_location_alt_outlined,
            ),
            textCapitalization: TextCapitalization.words,
            validator: (value) {
              if (!_isOtherSelected) return null;
              if (value == null || value.trim().isEmpty) {
                return localizations.validationPleaseEnterCity;
              }
              return null;
            },
          ),
        ],
      ],
    );
  }
}
