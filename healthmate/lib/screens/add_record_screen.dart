import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/health_record.dart';
import '../providers/health_provider.dart';

class AddRecordScreen extends StatefulWidget {
  final HealthRecord? record;

  const AddRecordScreen({Key? key, this.record}) : super(key: key);

  @override
  State<AddRecordScreen> createState() => _AddRecordScreenState();
}

class _AddRecordScreenState extends State<AddRecordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _stepsController = TextEditingController();
  final _caloriesController = TextEditingController();
  final _waterController = TextEditingController();
  
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.record != null) {
      _stepsController.text = widget.record!.steps.toString();
      _caloriesController.text = widget.record!.calories.toString();
      _waterController.text = widget.record!.water.toString();
      _selectedDate = DateTime.parse(widget.record!.date);
    }
  }

  @override
  void dispose() {
    _stepsController.dispose();
    _caloriesController.dispose();
    _waterController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _saveRecord() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        final provider = Provider.of<HealthProvider>(context, listen: false);
        
        final record = HealthRecord(
          id: widget.record?.id,
          date: DateFormat('yyyy-MM-dd').format(_selectedDate),
          steps: int.parse(_stepsController.text),
          calories: int.parse(_caloriesController.text),
          water: int.parse(_waterController.text),
        );

        if (widget.record == null) {
          await provider.addRecord(record);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Record added successfully!'),
                backgroundColor: Colors.green,
              ),
            );
          }
        } else {
          await provider.updateRecord(record);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Record updated successfully!'),
                backgroundColor: Colors.blue,
              ),
            );
          }
        }

        if (mounted) {
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.record == null ? 'Add Health Record' : 'Edit Health Record'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue, Colors.purple],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                elevation: 3,
                child: ListTile(
                  leading: const Icon(Icons.calendar_today, color: Colors.blue),
                  title: const Text('Date'),
                  subtitle: Text(DateFormat('MMM dd, yyyy').format(_selectedDate)),
                  trailing: const Icon(Icons.edit),
                  onTap: () => _selectDate(context),
                ),
              ),
              const SizedBox(height: 20),
              
              // Steps Input
              TextFormField(
                controller: _stepsController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Steps Walked',
                  prefixIcon: const Icon(Icons.directions_walk, color: Colors.green),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.green.withOpacity(0.1),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter steps';
                  }
                  final steps = int.tryParse(value);
                  if (steps == null || steps < 0) {
                    return 'Please enter a valid number';
                  }
                  if (steps > 100000) {
                    return 'Steps seem too high';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Calories Input
              TextFormField(
                controller: _caloriesController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Calories Burned',
                  prefixIcon: const Icon(Icons.local_fire_department, color: Colors.orange),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.orange.withOpacity(0.1),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter calories';
                  }
                  final calories = int.tryParse(value);
                  if (calories == null || calories < 0) {
                    return 'Please enter a valid number';
                  }
                  if (calories > 10000) {
                    return 'Calories seem too high';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Water Input
              TextFormField(
                controller: _waterController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Water Intake (ml)',
                  prefixIcon: const Icon(Icons.water_drop, color: Colors.blue),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.blue.withOpacity(0.1),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter water intake';
                  }
                  final water = int.tryParse(value);
                  if (water == null || water < 0) {
                    return 'Please enter a valid number';
                  }
                  if (water > 10000) {
                    return 'Water intake seems too high';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 30),
              
              ElevatedButton(
                onPressed: _isLoading ? null : _saveRecord,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  backgroundColor: Colors.blue,
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(
                        widget.record == null ? 'Add Record' : 'Update Record',
                        style: const TextStyle(fontSize: 16),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}