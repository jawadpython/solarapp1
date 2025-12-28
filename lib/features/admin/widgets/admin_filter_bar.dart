import 'package:flutter/material.dart';
import 'package:noor_energy/core/constants/app_colors.dart';

class AdminFilterBar extends StatelessWidget {
  final TextEditingController searchController;
  final List<String> filterOptions;
  final String selectedFilter;
  final Function(String) onFilterChanged;
  final String searchHint;

  const AdminFilterBar({
    super.key,
    required this.searchController,
    required this.filterOptions,
    required this.selectedFilter,
    required this.onFilterChanged,
    this.searchHint = 'Rechercher...',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        children: [
          TextField(
            controller: searchController,
            decoration: InputDecoration(
              hintText: searchHint,
              prefixIcon: const Icon(Icons.search),
              suffixIcon: searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        searchController.clear();
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          if (filterOptions.isNotEmpty) ...[
            const SizedBox(height: 12),
            SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: filterOptions.length,
                itemBuilder: (context, index) {
                  final option = filterOptions[index];
                  final isSelected = option == selectedFilter;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(option),
                      selected: isSelected,
                      onSelected: (selected) {
                        onFilterChanged(option);
                      },
                      selectedColor: AppColors.primary.withOpacity(0.2),
                      checkmarkColor: AppColors.primary,
                    ),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }
}

