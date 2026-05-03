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
        actions: const [ProfileActionIcon()],
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
              sport: facility.sport,
              type: facility.type,
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
  final _sportController = TextEditingController();
  final _typeController = TextEditingController();
  final _openSummaryController = TextEditingController();
  final _priceController = TextEditingController();
  final _openTimeController = TextEditingController();
  final _closeTimeController = TextEditingController();
  final _slotDurationController = TextEditingController();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    if (widget.facility != null) {
      _nameController.text = widget.facility!.name;
      _sportController.text = widget.facility!.sport;
      _typeController.text = widget.facility!.type;
      _openSummaryController.text = widget.facility!.openSummary;
      _priceController.text = widget.facility!.pricePerHour;
      _openTimeController.text = widget.facility!.openTime ?? '';
      _closeTimeController.text = widget.facility!.closeTime ?? '';
      _slotDurationController.text = widget.facility!.slotDurationMins?.toString() ?? '60';
    } else {
      _slotDurationController.text = '60';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _sportController.dispose();
    _typeController.dispose();
    _openSummaryController.dispose();
    _priceController.dispose();
    _openTimeController.dispose();
    _closeTimeController.dispose();
    _slotDurationController.dispose();
    super.dispose();
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
          sport: _sportController.text.trim(),
          type: _typeController.text.trim(),
          openSummary: _openSummaryController.text.trim(),
          pricePerHour: double.parse(_priceController.text.trim()),
          status: widget.facility!.status,
          openTime: _openTimeController.text.trim().isEmpty ? null : _openTimeController.text.trim(),
          closeTime: _closeTimeController.text.trim().isEmpty ? null : _closeTimeController.text.trim(),
          slotDurationMins: int.tryParse(_slotDurationController.text.trim()),
        );
      } else {
        await controller.apiClient.createFacility(
          token: token,
          venueId: widget.venueId,
          name: _nameController.text.trim(),
          sport: _sportController.text.trim(),
          type: _typeController.text.trim(),
          openSummary: _openSummaryController.text.trim(),
          pricePerHour: double.parse(_priceController.text.trim()),
          status: 'active',
          openTime: _openTimeController.text.trim().isEmpty ? null : _openTimeController.text.trim(),
          closeTime: _closeTimeController.text.trim().isEmpty ? null : _closeTimeController.text.trim(),
          slotDurationMins: int.tryParse(_slotDurationController.text.trim()),
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
        actions: const [ProfileActionIcon()],
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
                      controller: _sportController,
                      decoration: const InputDecoration(
                        labelText: 'Sport',
                        hintText: 'e.g. Football, Basketball',
                      ),
                      validator: (v) => v == null || v.trim().isEmpty
                          ? 'Sport is required'
                          : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _typeController,
                      decoration: const InputDecoration(
                        labelText: 'Type',
                        hintText: 'e.g. Indoor, Outdoor',
                      ),
                      validator: (v) => v == null || v.trim().isEmpty
                          ? 'Type is required'
                          : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _openSummaryController,
                      decoration: const InputDecoration(
                        labelText: 'Open Summary',
                        hintText: 'Brief description',
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
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
                    const SizedBox(height: 16),
                    Text(
                      'Operating Hours',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _openTimeController,
                            decoration: const InputDecoration(
                              labelText: 'Opens',
                              hintText: '09:00',
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _closeTimeController,
                            decoration: const InputDecoration(
                              labelText: 'Closes',
                              hintText: '22:00',
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _slotDurationController,
                      decoration: const InputDecoration(
                        labelText: 'Slot Duration (minutes)',
                        hintText: '60',
                      ),
                      keyboardType: TextInputType.number,
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
