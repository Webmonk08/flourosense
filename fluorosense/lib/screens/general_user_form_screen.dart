import 'package:flutter/material.dart';
import 'package:fluorosense/services/api_service.dart';

class GeneralUserFormScreen extends StatefulWidget {
  const GeneralUserFormScreen({super.key});

  @override
  State<GeneralUserFormScreen> createState() => _GeneralUserFormScreenState();
}

class _GeneralUserFormScreenState extends State<GeneralUserFormScreen> {
  final _formKey = GlobalKey<FormState>();

  String _name = '',
      _age = '',
      _gender = '',
      _waterSource = '',
      _toothpasteType = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Personal Details'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Name'),
                validator: (value) =>
                    value!.isEmpty ? 'Please enter a name' : null,
                onSaved: (value) => _name = value!,
              ),
              SizedBox(height: 20),
              TextFormField(
                decoration: InputDecoration(labelText: 'Age'),
                keyboardType: TextInputType.number,
                validator: (value) =>
                    value!.isEmpty ? 'Please enter an age' : null,
                onSaved: (value) => _age = value!,
              ),
              SizedBox(height: 20),
              DropdownButtonFormField(
                decoration: InputDecoration(labelText: 'Gender'),
                initialValue: _gender.isEmpty ? null : _gender,
                items: ['Male', 'Female', 'Other']
                    .map(
                      (label) =>
                          DropdownMenuItem(value: label, child: Text(label)),
                    )
                    .toList(),
                onChanged: (value) =>
                    setState(() => _gender = value.toString()),
              ),
              SizedBox(height: 20),
              DropdownButtonFormField(
                decoration: InputDecoration(labelText: 'Primary Water Source'),
                initialValue: _waterSource.isEmpty ? null : _waterSource,
                items: ['Well', 'RO', 'Ground', 'Other']
                    .map(
                      (label) =>
                          DropdownMenuItem(value: label, child: Text(label)),
                    )
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
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();

                    final formData = {
                      'name': _name,
                      'age': _age,
                      'gender': _gender,
                      'water_source': _waterSource,
                      'toothpaste_type': _toothpasteType,
                    };

                    final args = ModalRoute.of(context)?.settings.arguments;
                    if (args is Map<String, dynamic> &&
                        args['is_self'] == true) {
                      try {
                        await ApiService().updateProfile({
                          'name': _name,
                          'age': _age,
                          'gender': _gender,
                          'water_source': _waterSource,
                          'toothpaste_type': _toothpasteType,
                          'user_type': 'Age 9+',
                        });
                      } catch (_) {}
                    }

                    if (mounted) {
                      Navigator.pushNamed(
                        context,
                        '/camera',
                        arguments: formData,
                      );
                    }
                  }
                },
                child: Text('Next: Select Image'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
