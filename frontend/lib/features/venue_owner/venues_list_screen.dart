import 'package:flutter/material.dart';
import 'package:frontend/core/api/api_models.dart';
import 'package:frontend/core/app_controller.dart';
import 'package:frontend/core/theme/app_theme.dart';
import 'package:frontend/core/widgets/parallelogram_btn.dart';
import 'package:frontend/core/widgets/venue_card_widget.dart';
import 'package:frontend/core/widgets/confirmation_dialog_widget.dart';
import 'package:frontend/core/widgets/profile_action_icon.dart';
import 'package:frontend/features/venue_owner/venue_details_screen.dart';

class VenuesListScreen extends StatefulWidget {
  const VenuesListScreen({super.key});

  @override
  State<VenuesListScreen> createState() => VenuesListScreenState();
}

class VenuesListScreenState extends State<VenuesListScreen> {
  List<VenueDto> _venues = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _loadVenues();
    });
  }

  Future<void> _loadVenues() async {
    final controller = AppScope.of(context);
    final token = controller.session?.token;
    if (token == null) return;

    try {
      final venues = await controller.apiClient
          .listVenues(token: token)
          .timeout(const Duration(seconds: 10));
      if (!mounted) return;
      setState(() => _venues = venues);
    } catch (_) {
      // Keep showing sample data on error
    }
  }

  Future<void> _deleteVenue(VenueDto venue) async {
    final controller = AppScope.of(context);
    final token = controller.session?.token;

    final confirmed = await ConfirmationDialog.show(
      context,
      title: 'Delete Venue',
      message: 'Delete "${venue.name}"? This action cannot be undone.',
      confirmText: 'Delete',
      isDestructive: true,
    );

    if (!confirmed) return;
    if (!mounted) return;

    if (token == null) return;

    try {
      await controller.apiClient
          .deleteVenue(token: token, venueId: venue.id)
          .timeout(const Duration(seconds: 10));
      if (!mounted) return;
      _loadVenues();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> showAddVenueDialog() async {
    final nameController = TextEditingController();
    final addressController = TextEditingController();
    final cityController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Add New Venue'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Venue Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: addressController,
              decoration: const InputDecoration(
                labelText: 'Address',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: cityController,
              decoration: const InputDecoration(
                labelText: 'City',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ParallelogramButton(
            text: 'Add',
            icon: null,
            onPressed: () => Navigator.pop(context, true),
            variant: ParallelogramButtonVariant.primary,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        ],
      ),
    );

    if (result != true || !mounted) return;

    final name = nameController.text.trim();
    final address = addressController.text.trim();
    final city = cityController.text.trim();

    if (name.isEmpty || city.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all required fields')),
      );
      return;
    }

    final controller = AppScope.of(context);
    final token = controller.session?.token;
    if (token == null) return;

    try {
      await controller.apiClient.createVenue(
        token: token,
        name: name,
        address: address,
        city: city,
      );
      if (!mounted) return;
      _loadVenues();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Venue added successfully')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _editVenue(VenueDto venue) async {
    final nameController = TextEditingController(text: venue.name);
    final addressController = TextEditingController(text: venue.address);
    final cityController = TextEditingController(text: venue.city);

    final result = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Edit Venue'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Venue Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: addressController,
              decoration: const InputDecoration(
                labelText: 'Address',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: cityController,
              decoration: const InputDecoration(
                labelText: 'City',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (result != true || !mounted) return;

    final name = nameController.text.trim();
    final address = addressController.text.trim();
    final city = cityController.text.trim();

    if (name.isEmpty || city.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all required fields')),
      );
      return;
    }

    final controller = AppScope.of(context);
    final token = controller.session?.token;
    if (token == null) return;

    try {
      await controller.apiClient.updateVenue(
        token: token,
        venueId: venue.id,
        name: name,
        address: address,
        city: city,
      );
      if (!mounted) return;
      _loadVenues();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Venue updated successfully')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Venues'),
        actions: const [ProfileActionIcon()],
      ),
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: _loadVenues,
            child: _venues.isEmpty
                ? _EmptyState(onAdd: () => showAddVenueDialog())
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _venues.length,
                    itemBuilder: (context, index) {
                      final venue = _venues[index];
                      return VenueCard(
                        key: ValueKey(venue.id),
                        name: venue.name,
                        city: venue.city,
                        facilityCount: venue.facilityCount,
                        status: venue.status,
                        showActions: true,
                        onView: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => VenueDetailsScreen(venue: venue),
                          ),
                        ),
                        onEdit: () => _editVenue(venue),
                        onDelete: () => _deleteVenue(venue),
                      );
                    },
                  ),
          ),
          Positioned(
            bottom: 16,
            right: 16,
            child: SafeArea(
              child: ParallelogramButton(
                onPressed: () => showAddVenueDialog(),
                text: 'Add Venue',
                icon: Icons.add,
                variant: ParallelogramButtonVariant.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onAdd;

  const _EmptyState({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.business,
            size: 64,
            color: AppTheme.onSurfaceVariant.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No venues yet',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: AppTheme.onSurfaceVariant),
          ),
          const SizedBox(height: 8),
          Text(
            'Add your first venue to get started',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppTheme.onSurfaceVariant),
          ),
          const SizedBox(height: 24),
          ParallelogramButton(
            text: 'Add Venue',
            icon: Icons.add,
            onPressed: onAdd,
            variant: ParallelogramButtonVariant.primary,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        ],
      ),
    );
  }
}
