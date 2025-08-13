import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../shared/models/pilot_model.dart';
import '../../shared/services/pilot_service.dart';
import '../../shared/widgets/app_logo.dart';

class PilotDiscoveryPage extends StatefulWidget {
  const PilotDiscoveryPage({super.key});

  @override
  State<PilotDiscoveryPage> createState() => _PilotDiscoveryPageState();
}

class _PilotDiscoveryPageState extends State<PilotDiscoveryPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final PilotService _pilotService = Get.find<PilotService>();
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    _animationController.forward();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _animationController.dispose();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: CustomScrollView(
            controller: _scrollController,
            slivers: [
              _buildAppBar(),
              _buildSearchSection(),
              _buildFilterSection(),
              _buildTabBar(),
              _buildTabContent(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      backgroundColor: Theme.of(context).primaryColor,
      flexibleSpace: FlexibleSpaceBar(
        title: Row(
          children: [
            SkykraftSmallLogo(size: 32),
            const SizedBox(width: 12),
            const Text(
              'Discover Pilots',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).primaryColor,
                Theme.of(context).primaryColor.withValues(alpha: 0.8),
              ],
            ),
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.filter_list, color: Colors.white),
          onPressed: _showAdvancedFilters,
          tooltip: 'Advanced Filters',
        ),
      ],
    );
  }

  Widget _buildSearchSection() {
    return SliverToBoxAdapter(
      child: Container(
        padding: const EdgeInsets.all(16),
        child: TextField(
          controller: _searchController,
          onChanged: _pilotService.searchPilots,
          decoration: InputDecoration(
            hintText: 'Search pilots, specializations, locations...',
            prefixIcon: const Icon(Icons.search),
            suffixIcon: IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                _searchController.clear();
                _pilotService.searchPilots('');
              },
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: Theme.of(context).cardColor,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 16,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterSection() {
    return SliverToBoxAdapter(
      child: Container(
        height: 60,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: [
            _buildFilterChip(
              label: 'All',
              isSelected: _pilotService.selectedSpecializations.isEmpty,
              onTap: () => _pilotService.clearFilters(),
            ),
            ...PilotSpecialization.values.map((spec) => _buildFilterChip(
              label: spec.name.replaceAll('_', ' ').toUpperCase(),
              isSelected: _pilotService.selectedSpecializations.contains(spec),
              onTap: () => _pilotService.filterBySpecializations([spec]),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : null,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        selected: isSelected,
        onSelected: (_) => onTap(),
        backgroundColor: Theme.of(context).cardColor,
        selectedColor: Theme.of(context).primaryColor,
        checkmarkColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: isSelected ? 4 : 1,
      ),
    );
  }

  Widget _buildTabBar() {
    return SliverPersistentHeader(
      pinned: true,
      delegate: _SliverAppBarDelegate(
        TabBar(
          controller: _tabController,
          labelColor: Theme.of(context).primaryColor,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Theme.of(context).primaryColor,
          indicatorWeight: 3,
          tabs: const [
            Tab(text: 'All Pilots'),
            Tab(text: 'Premium'),
            Tab(text: 'Nearby'),
          ],
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    return SliverFillRemaining(
      child: TabBarView(
        controller: _tabController,
        children: [
          _buildPilotList(_pilotService.filteredPilots),
          _buildPilotList(_pilotService.getPremiumPilots()),
          _buildNearbyPilots(),
        ],
      ),
    );
  }

  Widget _buildPilotList(List<PilotModel> pilots) {
    if (pilots.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: pilots.length,
      itemBuilder: (context, index) {
        final pilot = pilots[index];
        return _buildPilotCard(pilot);
      },
    );
  }

  Widget _buildNearbyPilots() {
    return FutureBuilder<List<PilotModel>>(
      future: _pilotService.getPilotsNearLocation(22.5937, 78.9629, 50),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        }
        
        final pilots = snapshot.data ?? [];
        if (pilots.isEmpty) {
          return _buildEmptyState();
        }
        
        return _buildPilotList(pilots);
      },
    );
  }

  Widget _buildPilotCard(PilotModel pilot) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: InkWell(
          onTap: () => _showPilotDetails(pilot),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundImage: pilot.photoUrl != null
                          ? NetworkImage(pilot.photoUrl!)
                          : null,
                      child: pilot.photoUrl == null
                          ? const Icon(Icons.person, size: 30)
                          : null,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  pilot.name,
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              if (pilot.isPremium)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.amber,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Text(
                                    'PREMIUM',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            pilot.experienceText,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.star,
                                size: 16,
                                color: Colors.amber,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${pilot.rating.toStringAsFixed(1)}',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '(${pilot.totalBookings} bookings)',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Specializations
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: pilot.specializationTexts.take(3).map((spec) => 
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        spec,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                  ).toList(),
                ),
                
                const SizedBox(height: 16),
                
                // Bottom row with rate and status
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Rate',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey.shade600,
                          ),
                        ),
                        Text(
                          '₹${pilot.hourlyRate.toStringAsFixed(0)}/hr',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: _getStatusColor(pilot.statusText).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            pilot.statusText,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: _getStatusColor(pilot.statusText),
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        if (pilot.isVerified)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.verified,
                                size: 16,
                                color: Colors.blue,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Verified',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.blue,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No pilots found',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your search or filters',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _pilotService.clearFilters,
            child: const Text('Clear Filters'),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'online':
        return Colors.green;
      case 'recently active':
        return Colors.orange;
      case 'offline':
        return Colors.grey;
      case 'unavailable':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _showAdvancedFilters() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => _AdvancedFiltersSheet(),
    );
  }

  void _showPilotDetails(PilotModel pilot) {
    // Navigate to pilot details page
    Get.to(() => PilotDetailsPage(pilot: pilot));
  }
}

class _AdvancedFiltersSheet extends StatefulWidget {
  @override
  State<_AdvancedFiltersSheet> createState() => _AdvancedFiltersSheetState();
}

class _AdvancedFiltersSheetState extends State<_AdvancedFiltersSheet> {
  final PilotService _pilotService = Get.find<PilotService>();
  
  double _maxDistance = 50.0;
  double _minRating = 0.0;
  double _maxHourlyRate = 1000.0;
  bool _verifiedOnly = false;
  bool _availableOnly = true;

  @override
  void initState() {
    super.initState();
    _maxDistance = _pilotService.maxDistance;
    _minRating = _pilotService.minRating;
    _maxHourlyRate = _pilotService.maxHourlyRate;
    _verifiedOnly = _pilotService.verifiedOnly;
    _availableOnly = _pilotService.availableOnly;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 32,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Advanced Filters',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Distance filter
          Text(
            'Maximum Distance: ${_maxDistance.toStringAsFixed(0)} km',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          Slider(
            value: _maxDistance,
            min: 5.0,
            max: 200.0,
            divisions: 39,
            onChanged: (value) {
              setState(() => _maxDistance = value);
            },
            onChangeEnd: (value) {
              _pilotService.filterByDistance(value);
            },
          ),
          
          const SizedBox(height: 24),
          
          // Rating filter
          Text(
            'Minimum Rating: ${_minRating.toStringAsFixed(1)}',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          Slider(
            value: _minRating,
            min: 0.0,
            max: 5.0,
            divisions: 10,
            onChanged: (value) {
              setState(() => _minRating = value);
            },
            onChangeEnd: (value) {
              _pilotService.filterByRating(value);
            },
          ),
          
          const SizedBox(height: 24),
          
          // Hourly rate filter
          Text(
            'Maximum Hourly Rate: ₹${_maxHourlyRate.toStringAsFixed(0)}',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          Slider(
            value: _maxHourlyRate,
            min: 100.0,
            max: 5000.0,
            divisions: 49,
            onChanged: (value) {
              setState(() => _maxHourlyRate = value);
            },
            onChangeEnd: (value) {
              _pilotService.filterByHourlyRate(value);
            },
          ),
          
          const SizedBox(height: 24),
          
          // Checkboxes
          CheckboxListTile(
            title: const Text('Verified Pilots Only'),
            value: _verifiedOnly,
            onChanged: (value) {
              setState(() => _verifiedOnly = value ?? false);
              _pilotService.filterByVerification(value ?? false);
            },
          ),
          
          CheckboxListTile(
            title: const Text('Available Pilots Only'),
            value: _availableOnly,
            onChanged: (value) {
              setState(() => _availableOnly = value ?? false);
              _pilotService.filterByAvailability(value ?? false);
            },
          ),
          
          const SizedBox(height: 24),
          
          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    _pilotService.clearFilters();
                    Navigator.pop(context);
                  },
                  child: const Text('Clear All'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Apply'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;

  _SliverAppBarDelegate(this._tabBar);

  @override
  double get minExtent => _tabBar.preferredSize.height;

  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(context, shrinkOffset, overlapsContent) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}

// Placeholder for pilot details page
class PilotDetailsPage extends StatelessWidget {
  final PilotModel pilot;
  
  const PilotDetailsPage({super.key, required this.pilot});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(pilot.name),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Text('Pilot Details for ${pilot.name}'),
      ),
    );
  }
}
