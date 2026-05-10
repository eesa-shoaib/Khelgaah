import 'package:flutter/material.dart';
import 'package:frontend/core/api/api_models.dart';
import 'package:frontend/core/app_controller.dart';
import 'package:frontend/core/theme/app_theme.dart';
import 'package:frontend/core/widgets/app_widgets.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 6,
      child: Scaffold(
        appBar: AppBar(
          title: const AppLogo(width: 170, textAlign: TextAlign.left),
          actions: const [ProfileActionIcon()],
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'Overview'),
              Tab(text: 'Users'),
              Tab(text: 'Venues'),
              Tab(text: 'Bookings'),
              Tab(text: 'Payments'),
              Tab(text: 'Analytics'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            AdminOverviewSection(),
            UserManagementScreen(),
            VenueManagementScreen(),
            AdminBookingsScreen(),
            AdminPaymentsScreen(),
            AdminAnalyticsScreen(),
          ],
        ),
      ),
    );
  }
}

class AdminOverviewSection extends StatefulWidget {
  const AdminOverviewSection({super.key});

  @override
  State<AdminOverviewSection> createState() => _AdminOverviewSectionState();
}

class _AdminOverviewSectionState extends State<AdminOverviewSection> {
  bool _isLoading = true;
  String? _error;
  int _totalUsers = 0;
  int _totalVenues = 0;
  int _totalBookings = 0;
  int _pendingVenues = 0;
  int _pendingBookings = 0;
  int _openDisputes = 0;
  String _totalRevenue = '0';
  bool _didLoad = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didLoad) return;
    _didLoad = true;
    _loadDashboard();
  }

  Future<void> _loadDashboard() async {
    final controller = AppScope.of(context);
    final token = controller.session?.token;
    if (token == null) {
      if (!mounted) return;
      setState(() {
        _error = 'Authentication token not found.';
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final stats = await controller.apiClient
          .getAdminDashboard(token: token)
          .timeout(const Duration(seconds: 10));
      if (!mounted) return;
      setState(() {
        _totalUsers = stats.totalUsers;
        _totalVenues = stats.totalVenues;
        _totalBookings = stats.totalBookings;
        _pendingVenues = stats.pendingVenues;
        _pendingBookings = stats.pendingBookings;
        _openDisputes = stats.openDisputes;
        _totalRevenue = stats.totalRevenue;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Failed to load dashboard';
        _isLoading = false;
      });
    }
  }

  void _goToTab(int index) {
    DefaultTabController.of(context).animateTo(index);
  }

  @override
  Widget build(BuildContext context) {
    final user = AppScope.of(context).session?.user;

    return RefreshIndicator(
      onRefresh: _loadDashboard,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          BookingSummaryCard(
            title: 'Welcome, ${user?.fullName ?? 'Admin'}',
            subtitle: 'System overview and management dashboard.',
            meta: 'ADMIN',
          ),
          const SizedBox(height: 20),
          if (_error != null) ...[
            ErrorStateWidget(message: _error!, onRetry: _loadDashboard),
            const SizedBox(height: 20),
          ] else if (_isLoading) ...[
            const Center(child: Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: CircularProgressIndicator(),
            )),
            const SizedBox(height: 20),
          ],
          const Text(
            'Quick Actions',
            style: TextStyle(
              color: AppTheme.onSurface,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          AppActionTile(
            title: 'Manage Users',
            leadingIcon: Icons.group_outlined,
            onTap: () => _goToTab(1),
          ),
          AppActionTile(
            title: 'Venue Approvals',
            leadingIcon: Icons.approval_outlined,
            onTap: () => _goToTab(2),
          ),
          AppActionTile(
            title: 'Booking Management',
            leadingIcon: Icons.event_note_outlined,
            onTap: () => _goToTab(3),
          ),
          AppActionTile(
            title: 'Payments',
            leadingIcon: Icons.payments_outlined,
            onTap: () => _goToTab(4),
          ),
          AppActionTile(
            title: 'View Reports',
            leadingIcon: Icons.analytics_outlined,
            onTap: () => _goToTab(5),
          ),
          const SizedBox(height: 24),
          const Text(
            'Overview',
            style: TextStyle(
              color: AppTheme.onSurface,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          StatsCard(
            icon: Icons.people,
            label: 'Users',
            value: '$_totalUsers',
            subtitle: 'Total registered users',
          ),
          const SizedBox(height: 12),
          StatsCard(
            icon: Icons.business,
            label: 'Venues',
            value: '$_totalVenues',
            subtitle: 'Approved and pending venues',
          ),
          const SizedBox(height: 12),
          StatsCard(
            icon: Icons.event_note,
            label: 'Bookings',
            value: '$_totalBookings',
            subtitle: 'Total bookings',
          ),
          const SizedBox(height: 12),
          StatsCard(
            icon: Icons.pending_actions,
            label: 'Pending',
            value: '${_pendingVenues + _pendingBookings}',
            color: Colors.amber,
            subtitle: '$_pendingVenues venues, $_pendingBookings bookings',
          ),
          const SizedBox(height: 12),
          StatsCard(
            icon: Icons.report_problem_outlined,
            label: 'Disputes',
            value: '$_openDisputes',
            color: Colors.redAccent,
            subtitle: 'Open disputes needing review',
          ),
          const SizedBox(height: 12),
          StatsCard(
            icon: Icons.payments,
            label: 'Revenue',
            value: 'PKR $_totalRevenue',
            subtitle: 'Paid payments in system',
          ),
        ],
      ),
    );
  }
}

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  List<AdminUserDto> _users = [];
  String? _selectedRole;
  String? _selectedStatus;
  bool _isLoading = true;
  String? _error;
  bool _didLoad = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didLoad) return;
    _didLoad = true;
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    final controller = AppScope.of(context);
    final token = controller.session?.token;
    if (token == null) {
      if (!mounted) return;
      setState(() {
        _error = 'Authentication token not found.';
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final users = await controller.apiClient
          .listAdminUsers(token: token, role: _selectedRole, status: _selectedStatus)
          .timeout(const Duration(seconds: 10));
      if (!mounted) return;
      setState(() {
        _users = users;
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
        _error = 'Failed to load users.';
        _isLoading = false;
      });
    }
  }

  Future<void> _suspendUser(AdminUserDto user) async {
    final controller = AppScope.of(context);
    final token = controller.session?.token;
    if (token == null) {
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Suspend User'),
        content: Text('Suspend "${user.fullName}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error),
            child: const Text('Suspend'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await controller.apiClient.suspendAdminUser(token: token, userId: user.id);
      _loadUsers();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _deleteUser(AdminUserDto user) async {
    final controller = AppScope.of(context);
    final token = controller.session?.token;
    if (token == null) {
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete User'),
        content: Text('Delete "${user.fullName}" permanently?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await controller.apiClient.deleteAdminUser(token: token, userId: user.id);
      await _loadUsers();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _changeRole(AdminUserDto user) async {
    final controller = AppScope.of(context);
    final token = controller.session?.token;
    if (token == null) {
      return;
    }

    final role = await showDialog<String>(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text('Change Role: ${user.fullName}'),
        children: [
          _RoleChoice(
            label: 'Customer',
            value: 'customer',
            selected: user.role == 'customer',
          ),
          _RoleChoice(
            label: 'Venue Owner',
            value: 'venue_owner',
            selected: user.role == 'venue_owner',
          ),
          _RoleChoice(
            label: 'Admin',
            value: 'admin',
            selected: user.role == 'admin',
          ),
        ],
      ),
    );

    if (role == null || role == user.role) return;

    try {
      await controller.apiClient.changeAdminUserRole(
        token: token,
        userId: user.id,
        role: role,
      );
      await _loadUsers();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('User Management')),
      body: Column(
        children: [
          _buildRoleFilter(),
          _buildStatusFilter(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(child: Text(_error!))
                    : _buildUsersList(),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleFilter() {
    final roles = ['customer', 'venue_owner', 'admin'];
    return FilterChipsWidget(
      filters: roles,
      selected: _selectedRole,
      onSelected: (value) {
        setState(() {
          _selectedRole = value;
        });
        _loadUsers();
      },
      allLabel: 'All',
    );
  }

  Widget _buildStatusFilter() {
    final statuses = ['active', 'suspended', 'deleted'];
    return FilterChipsWidget(
      filters: statuses,
      selected: _selectedStatus,
      onSelected: (value) {
        setState(() {
          _selectedStatus = value;
        });
        _loadUsers();
      },
      allLabel: 'All',
    );
  }

  Widget _buildUsersList() {
    if (_users.isEmpty) {
      return const BookingSummaryCard(
              title: 'No users found',
              subtitle: 'There are no users matching your filters.',
              meta: 'USERS',
            );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _users.length,
      itemBuilder: (context, index) {
        final user = _users[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.surfaceContainer,
            border: Border.all(color: AppTheme.outlineVariant),
          ),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: AppTheme.primary.withValues(alpha: 0.2),
                child: Text(
                  user.fullName.isNotEmpty ? user.fullName[0].toUpperCase() : '?',
                  style: TextStyle(color: AppTheme.primary),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.fullName,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    Text(
                      user.email,
                      style: TextStyle(fontSize: 12, color: AppTheme.onSurfaceVariant),
                    ),
                    Row(
                      children: [
                        Container(
                          margin: const EdgeInsets.only(top: 4),
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: _roleColor(user.role).withValues(alpha: 0.2),
                          ),
                          child: Text(
                            user.role.toUpperCase(),
                            style: TextStyle(fontSize: 10, color: _roleColor(user.role)),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          margin: const EdgeInsets.only(top: 4),
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: _statusColor(user.status).withValues(alpha: 0.2),
                          ),
                          child: Text(
                            user.status.toUpperCase(),
                            style: TextStyle(fontSize: 10, color: _statusColor(user.status)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  switch (value) {
                    case 'role':
                      _changeRole(user);
                      break;
                    case 'suspend':
                      _suspendUser(user);
                      break;
                    case 'delete':
                      _deleteUser(user);
                      break;
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'role',
                    child: Text('Change role'),
                  ),
                  if (user.status == 'active')
                    const PopupMenuItem(
                      value: 'suspend',
                      child: Text('Suspend'),
                    ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Text('Delete'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Color _roleColor(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return Colors.purple;
      case 'venue_owner':
        return Colors.blue;
      case 'customer':
        return Colors.green;
      default:
        return AppTheme.onSurfaceVariant;
    }
  }

  Color _statusColor(String status) {
    return status == 'active' ? Colors.green : Colors.red;
  }
}

class _RoleChoice extends StatelessWidget {
  const _RoleChoice({
    required this.label,
    required this.value,
    required this.selected,
  });

  final String label;
  final String value;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return SimpleDialogOption(
      onPressed: () => Navigator.pop(context, value),
      child: Row(
        children: [
          Icon(selected ? Icons.radio_button_checked : Icons.radio_button_off),
          const SizedBox(width: 12),
          Text(label),
        ],
      ),
    );
  }
}

class VenueManagementScreen extends StatefulWidget {
  const VenueManagementScreen({super.key});

  @override
  State<VenueManagementScreen> createState() => _VenueManagementScreenState();
}

class _VenueManagementScreenState extends State<VenueManagementScreen> {
  List<AdminVenueDto> _venues = [];
  String? _selectedStatus;
  bool _isLoading = true;
  String? _error;
  bool _didLoad = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didLoad) return;
    _didLoad = true;
    _loadVenues();
  }

  Future<void> _loadVenues() async {
    final controller = AppScope.of(context);
    final token = controller.session?.token;
    if (token == null) {
      if (!mounted) return;
      setState(() {
        _error = 'Authentication token not found.';
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final venues = await controller.apiClient
          .listAdminVenues(token: token, status: _selectedStatus)
          .timeout(const Duration(seconds: 10));
      if (!mounted) return;
      setState(() {
        _venues = venues;
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
        _error = 'Failed to load venues.';
        _isLoading = false;
      });
    }
  }

  Future<void> _updateStatus(AdminVenueDto venue, String status) async {
    final controller = AppScope.of(context);
    final token = controller.session?.token;
    if (token == null) {
      return;
    }

    try {
      switch (status) {
        case 'approved':
          await controller.apiClient.approveAdminVenue(token: token, venueId: venue.id);
          break;
        case 'rejected':
          await controller.apiClient.rejectAdminVenue(token: token, venueId: venue.id);
          break;
        case 'suspended':
          await controller.apiClient.suspendAdminVenue(token: token, venueId: venue.id);
          break;
      }
      _loadVenues();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return Colors.green;
      case 'pending':
        return Colors.amber;
      case 'rejected':
      case 'suspended':
        return Colors.red;
      default:
        return AppTheme.onSurfaceVariant;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Venue Management')),
      body: Column(
        children: [
          _buildStatusFilter(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(child: Text(_error!))
                    : _buildVenuesList(),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusFilter() {
    final statuses = ['pending', 'approved', 'rejected', 'suspended'];
    return FilterChipsWidget(
      filters: statuses,
      selected: _selectedStatus,
      onSelected: (value) {
        setState(() {
          _selectedStatus = value;
        });
        _loadVenues();
      },
      allLabel: 'All',
    );
  }

  Widget _buildVenuesList() {
    if (_venues.isEmpty) {
      return const BookingSummaryCard(
              title: 'No venues found',
              subtitle: 'There are no venues matching your filters.',
              meta: 'VENUES',
            );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _venues.length,
      itemBuilder: (context, index) {
        final venue = _venues[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.surfaceContainer,
            border: Border(
              left: BorderSide(color: _statusColor(venue.approvalStatus), width: 3),
              top: BorderSide(color: AppTheme.outlineVariant),
              bottom: BorderSide(color: AppTheme.outlineVariant),
              right: BorderSide(color: AppTheme.outlineVariant),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      venue.name,
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: _statusColor(venue.approvalStatus).withValues(alpha: 0.2),
                    ),
                    child: Text(
                      venue.approvalStatus.toUpperCase(),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: _statusColor(venue.approvalStatus),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '${venue.city} • ${venue.address}',
                style: TextStyle(color: AppTheme.onSurfaceVariant, fontSize: 13),
              ),
              if (venue.approvalStatus == 'pending') ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _updateStatus(venue, 'rejected'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.error,
                          side: const BorderSide(color: AppTheme.error),
                        ),
                        child: const Text('Reject'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _updateStatus(venue, 'approved'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                        ),
                        child: const Text('Approve'),
                      ),
                    ),
                  ],
                ),
              ] else if (venue.approvalStatus == 'approved') ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => _updateStatus(venue, 'suspended'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.error,
                      side: const BorderSide(color: AppTheme.error),
                    ),
                    child: const Text('Suspend'),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class AdminAnalyticsScreen extends StatefulWidget {
  const AdminAnalyticsScreen({super.key});

  @override
  State<AdminAnalyticsScreen> createState() => _AdminAnalyticsScreenState();
}

class _AdminAnalyticsScreenState extends State<AdminAnalyticsScreen> {
  bool _isLoading = true;
  int _activeCustomers = 0;
  int _activeOwners = 0;
  int _confirmedBookings = 0;
  String _refundedAmount = '0';
  String? _error;
  bool _didLoad = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didLoad) return;
    _didLoad = true;
    _loadAnalytics();
  }

  Future<void> _loadAnalytics() async {
    final controller = AppScope.of(context);
    final token = controller.session?.token;
    if (token == null) {
      if (!mounted) return;
      setState(() {
        _error = 'Authentication token not found.';
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final data = await controller.apiClient
          .getAdminAnalytics(token: token)
          .timeout(const Duration(seconds: 10));
      if (!mounted) return;
      setState(() {
        _activeCustomers = data.activeCustomers;
        _activeOwners = data.activeOwners;
        _confirmedBookings = data.confirmedBookings;
        _refundedAmount = data.refundedAmount;
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
        _error = 'Failed to load analytics.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('System Analytics')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    StatsCard(
                      icon: Icons.people,
                      label: 'Active Customers',
                      value: '$_activeCustomers',
                    ),
                    const SizedBox(height: 12),
                    StatsCard(
                      icon: Icons.business,
                      label: 'Active Owners',
                      value: '$_activeOwners',
                    ),
                    const SizedBox(height: 12),
                    StatsCard(
                      icon: Icons.check_circle,
                      label: 'Confirmed Bookings',
                      value: '$_confirmedBookings',
                    ),
                    const SizedBox(height: 12),
                    StatsCard(
                      icon: Icons.money_off,
                      label: 'Refunded Amount',
                      value: 'PKR $_refundedAmount',
                      color: Colors.red,
                    ),
                  ],
                ),
    );
  }
}

class AdminBookingsScreen extends StatefulWidget {
  const AdminBookingsScreen({super.key});

  @override
  State<AdminBookingsScreen> createState() => _AdminBookingsScreenState();
}

class _AdminBookingsScreenState extends State<AdminBookingsScreen> {
  List<AdminBookingDto> _bookings = [];
  String? _selectedStatus;
  bool _isLoading = true;
  String? _error;
  bool _didLoad = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didLoad) return;
    _didLoad = true;
    _loadBookings();
  }

  Future<void> _loadBookings() async {
    final controller = AppScope.of(context);
    final token = controller.session?.token;
    if (token == null) {
      if (!mounted) return;
      setState(() {
        _error = 'Authentication token not found.';
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final bookings = await controller.apiClient
          .listAdminBookings(token: token, status: _selectedStatus)
          .timeout(const Duration(seconds: 10));
      if (!mounted) return;
      setState(() {
        _bookings = bookings;
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
        _error = 'Failed to load bookings.';
        _isLoading = false;
      });
    }
  }

  Future<void> _cancelBooking(AdminBookingDto booking) async {
    final controller = AppScope.of(context);
    final token = controller.session?.token;
    if (token == null) {
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Booking'),
        content: Text('Force cancel booking #${booking.id}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Back'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await controller.apiClient.cancelAdminBooking(token: token, bookingId: booking.id);
      _loadBookings();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Booking cancelled')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _resolveBooking(AdminBookingDto booking) async {
    final controller = AppScope.of(context);
    final token = controller.session?.token;
    if (token == null) {
      return;
    }

    final notesController = TextEditingController();
    String bookingStatus = booking.status;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Resolve Booking #${booking.id}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                initialValue: bookingStatus,
                decoration: const InputDecoration(labelText: 'Resolved status'),
                items: const [
                  DropdownMenuItem(value: 'pending', child: Text('Pending')),
                  DropdownMenuItem(value: 'confirmed', child: Text('Confirmed')),
                  DropdownMenuItem(value: 'completed', child: Text('Completed')),
                  DropdownMenuItem(value: 'cancelled', child: Text('Cancelled')),
                  DropdownMenuItem(value: 'rejected', child: Text('Rejected')),
                  DropdownMenuItem(value: 'disputed', child: Text('Disputed')),
                ],
                onChanged: (value) {
                  if (value == null) return;
                  setDialogState(() => bookingStatus = value);
                },
              ),
              const SizedBox(height: 12),
              TextField(
                controller: notesController,
                decoration: const InputDecoration(
                  labelText: 'Resolution notes',
                  hintText: 'Add the resolution summary',
                ),
                maxLines: 3,
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
              child: const Text('Resolve'),
            ),
          ],
        ),
      ),
    );

    if (confirmed != true) {
      notesController.dispose();
      return;
    }

    try {
      await controller.apiClient.resolveAdminBooking(
        token: token,
        bookingId: booking.id,
        resolutionNotes: notesController.text.trim(),
        bookingStatus: bookingStatus,
      );
      await _loadBookings();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Booking resolved')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      notesController.dispose();
    }
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return Colors.green;
      case 'pending':
        return Colors.amber;
      case 'cancelled':
      case 'rejected':
        return Colors.red;
      case 'completed':
        return Colors.blue;
      default:
        return AppTheme.onSurfaceVariant;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Booking Management')),
      body: Column(
        children: [
          _buildStatusFilter(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(child: Text(_error!))
                    : _buildBookingsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusFilter() {
    final statuses = ['pending', 'confirmed', 'completed', 'cancelled', 'rejected'];
    return FilterChipsWidget(
      filters: statuses,
      selected: _selectedStatus,
      onSelected: (value) {
        setState(() {
          _selectedStatus = value;
        });
        _loadBookings();
      },
      allLabel: 'All',
    );
  }

  Widget _buildBookingsList() {
    if (_bookings.isEmpty) {
      return const BookingSummaryCard(
              title: 'No bookings found',
              subtitle: 'There are no bookings matching your filters.',
              meta: 'BOOKINGS',
            );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _bookings.length,
      itemBuilder: (context, index) {
        final booking = _bookings[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.surfaceContainer,
            border: Border(
              left: BorderSide(color: _statusColor(booking.status), width: 3),
              top: BorderSide(color: AppTheme.outlineVariant),
              bottom: BorderSide(color: AppTheme.outlineVariant),
              right: BorderSide(color: AppTheme.outlineVariant),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Booking #${booking.id}',
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: _statusColor(booking.status).withValues(alpha: 0.2),
                    ),
                    child: Text(
                      booking.status.toUpperCase(),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: _statusColor(booking.status),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Customer: ${booking.userName}',
                style: TextStyle(color: AppTheme.onSurface),
              ),
              Text(
                'Facility: ${booking.facilityName} (${booking.venueName})',
                style: TextStyle(color: AppTheme.onSurfaceVariant, fontSize: 13),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 14, color: AppTheme.onSurfaceVariant),
                  const SizedBox(width: 8),
                  Text(
                    '${_formatDate(booking.startTime)} ${_formatTime(booking.startTime)} - ${_formatTime(booking.endTime)}',
                    style: TextStyle(color: AppTheme.onSurface),
                  ),
                ],
              ),
              Row(
                children: [
                  Icon(Icons.payment, size: 14, color: AppTheme.onSurfaceVariant),
                  const SizedBox(width: 8),
                  Text(
                    booking.paymentStatus,
                    style: TextStyle(color: AppTheme.onSurface),
                  ),
                ],
              ),
              if (booking.notes.trim().isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  'Notes: ${booking.notes}',
                  style: TextStyle(color: AppTheme.onSurfaceVariant, fontSize: 12),
                ),
              ],
              if (booking.status == 'pending' || booking.status == 'confirmed') ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _resolveBooking(booking),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.primary,
                          side: BorderSide(color: AppTheme.primary.withValues(alpha: 0.7)),
                        ),
                        child: const Text('Resolve'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _cancelBooking(booking),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.error,
                          side: const BorderSide(color: AppTheme.error),
                        ),
                        child: const Text('Cancel'),
                      ),
                    ),
                  ],
                ),
              ] else ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => _resolveBooking(booking),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.primary,
                      side: BorderSide(color: AppTheme.primary.withValues(alpha: 0.7)),
                    ),
                    child: const Text('Resolve / Update'),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class AdminPaymentsScreen extends StatefulWidget {
  const AdminPaymentsScreen({super.key});

  @override
  State<AdminPaymentsScreen> createState() => _AdminPaymentsScreenState();
}

class _AdminPaymentsScreenState extends State<AdminPaymentsScreen> {
  List<AdminPaymentDto> _payments = [];
  String? _selectedStatus;
  bool _isLoading = true;
  String? _error;
  bool _didLoad = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didLoad) return;
    _didLoad = true;
    _loadPayments();
  }

  Future<void> _loadPayments() async {
    final controller = AppScope.of(context);
    final token = controller.session?.token;
    if (token == null) {
      if (!mounted) return;
      setState(() {
        _error = 'Authentication token not found.';
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final payments = await controller.apiClient
          .listAdminPayments(token: token, status: _selectedStatus)
          .timeout(const Duration(seconds: 10));
      if (!mounted) return;
      setState(() {
        _payments = payments;
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
        _error = 'Failed to load payments.';
        _isLoading = false;
      });
    }
  }

  Future<void> _refundPayment(AdminPaymentDto payment) async {
    final controller = AppScope.of(context);
    final token = controller.session?.token;
    if (token == null) {
      return;
    }

    final notesController = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Refund booking #${payment.bookingId}'),
        content: TextField(
          controller: notesController,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'Refund notes',
            hintText: 'Reason for refund',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error),
            child: const Text('Refund'),
          ),
        ],
      ),
    );

    if (confirmed != true) {
      notesController.dispose();
      return;
    }

    try {
      await controller.apiClient.refundAdminPayment(
        token: token,
        bookingId: payment.bookingId,
        notes: notesController.text.trim(),
      );
      await _loadPayments();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Refund processed')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      notesController.dispose();
    }
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
        return Colors.green;
      case 'refunded':
        return Colors.red;
      case 'pending':
        return Colors.amber;
      default:
        return AppTheme.onSurfaceVariant;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Payments')),
      body: Column(
        children: [
          _buildStatusFilter(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(child: Text(_error!))
                    : _buildPaymentsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusFilter() {
    final statuses = ['pending', 'paid', 'refunded'];
    return FilterChipsWidget(
      filters: statuses,
      selected: _selectedStatus,
      onSelected: (value) {
        setState(() {
          _selectedStatus = value;
        });
        _loadPayments();
      },
      allLabel: 'All',
    );
  }

  Widget _buildPaymentsList() {
    if (_payments.isEmpty) {
      return const BookingSummaryCard(
              title: 'No payments found',
              subtitle: 'There are no payments matching your filters.',
              meta: 'PAYMENTS',
            );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _payments.length,
      itemBuilder: (context, index) {
        final payment = _payments[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.surfaceContainer,
            border: Border(
              left: BorderSide(color: _statusColor(payment.status), width: 3),
              top: BorderSide(color: AppTheme.outlineVariant),
              bottom: BorderSide(color: AppTheme.outlineVariant),
              right: BorderSide(color: AppTheme.outlineVariant),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Booking #${payment.bookingId}',
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: _statusColor(payment.status).withValues(alpha: 0.2),
                    ),
                    child: Text(
                      payment.status.toUpperCase(),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: _statusColor(payment.status),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text('${payment.currency} ${payment.amount} - ${payment.method}'),
              if (payment.providerReference.isNotEmpty)
                Text(
                  'Reference: ${payment.providerReference}',
                  style: TextStyle(color: AppTheme.onSurfaceVariant, fontSize: 12),
                ),
              if (payment.notes.trim().isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  payment.notes,
                  style: TextStyle(color: AppTheme.onSurfaceVariant, fontSize: 12),
                ),
              ],
              const SizedBox(height: 10),
              Text(
                'Created: ${payment.createdAt.toLocal()}',
                style: TextStyle(color: AppTheme.onSurfaceVariant, fontSize: 11),
              ),
              if (payment.status != 'refunded') ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => _refundPayment(payment),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.error,
                      side: const BorderSide(color: AppTheme.error),
                    ),
                    child: const Text('Refund'),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
