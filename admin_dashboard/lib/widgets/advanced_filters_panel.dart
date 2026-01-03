import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../utils/app_theme.dart';
import '../utils/debouncer.dart';

class AdvancedFiltersPanel extends StatefulWidget {
  final Function(String?) onStatusFilterChanged;
  final Function(DateTime?, DateTime?) onDateRangeChanged;
  final Function(String?) onRegionFilterChanged;
  final Function(String) onSearchChanged;
  final String? initialStatus;
  final DateTime? initialStartDate;
  final DateTime? initialEndDate;
  final String? initialRegion;
  final String initialSearch;

  const AdvancedFiltersPanel({
    super.key,
    required this.onStatusFilterChanged,
    required this.onDateRangeChanged,
    required this.onRegionFilterChanged,
    required this.onSearchChanged,
    this.initialStatus,
    this.initialStartDate,
    this.initialEndDate,
    this.initialRegion,
    this.initialSearch = '',
  });

  @override
  State<AdvancedFiltersPanel> createState() => _AdvancedFiltersPanelState();
}

class _AdvancedFiltersPanelState extends State<AdvancedFiltersPanel> {
  final TextEditingController _searchController = TextEditingController();
  final Debouncer _searchDebouncer = Debouncer(delay: const Duration(milliseconds: 300));
  
  String? _selectedStatus;
  DateTime? _startDate;
  DateTime? _endDate;
  String? _selectedRegion;
  bool _isExpanded = false;

  final List<String> _regions = [
    'Casablanca',
    'Rabat',
    'Marrakech',
    'Fès',
    'Tanger',
    'Agadir',
    'Meknès',
    'Oujda',
    'Tétouan',
    'Safi',
    'Autre',
  ];

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.initialStatus;
    _startDate = widget.initialStartDate;
    _endDate = widget.initialEndDate;
    _selectedRegion = widget.initialRegion;
    _searchController.text = widget.initialSearch;
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchDebouncer.dispose();
    super.dispose();
  }

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: _startDate != null && _endDate != null
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : null,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppTheme.primaryColor,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppTheme.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
      widget.onDateRangeChanged(_startDate, _endDate);
    }
  }

  void _clearFilters() {
    setState(() {
      _selectedStatus = null;
      _startDate = null;
      _endDate = null;
      _selectedRegion = null;
      _searchController.clear();
    });
    widget.onStatusFilterChanged(null);
    widget.onDateRangeChanged(null, null);
    widget.onRegionFilterChanged(null);
    widget.onSearchChanged('');
  }

  bool get _hasActiveFilters {
    return _selectedStatus != null ||
        _startDate != null ||
        _endDate != null ||
        _selectedRegion != null ||
        _searchController.text.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header with toggle
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Container(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Icon(
                    Icons.filter_list_rounded,
                    color: AppTheme.primaryColor,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Filtres avancés',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  if (_hasActiveFilters)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Actifs',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ),
                  const SizedBox(width: 12),
                  Icon(
                    _isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: AppTheme.textSecondary,
                  ),
                ],
              ),
            ),
          ),
          // Filters content
          if (_isExpanded)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: Colors.grey.shade200),
                ),
              ),
              child: Column(
                children: [
                  // Search field
                  Container(
                    height: 42,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F9FA),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (value) {
                        _searchDebouncer.call(() {
                          widget.onSearchChanged(value);
                        });
                      },
                      decoration: InputDecoration(
                        hintText: 'Rechercher par nom, téléphone, ville...',
                        hintStyle: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 14,
                        ),
                        prefixIcon: Icon(
                          Icons.search_rounded,
                          color: Colors.grey.shade500,
                          size: 20,
                        ),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: Icon(Icons.clear, size: 18, color: Colors.grey.shade500),
                                onPressed: () {
                                  _searchController.clear();
                                  widget.onSearchChanged('');
                                },
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Filters row
                  Row(
                    children: [
                      // Status filter
                      Expanded(
                        child: Container(
                          height: 42,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedStatus,
                              hint: const Text('Statut'),
                              isExpanded: true,
                              isDense: true,
                              items: [
                                const DropdownMenuItem(
                                  value: null,
                                  child: Text('Tous les statuts'),
                                ),
                                const DropdownMenuItem(
                                  value: 'pending',
                                  child: Text('En attente'),
                                ),
                                const DropdownMenuItem(
                                  value: 'approved',
                                  child: Text('Approuvé'),
                                ),
                                const DropdownMenuItem(
                                  value: 'rejected',
                                  child: Text('Rejeté'),
                                ),
                                const DropdownMenuItem(
                                  value: 'assigned',
                                  child: Text('Assigné'),
                                ),
                                const DropdownMenuItem(
                                  value: 'completed',
                                  child: Text('Terminé'),
                                ),
                              ],
                              onChanged: (value) {
                                setState(() => _selectedStatus = value);
                                widget.onStatusFilterChanged(value);
                              },
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Date range filter
                      Expanded(
                        child: InkWell(
                          onTap: _selectDateRange,
                          child: Container(
                            height: 42,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.calendar_today, size: 18, color: Colors.grey.shade600),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _startDate != null && _endDate != null
                                        ? '${DateFormat('dd/MM/yyyy').format(_startDate!)} - ${DateFormat('dd/MM/yyyy').format(_endDate!)}'
                                        : 'Période',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: _startDate != null ? AppTheme.textPrimary : Colors.grey.shade600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Region filter
                      Expanded(
                        child: Container(
                          height: 42,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedRegion,
                              hint: const Text('Région'),
                              isExpanded: true,
                              isDense: true,
                              items: [
                                const DropdownMenuItem(
                                  value: null,
                                  child: Text('Toutes les régions'),
                                ),
                                ..._regions.map((region) => DropdownMenuItem(
                                      value: region,
                                      child: Text(region),
                                    )),
                              ],
                              onChanged: (value) {
                                setState(() => _selectedRegion = value);
                                widget.onRegionFilterChanged(value);
                              },
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Clear filters button
                      if (_hasActiveFilters)
                        OutlinedButton.icon(
                          onPressed: _clearFilters,
                          icon: const Icon(Icons.clear_all, size: 18),
                          label: const Text('Réinitialiser'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            side: BorderSide(color: Colors.grey.shade300),
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
}

