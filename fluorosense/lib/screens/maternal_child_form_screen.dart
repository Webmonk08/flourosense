import 'package:flutter/material.dart';
import 'package:fluorosense/services/firestore_service.dart';

class MaternalChildFormScreen extends StatefulWidget {
  const MaternalChildFormScreen({super.key});

  @override
  _MaternalChildFormScreenState createState() =>
      _MaternalChildFormScreenState();
}

class _MaternalChildFormScreenState extends State<MaternalChildFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _pageController = PageController();

  String _name = '',
      _age = '',
      _gender = '',
      _waterSource = '',
      _toothpasteType = '';
  String _milkIntake = '', _sugarLevels = '', _toothpasteSwallowing = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Maternal/Child Details'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Form(
        key: _formKey,
        child: PageView(
          controller: _pageController,
          physics: NeverScrollableScrollPhysics(),
          children: [
            _buildPersonalDetailsPage(),
            _buildExposureDetailsPage(),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalDetailsPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Personal Details',
              style: Theme.of(context).textTheme.titleLarge),
          SizedBox(height: 20),
          TextFormField(
            decoration: InputDecoration(labelText: 'Name'),
            validator: (value) => value!.isEmpty ? 'Please enter a name' : null,
            onSaved: (value) => _name = value!,
          ),
          SizedBox(height: 20),
          TextFormField(
            decoration: InputDecoration(labelText: 'Age'),
            keyboardType: TextInputType.number,
            validator: (value) => value!.isEmpty ? 'Please enter an age' : null,
            onSaved: (value) => _age = value!,
          ),
          SizedBox(height: 20),
          DropdownButtonFormField(
            decoration: InputDecoration(labelText: 'Gender'),
            value: _gender.isEmpty ? null : _gender,
            items: ['Male', 'Female', 'Other']
                .map((label) =>
                    DropdownMenuItem(value: label, child: Text(label)))
                .toList(),
            onChanged: (value) => setState(() => _gender = value.toString()),
          ),
          SizedBox(height: 20),
          DropdownButtonFormField(
            decoration: InputDecoration(labelText: 'Primary Water Source'),
            value: _waterSource.isEmpty ? null : _waterSource,
            items: ['Well', 'RO', 'Ground', 'Other']
                .map((label) =>
                    DropdownMenuItem(value: label, child: Text(label)))
                .toList(),
            onChanged: (value) =>
                setState(() => _waterSource = value.toString()),
          ),
          SizedBox(height: 20),
          TextFormField(
            decoration: InputDecoration(labelText: 'Toothpaste Type/Brand'),
            onSaved: (value) => _toothpasteType = value!,
          ),
          SizedBox(height: 40),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                _formKey.currentState!.save();
                _pageController.nextPage(
                    duration: Duration(milliseconds: 300),
                    curve: Curves.easeIn);
              }
            },
            child: Text('Next'),
          ),
        ],
      ),
    );
  }

  Widget _buildExposureDetailsPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Exposure Details',
              style: Theme.of(context).textTheme.titleLarge),
          SizedBox(height: 20),
          TextFormField(
            decoration: InputDecoration(labelText: 'Daily Milk Intake (ml)'),
            keyboardType: TextInputType.number,
            onSaved: (value) => _milkIntake = value!,
          ),
          SizedBox(height: 20),
          TextFormField(
            decoration: InputDecoration(labelText: 'Daily Sugar Intake (g)'),
            keyboardType: TextInputType.number,
            onSaved: (value) => _sugarLevels = value!,
          ),
          SizedBox(height: 20),
          DropdownButtonFormField(
            decoration:
                InputDecoration(labelText: 'Toothpaste Swallowing Habit'),
            value: _toothpasteSwallowing.isEmpty ? null : _toothpasteSwallowing,
            items: ['Never', 'Sometimes', 'Always']
                .map((label) =>
                    DropdownMenuItem(value: label, child: Text(label)))
                .toList(),
            onChanged: (value) =>
                setState(() => _toothpasteSwallowing = value.toString()),
          ),
          SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () => _pageController.previousPage(
                    duration: Duration(milliseconds: 300),
                    curve: Curves.easeIn),
                child: Text('Back'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();

                    // Collect data into a map
                    final formData = {
                      'name': _name,
                      'age': _age,
                      'gender': _gender,
                      'water_source': _waterSource,
                      'toothpaste_type': _toothpasteType,
                      'milk_intake': _milkIntake,
                      'sugar_levels': _sugarLevels,
                      'toothpaste_swallowing': _toothpasteSwallowing,
                    };

                    // Navigate to image selection, passing form data
                    Navigator.pushNamed(context, '/camera', arguments: formData);
                  }
                },
                child: Text('Next: Select Image'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}


