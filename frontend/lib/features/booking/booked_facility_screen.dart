import 'package:flutter/material.dart';
import 'package:frontend/core/widgets/app_widgets.dart';
import 'package:frontend/features/booking/models/booked_facility_details.dart';
import 'package:frontend/features/booking/widgets/booked_facility_details_view.dart';

class BookedFacilityScreen extends StatefulWidget {
  final BookedFacilityDetails details;

  const BookedFacilityScreen({super.key, required this.details});

  @override
  State<BookedFacilityScreen> createState() => _BookedFacilityScreenState();
}

class _BookedFacilityScreenState extends State<BookedFacilityScreen> {
  late BookedFacilityDetails _details;

  @override
  void initState() {
    super.initState();
    _details = widget.details;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope<BookedFacilityDetails>(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) {
          return;
        }

        Navigator.of(context).pop(_details);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(_details.facilityName),
          actions: const [ProfileActionIcon()],
        ),
        body: BookedFacilityDetailsView(details: _details),
      ),
    );
  }
}
