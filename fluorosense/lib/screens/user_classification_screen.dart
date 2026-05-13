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
  bool _showSelfOthersChoice = false;

  @override
  void initState() {
    super.initState();
    _checkUserProfile();
  }

  Future<void> _checkUserProfile() async {
    try {
      final profile = await _apiService.getUserProfile();
      setState(() {
        _userProfile = profile;
        // If name exists, we assume profile details are filled
        if (profile['name'] != null && profile['name'].toString().isNotEmpty) {
          _showSelfOthersChoice = true;
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _navigateToUpload(Map<String, String> data) {
    Navigator.pushNamed(context, '/camera', arguments: data);
  }

  /// Handles "For Myself" when user profile exists.
  /// Skips basic info questions and uses saved profile data directly.
  /// For maternal/child users, still asks essential per-analysis exposure details.
  void _handleForMyself() {
    final profile = _userProfile!;
    final userType = profile['user_type']?.toString() ?? '';

    if (userType == 'Pregnant/Caretaker (<9yrs)') {
      Navigator.pushNamed(
        context,
        '/maternal-child-form',
        arguments: {'prefilled': true, 'profile': profile},
      );
    } else {
      final formData = {
        'name': profile['name']?.toString() ?? '',
        'age': profile['age']?.toString() ?? '',
        'gender': profile['gender']?.toString() ?? '',
        'water_source': profile['water_source']?.toString() ?? '',
        'toothpaste_type': profile['toothpaste_type']?.toString() ?? '',
      };
      _navigateToUpload(formData);
    }
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
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: _showSelfOthersChoice
              ? _buildSelfOthersView()
              : _buildUserTypeView(),
        ),
      ),
    );
  }

  Widget _buildSelfOthersView() {
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
              ],
            ),
          ),
        ),
        const SizedBox(height: 30),
        const Text(
          'Who is this analysis for?',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 40),
        ElevatedButton(
          onPressed: _handleForMyself,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 20),
          ),
          child: const Text('For Myself'),
        ),
        const SizedBox(height: 20),
        OutlinedButton(
          onPressed: () {
            setState(() => _showSelfOthersChoice = false);
          },
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 20),
            side: BorderSide(color: Theme.of(context).primaryColor),
          ),
          child: Text(
            'For Others',
            style: TextStyle(color: Theme.of(context).primaryColor),
          ),
        ),
      ],
    );
  }

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
            final isSelf = _userProfile?['name'] == null;
            Navigator.pushNamed(
              context,
              '/maternal-child-form',
              arguments: {'is_self': isSelf},
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
            final isSelf = _userProfile?['name'] == null;
            Navigator.pushNamed(
              context,
              '/general-user-form',
              arguments: {'is_self': isSelf},
            );
          },
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 20),
          ),
          child: const Text('Age 9+'),
        ),
        if (_userProfile?['name'] != null) ...[
          const SizedBox(height: 20),
          TextButton(
            onPressed: () => setState(() => _showSelfOthersChoice = true),
            child: const Text('Back to Self/Others'),
          ),
        ],
      ],
    );
  }
}
