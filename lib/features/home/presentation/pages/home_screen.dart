// ============================================================================
// IMPORTS - Import necessary packages and files
// ============================================================================
import 'package:flutter/material.dart';
import 'package:noor_energy/core/constants/app_colors.dart'; // App color constants
import 'package:noor_energy/core/services/language_service.dart'; // Language switching
import 'package:noor_energy/features/profile/screens/profile_screen.dart'; // Profile screen
import 'package:noor_energy/features/home/widgets/home_devis_form_dialog.dart'; // Home devis form dialog
import 'package:noor_energy/features/marketplace/screens/marketplace_screen.dart'; // Marketplace screen
import 'package:noor_energy/routes/app_routes.dart'; // Navigation routes
import 'package:noor_energy/l10n/app_localizations.dart'; // Localizations

// ============================================================================
// HOMESCREEN WIDGET - Main screen widget (StatefulWidget = can change state)
// ============================================================================
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  // This method creates the state for this widget
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

// ============================================================================
// HOMESCREEN STATE - Manages the state and UI of the home screen
// ============================================================================
class _HomeScreenState extends State<HomeScreen> {
  // Track which bottom navigation item is selected (0 = Home, 1 = Espace Pro, etc.)
  int _currentIndex = 0;


  // ==========================================================================
  // HELPER METHOD: Show bottom menu sheet
  // ==========================================================================
  /// This method displays a bottom sheet menu when user taps the menu icon
  /// Bottom sheet slides up from bottom of screen
  void _showMenu(BuildContext context) {
    // showModalBottomSheet creates a modal bottom sheet (popup from bottom)
    showModalBottomSheet(
      context: context, // Required: tells Flutter which screen to show this on
      // Shape: rounds the top corners of the bottom sheet
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      // Builder: creates the content inside the bottom sheet
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20), // Space inside container
        child: Column(
          mainAxisSize: MainAxisSize.min, // Column takes minimum space needed
          children: [
            // ListTile: creates a menu item with icon and text
            ListTile(
              leading: const Icon(Icons.person_outline), // Icon on left
              title: Text(AppLocalizations.of(context)!.profile), // Menu text
              onTap: () {
                // When tapped: close bottom sheet, then navigate to profile
                Navigator.pop(context); // Close bottom sheet
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProfileScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================================
  // BUILD METHOD: Creates the UI for this screen
  // ==========================================================================
  /// This is the main method that builds the entire home screen UI
  /// It's called automatically by Flutter whenever the screen needs to be displayed
  @override
  Widget build(BuildContext context) {
    // Scaffold: The main structure of the screen (like a page frame)
    return Scaffold(
      backgroundColor: Colors.grey.shade50, // Light grey background color
      
      // ======================================================================
      // APPBAR - Top bar with brand logo, title, and action buttons
      // ======================================================================
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        leadingWidth: 0,
        titleSpacing: 0,
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              /// TEXT + SLOGAN - Clean design without icon
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.appTitle.toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                        color: Colors.black,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      AppLocalizations.of(context)!.slogan,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.notifications_none, color: Colors.grey.shade700),
            tooltip: 'Notifications',
          ),
          IconButton(
            onPressed: () {
              _showMenu(context);
            },
            icon: Icon(Icons.menu, color: Colors.grey.shade700),
            tooltip: 'Menu',
          ),
          const SizedBox(width: 8),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: Colors.grey.shade200,
          ),
        ),
      ),
      
      // ======================================================================
      // BODY - Main content area (scrollable)
      // ======================================================================
      body: SingleChildScrollView(
        // Column: Arranges widgets vertically (top to bottom)
        child: Column(
          mainAxisSize: MainAxisSize.min, // Column takes minimum space needed
          children: [
            // ==================================================================
            // BANNER SECTION with CTA Button
            // ==================================================================
            // Spacing after AppBar for clean layout
            const SizedBox(height: 26),
            // Container: Wrapper with margins (space around the banner)
            Container(
              // Margin: Space outside the container (horizontal = left/right, vertical = top/bottom)
              margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 0),
              // Stack: Allows widgets to overlap (banner image + button on top)
              child: Stack(
                children: [
                  // ============================================================
                  // BANNER IMAGE - Background image
                  // ============================================================
                  // ClipRRect: Clips the image to rounded corners
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12), // Rounded corners (16px radius)
                    child: SizedBox(
                      width: double.infinity, // Full width of screen
                      height: 160, // Height in pixels (change this to make banner taller/shorter)
                      child: Image.asset(
                        'assets/images/banner_solar.png', // Image file path
                        fit: BoxFit.cover, // How image fills the space (cover = fills entire area)
                      ),
                    ),
                  ),
                  // ============================================================
                  // GRADIENT OVERLAY - Dark overlay at bottom for better text readability
                  // ============================================================
                  // Positioned.fill: Fills the entire Stack area
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.transparent,
                            Colors.black.withOpacity(0.3),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // ============================================================
                  // CTA BUTTON - "Demander une étude gratuite" button
                  // ============================================================
                  // Positioned: Places button at specific location in Stack
                  Positioned(
                    bottom: 0, // 16 pixels from bottom of banner
                    left: 0,    // 1 pixel from left edge (change to move left/right)
                    // Container: Creates the button with styling
                    child: Container(
                      // BoxDecoration: Styles the container (color, border, shadow)
                      decoration: BoxDecoration(
                        color: AppColors.primary, // Button background color
                        borderRadius: BorderRadius.circular(12), // Rounded corners (change 12 to make more/less rounded)
                        // boxShadow: Creates shadow effect
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.4), // Shadow color (40% opacity)
                            blurRadius: 8, // How blurry the shadow is (higher = more blur)
                            offset: const Offset(0, 2), // Shadow position (x, y) - moves shadow down
                          ),
                        ],
                      ),
                      // Material: Provides touch feedback (ripple effect)
                      child: Material(
                        color: Colors.transparent, // Transparent so decoration shows through
                        child: InkWell(
                          // onTap: What happens when button is tapped
                          onTap: () {
                            // Show devis request form dialog
                            showDialog(
                              context: context,
                              builder: (context) => const HomeDevisFormDialog(),
                            );
                          },
                          borderRadius: BorderRadius.circular(12), // Ripple effect shape
                          // Container: Inner container with padding for text
                          child: Container(
                            // Padding: Space inside button (vertical = top/bottom, horizontal = left/right)
                            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                            child: Text(
                              AppLocalizations.of(context)!.requestFreeStudy, // Button text
                              style: TextStyle(
                                fontSize: 15, // Text size (change to make bigger/smaller)
                                fontWeight: FontWeight.w600, // Text weight (w600 = semi-bold)
                                letterSpacing: 0.1, // Space between letters
                                color: Colors.white, // Text color
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // ==================================================================
            // SERVICES SECTION - Title and subtitle
            // ==================================================================
            // Padding: Adds space around the section title
            Padding(
              // EdgeInsets.only: Specify padding for specific sides only
              padding: const EdgeInsets.only(left: 16, right: 16, top: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start, // Align children to left
                children: [
                  // Main section title
                  Text(
                    AppLocalizations.of(context)!.ourServices, // Section title text
                    style: const TextStyle(
                      fontSize: 20, // Large text size
                      fontWeight: FontWeight.bold, // Bold text
                      color: AppColors.textPrimary, // Dark text color
                    ),
                  ),
                  const SizedBox(height: 5), // Small space between title and subtitle
                  // Subtitle text
                  Text(
                    AppLocalizations.of(context)!.servicesSubtitle,
                    style: TextStyle(
                      fontSize: 14, // Smaller than title
                      color: Colors.grey.shade600, // Grey color
                      fontWeight: FontWeight.w400, // Normal weight
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14), // Space between title section and cards
            // ==================================================================
            // SERVICES GRID LAYOUT - Custom 2-1-2 pattern
            // ==================================================================
            // Layout structure:
            // Row 1: [Étude & Devis] [Installation]
            // Center: [Calculateur Solaire] (big button)
            // Row 2: [Maintenance] [Techniciens]
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16), // Left and right padding
              child: Column(
                children: [
                  // ============================================================
                  // TOP ROW - Two service cards side by side
                  // ============================================================
                  // Row: Arranges widgets horizontally (left to right)
                  Row(
                    children: [
                      // Expanded: Makes widget take equal available space
                      Expanded(
                        child: _FeatureCard(
                          icon: Icons.assessment_outlined, // Icon for this service
                          title: AppLocalizations.of(context)!.studyQuote, // Title (\n = new line)
                          description: AppLocalizations.of(context)!.studyQuoteDescription,
                          color: const Color(0xFF2196F3), // Blue color (hex: 0xFFRRGGBB)
                          onTap: () {
                            // Navigate to Étude Devis screen when tapped
                            Navigator.pushNamed(context, AppRoutes.etudeDevis);
                          },
                        ),
                      ),
                      const SizedBox(width: 16), // Space between cards (16 pixels)
                      Expanded(
                        child: _FeatureCard(
                          icon: Icons.solar_power_outlined,
                          title: AppLocalizations.of(context)!.installation,
                          description: AppLocalizations.of(context)!.installationDescription,
                          color: const Color(0xFFFF9800), // Orange color
                          onTap: () {
                            Navigator.pushNamed(context, AppRoutes.installationRequest);
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12), // Space between rows
                  // ============================================================
                  // CENTER - Primary Calculator Card (bigger, prominent)
                  // ============================================================
                  // This is the main CTA button - larger and more prominent
                  _PrimaryCalculatorCard(
                    icon: Icons.calculate_rounded, // Calculator icon
                    title: AppLocalizations.of(context)!.solarCalculator, // Title
                    description: AppLocalizations.of(context)!.solarCalculatorDescription,
                    onTap: () {
                      // Navigate to calculator screen with error handling
                      try {
                        Navigator.pushNamed(context, AppRoutes.calulatorInput);
                      } catch (e) {
                        // Show error if navigation fails
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Erreur: Impossible d\'ouvrir le calculateur. $e'),
                            backgroundColor: Colors.red,
                            duration: const Duration(seconds: 3),
                          ),
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 12), // Space between center card and bottom row
                  // ============================================================
                  // BOTTOM ROW - Two service cards side by side
                  // ============================================================
                  Row(
                    children: [
                      Expanded(
                        child: _FeatureCard(
                          icon: Icons.build_outlined,
                          title: AppLocalizations.of(context)!.maintenanceRepair,
                          description: AppLocalizations.of(context)!.maintenanceRepairDescription,
                          color: const Color(0xFF4CAF50),
                          onTap: () {
                            Navigator.pushNamed(context, AppRoutes.maintenanceRequest);
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _FeatureCard(
                          icon: Icons.search,
                          title: AppLocalizations.of(context)!.searchCompaniesOrTechnicians,
                          description: AppLocalizations.of(context)!.searchCompaniesOrTechniciansDescription,
                          color: const Color(0xFF9C27B0),
                          onTap: () {
                            Navigator.pushNamed(context, AppRoutes.searchChoice);
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16), // Space after services section
            // ==================================================================
            // ESPACE PRO HELPER TEXT - Information text about professional space
            // ==================================================================
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6), // Padding inside container
              color: Colors.white, // White background
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center, // Center content horizontally
                children: [
                  Icon(Icons.info_outline, size: 14, color: Colors.grey.shade500), // Info icon
                  const SizedBox(width: 6), // Small space between icon and text
                  Flexible(
                    // Flexible: Allows text to wrap if too long
                    child: Text(
                      AppLocalizations.of(context)!.proSpaceInfo,
                      textAlign: TextAlign.center, // Center text
                      style: TextStyle(
                        fontSize: 11, // Small text size
                        color: Colors.grey.shade600, // Grey color
                        fontStyle: FontStyle.italic, // Italic style
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4), // Small space at bottom
          ],
        ),
      ),
      // ======================================================================
      // BOTTOM NAVIGATION BAR - Bottom menu with icons
      // ======================================================================
      bottomNavigationBar: Container(
        // BoxDecoration: Styles the bottom navigation container
        decoration: BoxDecoration(
          color: Colors.white, // White background
          boxShadow: [
            // Shadow above the bar (negative offset moves shadow up)
            BoxShadow(
              color: Colors.black.withOpacity(0.05), // Very light shadow (5% opacity)
              blurRadius: 10, // Blur amount
              offset: const Offset(0, -5), // Shadow position (x=0, y=-5 moves up)
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex, // Which tab is currently selected
          // onTap: Called when user taps a navigation item
          onTap: (index) {
            if (index == 0) {
              // Home - already on home, just update index
              setState(() => _currentIndex = index);
            } else if (index == 1) {
              // Espace Pro navigation - navigate to screen
              Navigator.pushNamed(context, AppRoutes.espacePro);
              // Don't update currentIndex since we're navigating away
            } else if (index == 2) {
              // Chat - not implemented yet, show coming soon message
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(AppLocalizations.of(context)!.chatComingSoon),
                  duration: const Duration(seconds: 2),
                ),
              );
              // Don't update index, stay on home
            } else if (index == 3) {
              // Boutique - navigate to MarketplaceScreen
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MarketplaceScreen()),
              );
              // Don't update currentIndex since we're navigating away
            } else if (index == 4) {
              // Profile navigation
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              );
            }
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: Colors.grey.shade500,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
          unselectedLabelStyle: const TextStyle(fontSize: 12),
          elevation: 0,
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.home_outlined),
              activeIcon: const Icon(Icons.home),
              label: AppLocalizations.of(context)!.home,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.business_outlined),
              activeIcon: const Icon(Icons.business),
              label: AppLocalizations.of(context)!.proSpace,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.chat_bubble_outline),
              activeIcon: const Icon(Icons.chat_bubble),
              label: AppLocalizations.of(context)!.chat,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.shopping_bag_outlined),
              activeIcon: const Icon(Icons.shopping_bag),
              label: AppLocalizations.of(context)!.shop,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.person_outline),
              activeIcon: const Icon(Icons.person),
              label: AppLocalizations.of(context)!.profile,
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// FEATURE CARD WIDGET - Reusable card for service items
// ============================================================================
/// This widget creates a service card with icon, title, and description
/// Used for: Étude & Devis, Installation, Maintenance, Techniciens
class _FeatureCard extends StatelessWidget {
  // Properties: Data this widget needs to display
  final IconData icon;        // Icon to display
  final String title;         // Card title text
  final String description;   // Description text below title
  final Color color;          // Color theme for icon background
  final VoidCallback onTap;   // Function to call when card is tapped

  // Constructor: Creates the widget with required properties
  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
    required this.onTap,
  });

  // Build method: Creates the UI for this card
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white, // White card background
      borderRadius: BorderRadius.circular(20), // Rounded corners
      elevation: 2, // Shadow depth (makes card appear raised)
      shadowColor: Colors.black.withOpacity(0.1), // Shadow color (10% opacity)
      // InkWell: Provides tap feedback (ripple effect)
      child: InkWell(
        onTap: onTap, // Call the onTap function when tapped
        borderRadius: BorderRadius.circular(20), // Ripple effect shape
        child: Container(
          height: 170, // Increased height to accommodate text better
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14), // Adjusted padding
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20), // Match Material border radius
            border: Border.all(color: Colors.grey.shade100), // Light grey border
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center, // Center content vertically
            mainAxisSize: MainAxisSize.max, // Use maximum space available
            children: [
              // Icon container with colored background
              Container(
                padding: const EdgeInsets.all(10), // Slightly reduced padding
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1), // Light version of card color (10% opacity)
                  borderRadius: BorderRadius.circular(16), // Rounded icon background
                ),
                child: Icon(icon, size: 26, color: color), // Slightly smaller icon
              ),
              const SizedBox(height: 8), // Space between icon and title
              // Title text
              Flexible(
                // Flexible: Allows text to shrink if needed but can expand
                child: Text(
                  title,
                  textAlign: TextAlign.center, // Center the text
                  maxLines: 2, // Maximum 2 lines
                  overflow: TextOverflow.ellipsis, // Show "..." if text too long
                  style: const TextStyle(
                    fontSize: 13, // Slightly smaller to fit better
                    fontWeight: FontWeight.w600, // Semi-bold
                    color: AppColors.textPrimary, // Dark text color
                    height: 1.3, // Increased line height for better readability
                  ),
                ),
              ),
              // Description text (only show if not empty)
              if (description.isNotEmpty) ...[
                const SizedBox(height: 5), // Space between title and description
                Flexible(
                  child: Text(
                    description,
                    textAlign: TextAlign.center,
                    maxLines: 2, // Maximum 2 lines
                    overflow: TextOverflow.ellipsis, // Show "..." if text too long
                    style: TextStyle(
                      fontSize: 11, // Smaller than title
                      fontWeight: FontWeight.w400, // Normal weight
                      color: Colors.grey.shade600, // Grey color
                      height: 1.4, // Increased line spacing for better readability
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// TECHNICIAN CARD - Special card with professional technician visual
// ============================================================================
/// This widget creates a professional technician card with a custom visual
/// representing a solar technician with helmet and tools
class _TechnicianCard extends StatelessWidget {
  final String title;
  final String description;
  final VoidCallback onTap;

  const _TechnicianCard({
    required this.title,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.1),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey.shade100),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Professional technician visual - Custom container with professional design
              Container(
                width: 64,
                height: 64,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  // Purple gradient background (matching original color theme)
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFF673AB7).withOpacity(0.12), // Light purple
                      const Color(0xFF673AB7).withOpacity(0.20), // Slightly darker purple
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16), // Rounded square (professional look)
                  // Soft shadow for depth and premium feel
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF673AB7).withOpacity(0.25),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Main technician icon - Engineering icon represents professional technician
                    // This icon shows a person with hard hat and tools (professional look)
                    Icon(
                      Icons.engineering,
                      size: 36,
                      color: const Color(0xFF673AB7),
                    ),
                    // Small certification badge overlay (represents certified technician)
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Container(
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.verified,
                          size: 12,
                          color: const Color(0xFF673AB7),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              // Title text
              Flexible(
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                    height: 1.2,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              // Description text
              Flexible(
                child: Text(
                  description,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                    color: Colors.grey.shade600,
                    height: 1.3,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// PRIMARY CALCULATOR CARD - Large, prominent button for main action
// ============================================================================
/// This widget creates a large, prominent card for the Solar Calculator
/// It's bigger than regular cards and uses primary color with gradient
/// This is the main CTA (Call To Action) on the home screen
class _PrimaryCalculatorCard extends StatelessWidget {
  // Properties needed for this card
  final IconData icon;        // Calculator icon
  final String title;         // "Calculateur Solaire"
  final String description;   // Description text
  final VoidCallback onTap;  // Function to call when tapped

  // Constructor
  const _PrimaryCalculatorCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primary, // Primary yellow/gold color
      borderRadius: BorderRadius.circular(22), // More rounded than regular cards
      elevation: 6, // Higher elevation = more shadow (more prominent)
      shadowColor: AppColors.primary.withOpacity(0.4), // Shadow with primary color
      child: InkWell(
        onTap: onTap, // Navigate to calculator when tapped
        borderRadius: BorderRadius.circular(22),
        child: Container(
          // Larger padding than regular cards (24px vs 16px)
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            // Gradient: Smooth color transition from primary to primaryDark
            gradient: LinearGradient(
              begin: Alignment.topLeft,    // Gradient starts top-left
              end: Alignment.bottomRight,  // Gradient ends bottom-right
              colors: [
                AppColors.primary,      // Lighter yellow (top-left)
                AppColors.primaryDark,   // Darker yellow (bottom-right)
              ],
            ),
            // Additional shadow for depth
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.3), // 30% opacity shadow
                blurRadius: 12, // More blur than regular cards
                offset: const Offset(0, 4), // Shadow offset (moves shadow down)
              ),
            ],
          ),
          // Row: Arranges icon, text, and arrow horizontally
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center, // Center content
            children: [
              // Icon container with semi-transparent white background
              Container(
                padding: const EdgeInsets.all(16), // Space around icon
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2), // 20% white (semi-transparent)
                  borderRadius: BorderRadius.circular(16), // Rounded icon background
                ),
                child: Icon(
                  icon,
                  size: 42, // Larger icon than regular cards (42 vs 28)
                  color: Colors.white, // White icon
                ),
              ),
              const SizedBox(width: 18), // Space between icon and text
              // Text content (title + description)
              Expanded(
                // Expanded: Takes remaining space
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start, // Align text to start (RTL-aware)
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Title text
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 22, // Larger than regular cards (22 vs 14)
                        fontWeight: FontWeight.bold, // Bold text
                        color: Colors.white, // White text
                        letterSpacing: 0.3, // Space between letters
                      ),
                    ),
                    const SizedBox(height: 6), // Small space between title and description
                    // Description text
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w400, // Normal weight
                        color: Colors.white.withOpacity(0.9), // 90% white (slightly transparent)
                        height: 1.3, // Line height
                      ),
                    ),
                  ],
                ),
              ),
              // Arrow icon indicating this is clickable (RTL-aware)
              Icon(
                Directionality.of(context) == TextDirection.rtl
                    ? Icons.arrow_back_ios
                    : Icons.arrow_forward_ios,
                color: Colors.white,
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PartnerTechnicianCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _PartnerTechnicianCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.1),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey.shade100),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, size: 28, color: color),
              ),
              const SizedBox(height: 10),
              Flexible(
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                    height: 1.2,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Flexible(
                child: Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w400,
                    color: Colors.grey.shade600,
                    height: 1.2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

