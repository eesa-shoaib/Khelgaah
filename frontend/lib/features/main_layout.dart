import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_theme.dart';
import 'package:frontend/core/utils/app_feedback.dart';
import 'package:frontend/features/booking/bookings_screen.dart';
import 'package:frontend/features/booking/models/booked_facility_details.dart';
import 'home/home_screen.dart';
import 'search/search_screen.dart';

class MainLayout extends StatefulWidget {
  final int initialIndex;

  const MainLayout({super.key, this.initialIndex = 0});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  late int _selectedIndex;
  late final PageController _pageController;
  BookedFacilityDetails? _latestBooking;

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

  void _handleBookingUpdated(BookedFacilityDetails details) {
    setState(() {
      _latestBooking = details;
      _selectedIndex = 2;
    });

    _pageController.animateToPage(
      2,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
    AppFeedback.haptic(AppFeedbackType.success);
    AppFeedback.pulseMessage(
      context,
      message: 'Booking moved to your Bookings tab.',
      icon: Icons.bookmark_added_outlined,
    );
  }

  void _handleBookingPayment() {
    if (_latestBooking == null) {
      return;
    }

    setState(() {
      _latestBooking = _latestBooking!.copyWith(isPaid: true);
    });

    AppFeedback.haptic(AppFeedbackType.success);
    AppFeedback.pulseMessage(
      context,
      message: 'Payment status updated.',
      icon: Icons.verified_outlined,
    );
  }

  void _handleNavTap(int index) {
    if (index == _selectedIndex) {
      return;
    }

    AppFeedback.haptic(AppFeedbackType.selection);
    setState(() {
      _selectedIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
  }

  void _handlePageChanged(int index) {
    if (_selectedIndex == index) {
      return;
    }

    setState(() {
      _selectedIndex = index;
    });
    AppFeedback.haptic(AppFeedbackType.selection);
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      HomeScreen(
        latestBooking: _latestBooking,
        onBookingUpdated: _handleBookingUpdated,
      ),
      SearchScreen(onBookingUpdated: _handleBookingUpdated),
      BookingsScreen(
        latestBooking: _latestBooking,
        onPayNow: _latestBooking == null ? null : _handleBookingPayment,
      ),
    ];

    return Scaffold(
      extendBody: true,
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppTheme.background, Color(0xFF18120E)],
          ),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Positioned(
              top: -120,
              right: -80,
              child: IgnorePointer(
                child: Container(
                  width: 240,
                  height: 240,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.orangePrimary.withValues(alpha: 0.07),
                  ),
                ),
              ),
            ),
            PageView(
              controller: _pageController,
              onPageChanged: _handlePageChanged,
              children: screens,
            ),
          ],
        ),
      ),
      bottomNavigationBar: ClipPath(
        clipper: _NavBarClipper(),
        child: Container(
          margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          decoration: BoxDecoration(
            color: AppTheme.surface.withValues(alpha: 0.94),
            border: Border.all(
              color: AppTheme.orangePrimary.withValues(alpha: 0.2),
            ),
          ),
          child: BottomNavigationBar(
            currentIndex: _selectedIndex,
            type: BottomNavigationBarType.fixed,
            enableFeedback: false,
            backgroundColor: Colors.transparent,
            onTap: _handleNavTap,
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
              BottomNavigationBarItem(
                icon: Icon(Icons.search),
                label: "Search",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.bookmark_outline),
                activeIcon: Icon(Icons.bookmark),
                label: "Bookings",
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Clipper for pointed left and right boundaries on navigation bar
class _NavBarClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    const pointSize = 15.0; // Adjust this to make points bigger/smaller

    // Start from top-left after the point
    path.moveTo(pointSize, 0);

    // Top line to top-right
    path.lineTo(size.width - pointSize, 0);

    // Right point
    path.lineTo(size.width, size.height / 2);

    // Bottom-right to bottom-left
    path.lineTo(size.width - pointSize, size.height);
    path.lineTo(pointSize, size.height);

    // Left point
    path.lineTo(0, size.height / 2);

    // Close the path
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
