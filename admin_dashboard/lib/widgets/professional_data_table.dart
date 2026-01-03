import 'package:flutter/material.dart';
import 'package:data_table_2/data_table_2.dart';
import '../utils/app_theme.dart';
import '../utils/status_chip.dart';
import '../utils/debouncer.dart';

/// Professional Data Table Component for Web Admin Dashboard
/// Features: Search, Filter, Pagination, Sorting, Actions
class ProfessionalDataTable extends StatefulWidget {
  final List<Map<String, dynamic>> data;
  final List<DataColumn2> columns;
  final DataRow2 Function(Map<String, dynamic> data) buildRow;
  final String? searchHint;
  final Function(String)? onSearch;
  final List<String>? filterOptions;
  final Function(String?)? onFilterChanged;
  final int rowsPerPage;
  final bool showPagination;

  const ProfessionalDataTable({
    super.key,
    required this.data,
    required this.columns,
    required this.buildRow,
    this.searchHint,
    this.onSearch,
    this.filterOptions,
    this.onFilterChanged,
    this.rowsPerPage = 10,
    this.showPagination = true,
  });

  @override
  State<ProfessionalDataTable> createState() => _ProfessionalDataTableState();
}

class _ProfessionalDataTableState extends State<ProfessionalDataTable> {
  final TextEditingController _searchController = TextEditingController();
  final Debouncer _searchDebouncer = Debouncer(delay: const Duration(milliseconds: 300));
  String? _selectedFilter;
  int _currentPage = 0;
  String _sortColumn = '';
  bool _sortAscending = true;
  String _searchQuery = '';

  List<Map<String, dynamic>> get _filteredData {
    var filtered = List<Map<String, dynamic>>.from(widget.data);
    
    // Apply search filter (using debounced query)
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((item) {
        return item.values.any((value) =>
            value.toString().toLowerCase().contains(query));
      }).toList();
    }
    
    // Apply status filter (supports both 'status' and 'active' fields)
    if (_selectedFilter != null) {
      filtered = filtered.where((item) {
        // Check for status field (for requests/applications)
        if (item['status'] != null) {
          return item['status']?.toString() == _selectedFilter;
        }
        // Check for active field (for technicians/partners)
        if (item['active'] != null) {
          if (_selectedFilter == 'active') {
            return item['active'] == true;
          } else if (_selectedFilter == 'inactive') {
            return item['active'] == false;
          }
        }
        return false;
      }).toList();
    }
    
    return filtered;
  }

  List<Map<String, dynamic>> get _paginatedData {
    final start = _currentPage * widget.rowsPerPage;
    final end = (start + widget.rowsPerPage).clamp(0, _filteredData.length);
    return _filteredData.sublist(start.clamp(0, _filteredData.length), end);
  }

  int get _totalPages => (_filteredData.length / widget.rowsPerPage).ceil();

  @override
  void dispose() {
    _searchController.dispose();
    _searchDebouncer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 24,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Toolbar: Search + Filters
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.grey.shade200),
              ),
            ),
            child: Row(
              children: [
                // Search Bar
                Expanded(
                  child: Container(
                    height: 42,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F9FA),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (value) {
                        // Debounce search to reduce rebuilds
                        _searchDebouncer.call(() {
                          if (mounted) {
                            setState(() {
                              _searchQuery = value;
                              _currentPage = 0;
                            });
                            widget.onSearch?.call(value);
                          }
                        });
                      },
                      decoration: InputDecoration(
                        hintText: widget.searchHint ?? 'Rechercher...',
                        hintStyle: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 14,
                        ),
                        prefixIcon: Icon(
                          Icons.search_rounded,
                          color: Colors.grey.shade500,
                          size: 20,
                        ),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: Icon(Icons.clear, size: 18, color: Colors.grey.shade500),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() {
                                    _searchQuery = '';
                                    _currentPage = 0;
                                  });
                                  widget.onSearch?.call('');
                                },
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Filter Dropdown
                if (widget.filterOptions != null && widget.filterOptions!.isNotEmpty)
                  Container(
                    height: 42,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedFilter,
                        hint: const Text('Filtrer'),
                        isDense: true,
                        items: [
                          const DropdownMenuItem(
                            value: null,
                            child: Text('Tous'),
                          ),
                          ...widget.filterOptions!.map((option) {
                            String label = option;
                            switch (option) {
                              case 'pending':
                                label = 'En attente';
                                break;
                              case 'approved':
                                label = 'Approuvé';
                                break;
                              case 'rejected':
                                label = 'Rejeté';
                                break;
                              case 'assigned':
                                label = 'Assigné';
                                break;
                              case 'active':
                                label = 'Actif';
                                break;
                              case 'inactive':
                                label = 'Inactif';
                                break;
                            }
                            return DropdownMenuItem(
                              value: option,
                              child: Text(label),
                            );
                          }),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedFilter = value;
                            _currentPage = 0;
                          });
                          widget.onFilterChanged?.call(value);
                        },
                      ),
                    ),
                  ),
                const SizedBox(width: 12),
                // Export Button
                OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.download_rounded, size: 18),
                  label: const Text('Exporter'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    side: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
              ],
            ),
          ),
          // Data Table
          Expanded(
            child: DataTable2(
              columnSpacing: 24,
              horizontalMargin: 20,
              minWidth: 800,
              columns: widget.columns,
              rows: _paginatedData.map((item) => widget.buildRow(item)).toList(),
              headingRowDecoration: BoxDecoration(
                color: const Color(0xFFF8F9FA),
                border: Border(
                  bottom: BorderSide(color: Colors.grey.shade200, width: 1),
                ),
              ),
              headingRowHeight: 56,
              dataRowHeight: 64,
              headingTextStyle: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppTheme.textSecondary,
                letterSpacing: 0.3,
              ),
              dataTextStyle: const TextStyle(
                fontSize: 14,
                color: AppTheme.textPrimary,
                height: 1.4,
              ),
              // Performance optimizations
              smRatio: 0.75,
              lmRatio: 1.5,
            ),
          ),
          // Pagination
          if (widget.showPagination && _totalPages > 1)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: Colors.grey.shade200),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Affichage ${_currentPage * widget.rowsPerPage + 1}-${(_currentPage * widget.rowsPerPage + widget.rowsPerPage).clamp(0, _filteredData.length)} sur ${_filteredData.length}',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left_rounded),
                        onPressed: _currentPage > 0
                            ? () => setState(() => _currentPage--)
                            : null,
                        color: _currentPage > 0
                            ? AppTheme.textPrimary
                            : Colors.grey.shade400,
                      ),
                      ...List.generate(
                        _totalPages.clamp(0, 7),
                        (index) {
                          if (_totalPages > 7) {
                            if (index == 0) {
                              return _buildPageButton(0);
                            } else if (index == 6) {
                              return _buildPageButton(_totalPages - 1);
                            } else if (index == 3) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 4),
                                child: Text(
                                  '...',
                                  style: TextStyle(color: AppTheme.textSecondary),
                                ),
                              );
                            } else {
                              return _buildPageButton(_currentPage + index - 3);
                            }
                          }
                          return _buildPageButton(index);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.chevron_right_rounded),
                        onPressed: _currentPage < _totalPages - 1
                            ? () => setState(() => _currentPage++)
                            : null,
                        color: _currentPage < _totalPages - 1
                            ? AppTheme.textPrimary
                            : Colors.grey.shade400,
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

  Widget _buildPageButton(int page) {
    final isSelected = page == _currentPage;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => setState(() => _currentPage = page),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: isSelected ? AppTheme.primaryColor : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: Text(
              '${page + 1}',
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? Colors.white : AppTheme.textPrimary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

