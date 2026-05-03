import 'package:flutter/material.dart';
import 'package:frontend/core/api/api_models.dart';
import 'package:frontend/core/app_controller.dart';
import 'package:frontend/core/theme/app_theme.dart';
import 'package:frontend/core/utils/app_feedback.dart';
import 'package:frontend/core/widgets/confirmation_dialog_widget.dart';
import 'package:frontend/core/widgets/facility_card_widget.dart';
import 'package:frontend/core/widgets/profile_action_icon.dart';
import 'package:frontend/features/venue_owner/facility_details_screen.dart';

class FacilitiesListScreen extends StatefulWidget {
  final VenueDto venue;

  const FacilitiesListScreen({super.key, required this.venue});

  @override
  State<FacilitiesListScreen> createState() => _FacilitiesListScreenState();
}

class _FacilitiesListScreenState extends State<FacilitiesListScreen> {
  bool _isLoading = true;
  List<VenueOwnerFacilityDto> _facilities = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadFacilities();
  }

  Future<void> _loadFacilities() async {
    final controller = AppScope.of(context);
    final token = controller.session?.token;
    if (token == null) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final facilities = await controller.apiClient.listFacilitiesForVenue(
        token: token,
        venueId: widget.venue.id,
      );
      if (!mounted) return;
      setState(() {
        _facilities = facilities;
        _isLoading = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.message;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'Failed to load facilities.';
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteFacility(VenueOwnerFacilityDto facility) async {
    final controller = AppScope.of(context);
    final token = controller.session?.token;

    final confirmed = await ConfirmationDialog.show(
      context,
      title: 'Delete Facility',
      message:
          'Are you sure you want to delete "${facility.name}"? This action cannot be undone.',
      confirmText: 'Delete',
      isDestructive: true,
    );

    if (!confirmed) return;
    if (!mounted) return;
    if (token == null) return;

    try {
      await controller.apiClient.deleteFacility(
        token: token,
        facilityId: facility.id,
      );
      if (!mounted) return;
      AppFeedback.pulseMessage(
        context,
        message: 'Facility deleted successfully.',
        icon: Icons.check_circle_outline,
      );
      _loadFacilities();
    } on ApiException catch (e) {
      if (!mounted) return;
      AppFeedback.pulseMessage(
        context,
        message: e.message,
        icon: Icons.error_outline,
      );
    }
  }

  void _navigateToFacilityDetails(VenueOwnerFacilityDto facility) {
    final navContext = context;
    Navigator.push<void>(
      navContext,
      MaterialPageRoute(
        builder: (_) => FacilityDetailsScreen(facility: facility),
      ),
    ).then((_) => _loadFacilities());
  }

  void _navigateToAddFacility() {
    final navContext = context;
    Navigator.push<void>(
      navContext,
      MaterialPageRoute(
        builder: (_) => FacilityEditScreen(venueId: widget.venue.id),
      ),
    ).then((_) => _loadFacilities());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.venue.name} - Facilities'),
        actions: [ProfileActionIcon()],
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddFacility,
        backgroundColor: AppTheme.primary,
        foregroundColor: AppTheme.onPrimary,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_error!, style: const TextStyle(color: AppTheme.error)),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _loadFacilities,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_facilities.isEmpty) {
      return _EmptyState(onAdd: _navigateToAddFacility);
    }

    return RefreshIndicator(
      onRefresh: _loadFacilities,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          for (final facility in _facilities)
            FacilityCard(
              name: facility.name,
              description: facility.description,
              capacity: facility.capacity,
              pricePerHour: facility.pricePerHour,
              status: facility.status,
              showActions: true,
              onTap: () => _navigateToFacilityDetails(facility),
              onEdit: () {
                Navigator.push<void>(
                  context,
                  MaterialPageRoute(
                    builder: (_) => FacilityEditScreen(
                      venueId: widget.venue.id,
                      facility: facility,
                    ),
                  ),
                ).then((_) => _loadFacilities());
              },
              onDelete: () => _deleteFacility(facility),
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
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const SizedBox(height: 40),
        Icon(Icons.sports_outlined, size: 64, color: AppTheme.onSurfaceVariant),
        const SizedBox(height: 16),
        Text(
          'No facilities yet',
          style: theme.textTheme.titleMedium?.copyWith(
            color: AppTheme.onSurface,
            fontWeight: FontWeight.w700,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Add your first facility to start receiving bookings.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: AppTheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        Center(
          child: ElevatedButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add),
            label: const Text('Add Facility'),
          ),
        ),
      ],
    );
  }
}

class FacilityEditScreen extends StatefulWidget {
  final int venueId;
  final VenueOwnerFacilityDto? facility;

  const FacilityEditScreen({super.key, required this.venueId, this.facility});

  @override
  State<FacilityEditScreen> createState() => _FacilityEditScreenState();
}

class _FacilityEditScreenState extends State<FacilityEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _capacityController = TextEditingController();
  final _priceController = TextEditingController();
  final _amenitiesController = TextEditingController();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    if (widget.facility != null) {
      _nameController.text = widget.facility!.name;
      _descriptionController.text = widget.facility!.description;
      _capacityController.text = widget.facility!.capacity.toString();
      _priceController.text = widget.facility!.pricePerHour.toString();
      _amenitiesController.text = widget.facility!.amenities.join(', ');
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _capacityController.dispose();
    _priceController.dispose();
    _amenitiesController.dispose();
    super.dispose();
  }

  List<String> get _amenitiesList {
    return _amenitiesController.text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }

  Future<void> _saveFacility() async {
    if (!_formKey.currentState!.validate()) return;

    final controller = AppScope.of(context);
    final token = controller.session?.token;
    if (token == null) return;

    setState(() => _isSaving = true);

    try {
      if (widget.facility != null) {
        await controller.apiClient.updateFacility(
          token: token,
          facilityId: widget.facility!.id,
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim(),
          capacity: int.parse(_capacityController.text.trim()),
          pricePerHour: double.parse(_priceController.text.trim()),
          amenities: _amenitiesList,
        );
      } else {
        await controller.apiClient.createFacility(
          token: token,
          venueId: widget.venueId,
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim(),
          capacity: int.parse(_capacityController.text.trim()),
          pricePerHour: double.parse(_priceController.text.trim()),
          amenities: _amenitiesList,
        );
      }

      if (!mounted) return;
      AppFeedback.pulseMessage(
        context,
        message: widget.facility != null
            ? 'Facility updated successfully.'
            : 'Facility created successfully.',
        icon: Icons.check_circle_outline,
      );
      Navigator.pop(context);
    } on ApiException catch (e) {
      if (!mounted) return;
      AppFeedback.pulseMessage(
        context,
        message: e.message,
        icon: Icons.error_outline,
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.facility != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Facility' : 'Add Facility'),
        actions: [ProfileActionIcon()],
      ),
      body: _isSaving
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Facility Name',
                        hintText: 'Enter facility name',
                      ),
                      validator: (v) => v == null || v.trim().isEmpty
                          ? 'Name is required'
                          : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        hintText: 'Enter facility description',
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _capacityController,
                            decoration: const InputDecoration(
                              labelText: 'Capacity',
                              hintText: 'e.g. 20',
                            ),
                            keyboardType: TextInputType.number,
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) {
                                return 'Capacity is required';
                              }
                              if (int.tryParse(v.trim()) == null) {
                                return 'Enter a valid number';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _priceController,
                            decoration: const InputDecoration(
                              labelText: 'Price/Hour',
                              hintText: 'e.g. 1500',
                            ),
                            keyboardType: TextInputType.number,
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) {
                                return 'Price is required';
                              }
                              if (double.tryParse(v.trim()) == null) {
                                return 'Enter a valid amount';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _amenitiesController,
                      decoration: const InputDecoration(
                        labelText: 'Amenities (comma-separated)',
                        hintText: 'e.g. Changing Room, Shower, Parking',
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _saveFacility,
                        child: Text(
                          isEdit ? 'Update Facility' : 'Create Facility',
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
