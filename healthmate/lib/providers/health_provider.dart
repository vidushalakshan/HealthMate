import 'package:flutter/foundation.dart';
import '../models/health_record.dart';
import '../database/database_helper.dart';
import 'package:intl/intl.dart';

class HealthProvider with ChangeNotifier {
  List<HealthRecord> _records = [];
  List<HealthRecord> _filteredRecords = [];
  bool _isLoading = false;
  String? _searchDate;

  List<HealthRecord> get records => _filteredRecords.isEmpty && _searchDate == null
      ? _records
      : _filteredRecords;
  
  bool get isLoading => _isLoading;
  String? get searchDate => _searchDate;

  // Load all records from database
  Future<void> loadRecords() async {
    _isLoading = true;
    notifyListeners();

    try {
      _records = await DatabaseHelper.instance.readAllRecords();
      _filteredRecords = [];
      _searchDate = null;
    } catch (e) {
      debugPrint('Error loading records: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add a new record
  Future<void> addRecord(HealthRecord record) async {
    try {
      final newRecord = await DatabaseHelper.instance.create(record);
      _records.insert(0, newRecord);
      
      // If we're currently filtering, update filtered list too
      if (_searchDate != null && record.date == _searchDate) {
        _filteredRecords.insert(0, newRecord);
      }
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding record: $e');
      rethrow;
    }
  }

  // Update an existing record
  Future<void> updateRecord(HealthRecord record) async {
    try {
      await DatabaseHelper.instance.update(record);
      
      final index = _records.indexWhere((r) => r.id == record.id);
      if (index != -1) {
        _records[index] = record;
      }

      // Update filtered list if active
      if (_filteredRecords.isNotEmpty) {
        final filteredIndex = _filteredRecords.indexWhere((r) => r.id == record.id);
        if (filteredIndex != -1) {
          _filteredRecords[filteredIndex] = record;
        }
      }
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error updating record: $e');
      rethrow;
    }
  }

  // Delete a record
  Future<void> deleteRecord(int id) async {
    try {
      await DatabaseHelper.instance.delete(id);
      _records.removeWhere((record) => record.id == id);
      _filteredRecords.removeWhere((record) => record.id == id);
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting record: $e');
      rethrow;
    }
  }

  // Search records by date
  Future<void> searchByDate(String date) async {
    _isLoading = true;
    _searchDate = date;
    notifyListeners();

    try {
      _filteredRecords = await DatabaseHelper.instance.searchByDate(date);
    } catch (e) {
      debugPrint('Error searching records: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Clear search filter
  void clearSearch() {
    _searchDate = null;
    _filteredRecords = [];
    notifyListeners();
  }

  // Get today's statistics
  Future<Map<String, int>> getTodayStats() async {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    return await DatabaseHelper.instance.getTodayStats(today);
  }

  // Get total statistics for all records
  Map<String, int> getTotalStats() {
    int totalSteps = 0;
    int totalCalories = 0;
    int totalWater = 0;

    for (var record in _records) {
      totalSteps += record.steps;
      totalCalories += record.calories;
      totalWater += record.water;
    }

    return {
      'steps': totalSteps,
      'calories': totalCalories,
      'water': totalWater,
    };
  }
}