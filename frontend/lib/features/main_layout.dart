import 'package:flutter/material.dart';
import 'package:frontend/core/api/api_models.dart';
import 'package:frontend/core/app_controller.dart';
import 'package:frontend/core/theme/app_theme.dart';
import 'package:frontend/core/utils/app_feedback.dart';
import 'package:frontend/features/booking/bookings_screen.dart';
import 'package:frontend/features/booking/models/booked_facility_details.dart';
import 'package:frontend/features/home/home_screen.dart';
import 'package:frontend/features/search/search_screen.dart';

class MainLayout extends StatefulWidget {
  final int initialIndex;

  const MainLayout({super.key, this.initialIndex = 0});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  late int _selectedIndex;
  late final PageController _pageController;
  bool _isLoading = true;
  List<FacilityDto> _facilities = const [];
  List<BookedFacilityDetails> _bookings = const [];
  bool _didLoadInitialData = false;

  BookedFacilityDetails? get _latestBooking =>
      _bookings.isEmpty ? null : _bookings.first;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _selectedIndex);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didLoadInitialData) {
      return;
    }
    _didLoadInitialData = true;
    _refreshData();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _refreshData() async {
    final controller = AppScope.of(context);
    final session = controller.session;

    setState(() => _isLoading = true);

    try {
      final facilities = await controller.apiClient.listFacilities();
      final bookings = session == null
          ? const <BookingDto>[]
          : await controller.apiClient.listBookings(token: session.token);

      if (!mounted) {
        return;
      }

      setState(() {
        _facilities = facilities;
        _bookings = bookings
            .map((booking) => _toBookedDetails(booking, facilities))
            .toList(growable: false);
        _isLoading = false;
      });
    } on ApiException catch (error) {
      if (!mounted) {
        return;
      }

      setState(() => _isLoading = false);
      AppFeedback.pulseMessage(
        context,
        message: error.message,
        icon: Icons.error_outline,
      );
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() => _isLoading = false);
      AppFeedback.pulseMessage(
        context,
        message: 'Could not load live app data.',
        icon: Icons.error_outline,
      );
    }
  }

  BookedFacilityDetails _toBookedDetails(
    BookingDto booking,
    List<FacilityDto> facilities,
  ) {
    final facility = facilities.cast<FacilityDto?>().firstWhere(
      (item) => item?.id == booking.facilityId,
      orElse: () => null,
    );

    return BookedFacilityDetails(
      facilityName: facility?.name ?? 'Facility #${booking.facilityId}',
      facilityType: facility == null
          ? 'Unknown facility'
          : '${facility.sport} • ${facility.type}',
      facilitySummary: facility?.openSummary ?? 'Live booking from backend',
      startTime: booking.startTime.toLocal(),
      endTime: booking.endTime.toLocal(),
      durationMinutes: booking.endTime.difference(booking.startTime).inMinutes,
      bookingId: booking.id.toString(),
      status: booking.status,
    );
  }

  Future<void> _handleBookingUpdated(BookedFacilityDetails _) async {
    await _refreshData();
    if (!mounted) {
      return;
    }

    setState(() {
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
      message: 'Booking saved and reloaded from backend.',
      icon: Icons.bookmark_added_outlined,
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
        facilities: _facilities,
        isLoading: _isLoading,
        latestBooking: _latestBooking,
        onBookingUpdated: _handleBookingUpdated,
      ),
      SearchScreen(
        facilities: _facilities,
        isLoading: _isLoading,
        onBookingUpdated: _handleBookingUpdated,
      ),
      BookingsScreen(bookings: _bookings),
    ];

    return Scaffold(
      extendBody: true,
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppTheme.surfaceContainerLow, Color(0xFF18120E)],
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
                    color: AppTheme.primary.withValues(alpha: 0.07),
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
            color: AppTheme.surfaceContainerLow.withValues(alpha: 0.94),
            border: Border.all(color: AppTheme.primary.withValues(alpha: 0.2)),
          ),
          child: BottomNavigationBar(
            currentIndex: _selectedIndex,
            type: BottomNavigationBarType.fixed,
            enableFeedback: false,
            backgroundColor: Colors.transparent,
            onTap: _handleNavTap,
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
              BottomNavigationBarItem(
                icon: Icon(Icons.search),
                label: 'Search',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.bookmark_outline),
                activeIcon: Icon(Icons.bookmark),
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
