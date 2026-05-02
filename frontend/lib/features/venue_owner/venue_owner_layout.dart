import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_theme.dart';
import 'package:frontend/features/venue_owner/venue_owner_dashboard.dart';
import 'package:frontend/features/venue_owner/venues_list_screen.dart';
import 'package:frontend/features/venue_owner/venue_owner_bookings_screen.dart';

class VenueOwnerLayout extends StatefulWidget {
  final int initialIndex;

  const VenueOwnerLayout({super.key, this.initialIndex = 0});

  @override
  State<VenueOwnerLayout> createState() => VenueOwnerLayoutState();
}

class VenueOwnerLayoutState extends State<VenueOwnerLayout> {
  void navigateToTab(int index) {
    if (index == _selectedIndex) return;
    _onNavTap(index);
  }

  int get selectedIndex => _selectedIndex;

  late final PageController _pageController;
  int _selectedIndex = 0;

  final _venuesListKey = GlobalKey<VenuesListScreenState>();

  late final List<Widget> _screens = [
    const VenueOwnerDashboard(),
    VenuesListScreen(key: _venuesListKey),
    const VenueOwnerBookingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _selectedIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onNavTap(int index) {
    if (index == _selectedIndex) return;
    setState(() => _selectedIndex = index);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
  }

  void _onPageChanged(int index) {
    if (_selectedIndex == index) return;
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        children: _screens,
      ),
      bottomNavigationBar: ClipPath(
        clipper: _NavBarClipper(),
        child: Container(
          margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          decoration: BoxDecoration(
            color: AppTheme.surfaceContainerLow.withValues(alpha: 0.94),
            border: Border.all(color: AppTheme.primary.withValues(alpha: 0.2)),
          ),
          child: BottomNavigationBar(
            currentIndex: _selectedIndex,
            type: BottomNavigationBarType.fixed,
            enableFeedback: false,
            backgroundColor: Colors.transparent,
            onTap: _onNavTap,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.dashboard_outlined),
                activeIcon: Icon(Icons.dashboard),
                label: 'Dashboard',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.business_outlined),
                activeIcon: Icon(Icons.business),
                label: 'Venues',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.event_note_outlined),
                activeIcon: Icon(Icons.event_note),
                label: 'Bookings',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavBarClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    const pointSize = 15.0;

    path.moveTo(pointSize, 0);
    path.lineTo(size.width - pointSize, 0);
    path.lineTo(size.width, size.height / 2);
    path.lineTo(size.width - pointSize, size.height);
    path.lineTo(pointSize, size.height);
    path.lineTo(0, size.height / 2);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
