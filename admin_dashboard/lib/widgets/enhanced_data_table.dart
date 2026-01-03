import 'package:flutter/material.dart';
import 'package:data_table_2/data_table_2.dart';
import '../utils/app_theme.dart';

/// Enhanced Data Table with bulk selection support
class EnhancedDataTable extends StatefulWidget {
  final List<Map<String, dynamic>> data;
  final List<DataColumn2> columns;
  final DataRow2 Function(Map<String, dynamic> data, bool isSelected) buildRow;
  final Function(List<String> selectedIds) onBulkAction;
  final int rowsPerPage;
  final bool showPagination;

  const EnhancedDataTable({
    super.key,
    required this.data,
    required this.columns,
    required this.buildRow,
    required this.onBulkAction,
    this.rowsPerPage = 15,
    this.showPagination = true,
  });

  @override
  State<EnhancedDataTable> createState() => _EnhancedDataTableState();
}

class _EnhancedDataTableState extends State<EnhancedDataTable> {
  final Set<String> _selectedIds = {};
  int _currentPage = 0;
  bool _selectAll = false;

  List<Map<String, dynamic>> get _paginatedData {
    final start = _currentPage * widget.rowsPerPage;
    final end = (start + widget.rowsPerPage).clamp(0, widget.data.length);
    return widget.data.sublist(start.clamp(0, widget.data.length), end);
  }

  int get _totalPages => (widget.data.length / widget.rowsPerPage).ceil();

  void _toggleSelectAll(bool? value) {
    setState(() {
      _selectAll = value ?? false;
      if (_selectAll) {
        _selectedIds.addAll(_paginatedData.map((item) => item['id']?.toString() ?? ''));
      } else {
        _selectedIds.removeAll(_paginatedData.map((item) => item['id']?.toString() ?? ''));
      }
      widget.onBulkAction(_selectedIds.toList());
    });
  }

  void _toggleSelection(String id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else {
        _selectedIds.add(id);
      }
      _selectAll = _selectedIds.length == _paginatedData.length;
      widget.onBulkAction(_selectedIds.toList());
    });
  }

  @override
  Widget build(BuildContext context) {
    final enhancedColumns = [
      DataColumn2(
        label: Checkbox(
          value: _selectAll,
          onChanged: _toggleSelectAll,
        ),
        size: ColumnSize.S,
      ),
      ...widget.columns,
    ];

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
        ],
      ),
      child: Column(
        children: [
          // Bulk action bar
          if (_selectedIds.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.05),
                border: Border(
                  bottom: BorderSide(color: Colors.grey.shade200),
                ),
              ),
              child: Row(
                children: [
                  Text(
                    '${_selectedIds.length} élément(s) sélectionné(s)',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: () {
                      setState(() {
                        _selectedIds.clear();
                        _selectAll = false;
                      });
                      widget.onBulkAction([]);
                    },
                    icon: const Icon(Icons.clear, size: 18),
                    label: const Text('Désélectionner'),
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
              columns: enhancedColumns,
              rows: _paginatedData.map((item) {
                final id = item['id']?.toString() ?? '';
                final isSelected = _selectedIds.contains(id);
                final originalRow = widget.buildRow(item, isSelected);
                // Add checkbox as first cell
                return DataRow2(
                  selected: isSelected,
                  onSelectChanged: (value) => _toggleSelection(id),
                  cells: [
                    DataCell(
                      Checkbox(
                        value: isSelected,
                        onChanged: (value) => _toggleSelection(id),
                      ),
                    ),
                    ...originalRow.cells,
                  ],
                );
              }).toList(),
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
                    'Affichage ${_currentPage * widget.rowsPerPage + 1}-${(_currentPage * widget.rowsPerPage + widget.rowsPerPage).clamp(0, widget.data.length)} sur ${widget.data.length}',
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

