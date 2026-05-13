import 'package:flutter/material.dart';
import 'package:fluorosense/services/api_service.dart';
import 'package:fluorosense/services/auth_service.dart';
import 'package:fluorosense/services/suggestion_service.dart';
import 'package:intl/intl.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ApiService _apiService = ApiService();
  final AuthService _authService = AuthService();
  final _formKey = GlobalKey<FormState>();

  String _email = '';
  String _password = '';
  String _name = '';
  String _age = '';
  String _gender = '';
  String _waterSource = '';
  String _toothpasteType = '';
  bool _isUpdating = false;
  bool _isEditing = false;

  List<dynamic> _reports = [];
  List<dynamic> _filteredReports = [];
  DateTimeRange? _selectedDateRange;
  bool _isLoading = true;
  bool _hasProfileData = false;

  @override
  void initState() {
    super.initState();
    _loadProfileAndReports();
  }

  Future<void> _loadProfileAndReports() async {
    try {
      final profile = await _apiService.getUserProfile();
      final reports = await _apiService.getReports();
      setState(() {
        _email = profile['email'] ?? '';
        _name = profile['name'] ?? '';
        _age = profile['age']?.toString() ?? '';
        _gender = profile['gender'] ?? '';
        _waterSource = profile['water_source'] ?? '';
        _toothpasteType = profile['toothpaste_type'] ?? '';
        _reports = reports;
        _filteredReports = reports;
        _hasProfileData = _name.isNotEmpty;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading data: $e')),
        );
      }
      setState(() => _isLoading = false);
    }
  }

  DateTime _parseDateTime(dynamic timestamp) {
    if (timestamp == null) return DateTime.now();
    try {
      if (timestamp is String) {
        return DateTime.parse(timestamp);
      }
      return DateTime.now();
    } catch (e) {
      return DateTime.now();
    }
  }

  void _filterReportsByDate() {
    if (_selectedDateRange == null) {
      setState(() => _filteredReports = _reports);
      return;
    }

    setState(() {
      _filteredReports = _reports.where((report) {
        final timestamp = _parseDateTime(report['timestamp']);
        return timestamp.isAfter(_selectedDateRange!.start) &&
            timestamp.isBefore(_selectedDateRange!.end.add(const Duration(days: 1)));
      }).toList();
    });
  }

  Future<void> _updateProfile() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() => _isUpdating = true);
      try {
        final Map<String, dynamic> updateData = {
          "email": _email,
          "name": _name,
          "age": _age,
          "gender": _gender,
          "water_source": _waterSource,
          "toothpaste_type": _toothpasteType,
        };
        if (_password.isNotEmpty) {
          updateData["password"] = _password;
        }
        await _apiService.updateProfile(updateData);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile updated successfully')),
          );
          setState(() {
            _isEditing = false;
            _hasProfileData = _name.isNotEmpty;
          });
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Update failed: $e')),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isUpdating = false);
        }
      }
    }
  }

  Future<void> _logout() async {
    await _authService.signOut();
    if (mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil('/auth', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile & History'),
        backgroundColor: Theme.of(context).primaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Logout',
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _hasProfileData && !_isEditing
                ? _buildProfileSummary()
                : _buildProfileEditForm(),
            const Divider(height: 40),
            _buildOverallHealthSummary(),
            const Divider(height: 40),
            _buildHistorySection(),
          ],
        ),
      ),
    );
  }

  /// Read-only profile summary card
  Widget _buildProfileSummary() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('My Profile',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            TextButton.icon(
              onPressed: () => setState(() => _isEditing = true),
              icon: const Icon(Icons.edit, size: 18),
              label: const Text('Edit'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                CircleAvatar(
                  backgroundColor: const Color(0xFF008080),
                  radius: 36,
                  child: Text(
                    _name.isNotEmpty ? _name[0].toUpperCase() : 'U',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(_name,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                Text(_email,
                    style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 12),
                _buildDetailRow(Icons.cake, 'Age', _age.isNotEmpty ? _age : 'Not set'),
                const SizedBox(height: 12),
                _buildDetailRow(Icons.person, 'Gender', _gender.isNotEmpty ? _gender : 'Not set'),
                const SizedBox(height: 12),
                _buildDetailRow(Icons.water_drop, 'Water Source',
                    _waterSource.isNotEmpty ? _waterSource : 'Not set'),
                const SizedBox(height: 12),
                _buildDetailRow(Icons.brush, 'Toothpaste',
                    _toothpasteType.isNotEmpty ? _toothpasteType : 'Not set'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF008080), size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
        ),
        Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
      ],
    );
  }

  /// Editable form for profile
  Widget _buildProfileEditForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _hasProfileData ? 'Edit Profile' : 'Complete Your Profile',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              if (_hasProfileData)
                TextButton(
                  onPressed: () => setState(() => _isEditing = false),
                  child: const Text('Cancel'),
                ),
            ],
          ),
          const SizedBox(height: 20),
          TextFormField(
            initialValue: _email,
            decoration: const InputDecoration(labelText: 'Email'),
            validator: (value) => value!.isEmpty ? 'Enter email' : null,
            onSaved: (value) => _email = value!,
          ),
          const SizedBox(height: 10),
          TextFormField(
            initialValue: _name,
            decoration: const InputDecoration(labelText: 'Full Name'),
            validator: (value) => value!.isEmpty ? 'Enter your name' : null,
            onSaved: (value) => _name = value!,
          ),
          const SizedBox(height: 10),
          TextFormField(
            initialValue: _age,
            decoration: const InputDecoration(labelText: 'Age'),
            keyboardType: TextInputType.number,
            onSaved: (value) => _age = value!,
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField(
            decoration: const InputDecoration(labelText: 'Gender'),
            value: _gender.isEmpty ? null : _gender,
            items: ['Male', 'Female', 'Other']
                .map((label) =>
                    DropdownMenuItem(value: label, child: Text(label)))
                .toList(),
            onChanged: (value) => setState(() => _gender = value.toString()),
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField(
            decoration: const InputDecoration(labelText: 'Water Source'),
            value: _waterSource.isEmpty ? null : _waterSource,
            items: ['Well', 'RO', 'Ground', 'Other']
                .map((label) =>
                    DropdownMenuItem(value: label, child: Text(label)))
                .toList(),
            onChanged: (value) =>
                setState(() => _waterSource = value.toString()),
          ),
          const SizedBox(height: 10),
          TextFormField(
            initialValue: _toothpasteType,
            decoration: const InputDecoration(labelText: 'Toothpaste Type'),
            onSaved: (value) => _toothpasteType = value!,
          ),
          const SizedBox(height: 10),
          TextFormField(
            decoration: const InputDecoration(labelText: 'New Password (leave blank to keep)'),
            obscureText: true,
            onSaved: (value) => _password = value!,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _isUpdating ? null : _updateProfile,
            child: _isUpdating
                ? const CircularProgressIndicator(color: Colors.white)
                : Text(_hasProfileData ? 'Update Profile' : 'Save Profile'),
          ),
        ],
      ),
    );
  }

  /// Overall health summary based on all reports
  Widget _buildOverallHealthSummary() {
    final overallData = SuggestionService.getOverallSummary(_reports);
    final Color statusColor = Color(overallData['color']);
    final stats = overallData['stats'] as Map<String, dynamic>?;
    final recommendations = overallData['recommendations'] as List<String>;
    final trend = overallData['trend'] as String;

    IconData trendIcon;
    String trendText;
    Color trendColor;
    switch (trend) {
      case 'improving':
        trendIcon = Icons.trending_up;
        trendText = 'Improving';
        trendColor = const Color(0xFF4CAF50);
        break;
      case 'worsening':
        trendIcon = Icons.trending_down;
        trendText = 'Worsening';
        trendColor = const Color(0xFFF44336);
        break;
      default:
        trendIcon = Icons.trending_flat;
        trendText = 'Stable';
        trendColor = const Color(0xFF9E9E9E);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Overall Health Summary',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),

        // Status card
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        overallData['overallStatus'],
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const Spacer(),
                    if (_reports.isNotEmpty)
                      Row(
                        children: [
                          Icon(trendIcon, color: trendColor, size: 20),
                          const SizedBox(width: 4),
                          Text(trendText,
                              style: TextStyle(color: trendColor, fontSize: 13, fontWeight: FontWeight.w500)),
                        ],
                      ),
                  ],
                ),
                const SizedBox(height: 16),

                // Summary text
                Text(
                  overallData['summary'],
                  style: const TextStyle(fontSize: 14, height: 1.5),
                ),

                // Stats bar (if reports exist)
                if (stats != null && stats['total'] > 0) ...[
                  const SizedBox(height: 20),
                  _buildStatsBar(stats),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatLabel('Healthy', stats['noFluorosis'], const Color(0xFF4CAF50)),
                      _buildStatLabel('Mild', stats['mild'], const Color(0xFFFFC107)),
                      _buildStatLabel('Moderate', stats['moderate'], const Color(0xFFFF9800)),
                      _buildStatLabel('Severe', stats['severe'], const Color(0xFFF44336)),
                    ],
                  ),
                ],

                // Recommendations
                if (recommendations.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  const Divider(),
                  const SizedBox(height: 12),
                  const Row(
                    children: [
                      Icon(Icons.lightbulb, color: Color(0xFFFFC107), size: 18),
                      SizedBox(width: 8),
                      Text('Recommendations',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ...recommendations.map((rec) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.arrow_right, color: Color(0xFF008080), size: 18),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(rec, style: const TextStyle(fontSize: 13, height: 1.4)),
                            ),
                          ],
                        ),
                      )),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Visual stats bar showing distribution of classifications
  Widget _buildStatsBar(Map<String, dynamic> stats) {
    final total = stats['total'] as int;
    if (total == 0) return const SizedBox.shrink();

    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: Row(
        children: [
          if (stats['noFluorosis'] > 0)
            Expanded(
              flex: stats['noFluorosis'],
              child: Container(height: 8, color: const Color(0xFF4CAF50)),
            ),
          if (stats['mild'] > 0)
            Expanded(
              flex: stats['mild'],
              child: Container(height: 8, color: const Color(0xFFFFC107)),
            ),
          if (stats['moderate'] > 0)
            Expanded(
              flex: stats['moderate'],
              child: Container(height: 8, color: const Color(0xFFFF9800)),
            ),
          if (stats['severe'] > 0)
            Expanded(
              flex: stats['severe'],
              child: Container(height: 8, color: const Color(0xFFF44336)),
            ),
        ],
      ),
    );
  }

  Widget _buildStatLabel(String label, int count, Color color) {
    return Column(
      children: [
        Text('$count', style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 16)),
        Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
      ],
    );
  }

  Widget _buildHistorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Analysis History', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            IconButton(
              icon: const Icon(Icons.date_range),
              onPressed: () async {
                final picked = await showDateRangePicker(
                  context: context,
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                  initialDateRange: _selectedDateRange,
                );
                if (picked != null) {
                  setState(() => _selectedDateRange = picked);
                  _filterReportsByDate();
                }
              },
            ),
          ],
        ),
        if (_selectedDateRange != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Chip(
              label: Text(
                '${DateFormat('MMM d').format(_selectedDateRange!.start)} - ${DateFormat('MMM d').format(_selectedDateRange!.end)}',
              ),
              onDeleted: () {
                setState(() => _selectedDateRange = null);
                _filterReportsByDate();
              },
            ),
          ),
        if (_isLoading)
          const Center(child: CircularProgressIndicator())
        else if (_filteredReports.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Text('No reports found.'),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _filteredReports.length,
            itemBuilder: (context, index) {
              final report = _filteredReports[index];
              final suggestion = SuggestionService.getSuggestion(
                  report['classification']?.toString() ?? '');
              final Color reportColor = Color(suggestion['color']);

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 6),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                child: ExpansionTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Image.network(
                      report['image_url'],
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.broken_image, size: 50),
                    ),
                  ),
                  title: Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: reportColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          report['classification'] ?? 'Unknown',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                  subtitle: Text(
                    DateFormat('yyyy-MM-dd HH:mm').format(_parseDateTime(report['timestamp'])),
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  ),
                  trailing: Text(
                    '${(report['confidence'] * 100).toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: reportColor,
                    ),
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Divider(),
                          Text(
                            suggestion['description'],
                            style: const TextStyle(fontSize: 13, height: 1.4),
                          ),
                          const SizedBox(height: 12),
                          const Text('Tips:',
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 6),
                          ...(suggestion['tips'] as List<String>).take(3).map((tip) => Padding(
                                padding: const EdgeInsets.only(bottom: 6),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(Icons.arrow_right, color: reportColor, size: 16),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(tip, style: const TextStyle(fontSize: 12, height: 1.3)),
                                    ),
                                  ],
                                ),
                              )),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
      ],
    );
  }
}
