import 'package:flutter/material.dart';
import 'package:fluorosense/services/api_service.dart';

class UserClassificationScreen extends StatefulWidget {
  const UserClassificationScreen({super.key});

  @override
  State<UserClassificationScreen> createState() =>
      _UserClassificationScreenState();
}

class _UserClassificationScreenState extends State<UserClassificationScreen> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  Map<String, dynamic>? _userProfile;
  bool _hasProfileData = false;
  bool _showFullForm = false; // toggled when user picks "For Others"

  @override
  void initState() {
    super.initState();
    _checkUserProfile();
  }

  Future<void> _checkUserProfile() async {
    try {
      final profile = await _apiService.getUserProfile();
      if (!mounted) return;
      setState(() {
        _userProfile = profile;
        _hasProfileData =
            profile['name'] != null && profile['name'].toString().isNotEmpty;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  void _navigateToUpload(Map<String, String> data) {
    Navigator.pushNamed(context, '/camera', arguments: data);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analysis Selection'),
        backgroundColor: Theme.of(context).primaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => Navigator.pushNamed(context, '/profile'),
            tooltip: 'Profile & History',
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32.0),
          child: _showFullForm
              ? _buildUserTypeView()
              : _hasProfileData
              ? _buildQuickAnalysisView()
              : _buildUserTypeView(),
        ),
      ),
    );
  }

  /// When profile data exists: show user info card + only the essential
  /// per-analysis fields (water source, toothpaste type), then proceed.
  Widget _buildQuickAnalysisView() {
    final _quickFormKey = GlobalKey<FormState>();
    String waterSource = _userProfile?['water_source']?.toString() ?? '';
    String toothpasteType = _userProfile?['toothpaste_type']?.toString() ?? '';

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // User info card
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: const Color(0xFF008080),
                  radius: 24,
                  child: Text(
                    (_userProfile?['name']?.toString() ?? 'U')[0].toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _userProfile?['name']?.toString() ?? 'User',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Age: ${_userProfile?['age'] ?? 'N/A'} • ${_userProfile?['gender'] ?? 'N/A'}',
                        style: TextStyle(color: Colors.grey[600], fontSize: 13),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.check_circle, color: Color(0xFF008080)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),

        const Text(
          'Quick Analysis',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          'Your profile details will be used automatically.\nJust confirm these per-analysis details:',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey[600], fontSize: 14),
        ),
        const SizedBox(height: 24),

        // Per-analysis essential fields only
        Form(
          key: _quickFormKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Primary Water Source',
                  prefixIcon: Icon(Icons.water_drop),
                ),
                value: waterSource.isEmpty ? null : waterSource,
                validator: (value) => value == null || value.isEmpty
                    ? 'Please select a water source'
                    : null,
                items: ['Well', 'RO', 'Ground', 'Other']
                    .map(
                      (label) =>
                          DropdownMenuItem(value: label, child: Text(label)),
                    )
                    .toList(),
                onChanged: (value) => waterSource = value ?? '',
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: toothpasteType,
                decoration: const InputDecoration(
                  labelText: 'Toothpaste Type/Brand',
                  prefixIcon: Icon(Icons.brush),
                ),
                validator: (value) => value == null || value.isEmpty
                    ? 'Please enter toothpaste type'
                    : null,
                onChanged: (value) => toothpasteType = value,
              ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                icon: const Icon(Icons.camera_alt),
                label: const Text('Proceed to Image Selection'),
                onPressed: () {
                  if (_quickFormKey.currentState!.validate()) {
                    final formData = {
                      'name': _userProfile!['name']?.toString() ?? '',
                      'age': _userProfile!['age']?.toString() ?? '',
                      'gender': _userProfile!['gender']?.toString() ?? '',
                      'water_source': waterSource,
                      'toothpaste_type': toothpasteType,
                    };
                    _navigateToUpload(formData);
                  }
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),
        OutlinedButton(
          onPressed: () {
            setState(() => _showFullForm = true);
          },
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
            side: BorderSide(color: Theme.of(context).primaryColor),
          ),
          child: Text(
            'Analyse for someone else',
            style: TextStyle(color: Theme.of(context).primaryColor),
          ),
        ),
      ],
    );
  }

  /// Full form flow — when no profile data exists or user picks "For Others"
  Widget _buildUserTypeView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Select User Type',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 40),
        ElevatedButton(
          onPressed: () {
            Navigator.pushNamed(
              context,
              '/maternal-child-form',
              arguments: {'is_self': !_showFullForm},
            );
          },
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 20),
          ),
          child: const Text('Pregnant/Caretaker (<9yrs)'),
        ),
        const SizedBox(height: 30),
        ElevatedButton(
          onPressed: () {
            Navigator.pushNamed(
              context,
              '/general-user-form',
              arguments: {'is_self': !_showFullForm},
            );
          },
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 20),
          ),
          child: const Text('Age 9+'),
        ),
        if (_hasProfileData) ...[
          const SizedBox(height: 20),
          TextButton(
            onPressed: () => setState(() => _showFullForm = false),
            child: const Text('← Back to Quick Analysis'),
          ),
        ],
      ],
    );
  }
}
