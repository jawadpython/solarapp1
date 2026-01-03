import 'package:flutter/material.dart';
import 'package:noor_energy/core/constants/app_colors.dart';
import 'package:noor_energy/features/calculator/models/solar_result.dart';
import 'package:noor_energy/features/calculator/screens/devis_request_screen.dart';
import 'package:noor_energy/features/marketplace/models/product_model.dart';

class ProductDetailsScreen extends StatelessWidget {
  final ProductModel product;

  const ProductDetailsScreen({
    super.key,
    required this.product,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: CustomScrollView(
        slivers: [
          // App Bar with back button
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: Colors.white,
            foregroundColor: AppColors.textPrimary,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              background: _ProductImageHeader(product: product),
            ),
          ),
          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title Section
                  _TitleSection(product: product),
                  const SizedBox(height: 24),
                  // Warranty Badge
                  _WarrantyBadge(warranty: product.warranty),
                  const SizedBox(height: 24),
                  // Specs Section
                  _SpecsSection(product: product),
                  const SizedBox(height: 24),
                  // Description Card
                  if (product.descriptionShort.isNotEmpty)
                    _DescriptionCard(description: product.descriptionShort),
                  if (product.descriptionShort.isNotEmpty)
                    const SizedBox(height: 24),
                  // CTA Button
                  _CTAButton(
                    product: product,
                    onTap: () => _navigateToDevisRequest(context),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToDevisRequest(BuildContext context) {
    // Create a minimal SolarResult with product data
    final solarResult = SolarResult(
      kwhMonth: 0, // Default value
      powerKW: product.powerKw,
      panels: 0, // Default value
      savingRate: 0, // Default value
      savingMonth: 0, // Default value
      savingYear: 0, // Default value
      saving10Y: 0, // Default value
      saving20Y: 0, // Default value
      usedSunH: 0, // Default value
      monthName: '', // Default value
      regionCode: '', // Default value
    );

    // Determine system type from product type
    String systemType = 'Hybride'; // Default
    if (product.type.toLowerCase().contains('on-grid') ||
        product.type.toLowerCase().contains('ongrid')) {
      systemType = 'On-grid';
    } else if (product.type.toLowerCase().contains('off-grid') ||
        product.type.toLowerCase().contains('offgrid')) {
      systemType = 'Off-grid';
    } else if (product.type.toLowerCase().contains('hybrid')) {
      systemType = 'Hybride';
    }

    // Create product description for note field
    final productDescription =
        'Produit: ${product.model}\nMarque: ${product.brand}\nCatégorie: ${product.category}';

    // Navigate to DevisRequestScreen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DevisRequestScreen(
          result: solarResult,
          systemType: systemType,
          initialNote: productDescription,
        ),
      ),
    );
  }
}

/// Product image header with placeholder
class _ProductImageHeader extends StatelessWidget {
  final ProductModel product;

  const _ProductImageHeader({required this.product});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 300,
      color: Colors.grey.shade100,
      child: product.imageUrl != null && product.imageUrl!.isNotEmpty
          ? Image.network(
              product.imageUrl!,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return const _ImagePlaceholder();
              },
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                  ),
                );
              },
            )
          : const _ImagePlaceholder(),
    );
  }
}

/// Image placeholder widget
class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.grey.shade100,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.image_outlined,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 12),
          Text(
            'Image non disponible',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }
}

/// Title section with model, brand, and category
class _TitleSection extends StatelessWidget {
  final ProductModel product;

  const _TitleSection({required this.product});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Model (Title)
        Text(
          product.model,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        // Brand + Category (Subtitle)
        Row(
          children: [
            Icon(
              Icons.business,
              size: 18,
              color: Colors.grey.shade600,
            ),
            const SizedBox(width: 6),
            Text(
              product.brand,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(width: 12),
            Container(
              width: 4,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade400,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              product.category,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Warranty badge
class _WarrantyBadge extends StatelessWidget {
  final String warranty;

  const _WarrantyBadge({required this.warranty});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.success.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.success.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.verified,
            size: 20,
            color: AppColors.success,
          ),
          const SizedBox(width: 8),
          Text(
            'Garantie: $warranty',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.success,
            ),
          ),
        ],
      ),
    );
  }
}

/// Specifications section with bullet list
class _SpecsSection extends StatelessWidget {
  final ProductModel product;

  const _SpecsSection({required this.product});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: AppColors.primary,
                size: 24,
              ),
              const SizedBox(width: 8),
              const Text(
                'Spécifications',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _SpecItem(
            icon: Icons.flash_on,
            label: 'Puissance',
            value: '${product.powerKw.toStringAsFixed(1)} kW',
          ),
          const SizedBox(height: 16),
          _SpecItem(
            icon: Icons.category,
            label: 'Type',
            value: product.type,
          ),
          const SizedBox(height: 16),
          _SpecItem(
            icon: Icons.waves,
            label: 'Phase',
            value: product.phase,
          ),
          const SizedBox(height: 16),
          _SpecItem(
            icon: Icons.battery_charging_full,
            label: 'Tension',
            value: product.voltage,
          ),
          const SizedBox(height: 16),
          _SpecItem(
            icon: Icons.battery_std,
            label: 'Type de batterie',
            value: product.batteryType,
          ),
          const SizedBox(height: 16),
          _SpecItem(
            icon: Icons.home,
            label: 'Adapté pour',
            value: product.suitableFor,
          ),
          if (product.maxPvKw > 0) ...[
            const SizedBox(height: 16),
            _SpecItem(
              icon: Icons.solar_power,
              label: 'PV Max',
              value: '${product.maxPvKw.toStringAsFixed(1)} kW',
            ),
          ],
          if (product.mppt > 0) ...[
            const SizedBox(height: 16),
            _SpecItem(
              icon: Icons.tune,
              label: 'MPPT',
              value: '${product.mppt}',
            ),
          ],
        ],
      ),
    );
  }
}

/// Individual spec item
class _SpecItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _SpecItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: AppColors.primary,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey.shade700,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

/// Description card
class _DescriptionCard extends StatelessWidget {
  final String description;

  const _DescriptionCard({required this.description});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.description_outlined,
                color: AppColors.primary,
                size: 24,
              ),
              const SizedBox(width: 8),
              const Text(
                'Description',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            description,
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey.shade700,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}

/// CTA Button
class _CTAButton extends StatelessWidget {
  final ProductModel product;
  final VoidCallback onTap;

  const _CTAButton({
    required this.product,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: const Icon(Icons.request_quote, size: 24),
        label: const Text(
          'Demander un devis pour ce produit',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
      ),
    );
  }
}

