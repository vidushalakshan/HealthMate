import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/health_provider.dart';
import '../widgets/record_card.dart';
import 'add_record_screen.dart';

class RecordsListScreen extends StatefulWidget {
  const RecordsListScreen({Key? key}) : super(key: key);

  @override
  State<RecordsListScreen> createState() => _RecordsListScreenState();
}

class _RecordsListScreenState extends State<RecordsListScreen> {
  DateTime? _selectedDate;
  String _filterType = 'all'; // all, today, week, month, custom

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<HealthProvider>(context, listen: false).loadRecords();
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.blue,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _filterType = 'custom';
      });
      final dateString = DateFormat('yyyy-MM-dd').format(picked);
      if (mounted) {
        Provider.of<HealthProvider>(context, listen: false).searchByDate(dateString);
      }
    }
  }

  void _clearSearch() {
    setState(() {
      _selectedDate = null;
      _filterType = 'all';
    });
    Provider.of<HealthProvider>(context, listen: false).clearSearch();
  }

  void _applyQuickFilter(String filterType) {
    setState(() => _filterType = filterType);
    
    final now = DateTime.now();
    String? dateString;
    
    switch (filterType) {
      case 'today':
        _selectedDate = now;
        dateString = DateFormat('yyyy-MM-dd').format(now);
        Provider.of<HealthProvider>(context, listen: false).searchByDate(dateString);
        break;
      case 'yesterday':
        final yesterday = now.subtract(const Duration(days: 1));
        _selectedDate = yesterday;
        dateString = DateFormat('yyyy-MM-dd').format(yesterday);
        Provider.of<HealthProvider>(context, listen: false).searchByDate(dateString);
        break;
      case 'all':
        _clearSearch();
        break;
    }
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Filter Records',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _buildFilterOption(
                'All Records',
                Icons.list,
                Colors.purple,
                () {
                  Navigator.pop(context);
                  _applyQuickFilter('all');
                },
              ),
              _buildFilterOption(
                'Today',
                Icons.today,
                Colors.green,
                () {
                  Navigator.pop(context);
                  _applyQuickFilter('today');
                },
              ),
              _buildFilterOption(
                'Yesterday',
                Icons.calendar_today,
                Colors.orange,
                () {
                  Navigator.pop(context);
                  _applyQuickFilter('yesterday');
                },
              ),
              _buildFilterOption(
                'Custom Date',
                Icons.date_range,
                Colors.blue,
                () {
                  Navigator.pop(context);
                  _selectDate(context);
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterOption(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, int id, String date) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.delete, color: Colors.red),
            ),
            const SizedBox(width: 12),
            const Text('Delete Record'),
          ],
        ),
        content: Text(
          'Are you sure you want to delete the record for $date? This action cannot be undone.',
          style: const TextStyle(fontSize: 15),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Provider.of<HealthProvider>(context, listen: false).deleteRecord(id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.white),
                      SizedBox(width: 12),
                      Text('Record deleted successfully'),
                    ],
                  ),
                  backgroundColor: Colors.red,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  String _getFilterTitle() {
    switch (_filterType) {
      case 'today':
        return 'Today\'s Records';
      case 'yesterday':
        return 'Yesterday\'s Records';
      case 'custom':
        return _selectedDate != null
            ? DateFormat('MMM dd, yyyy').format(_selectedDate!)
            : 'Custom Date';
      default:
        return 'All Records';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getFilterTitle()),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue, Colors.purple],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterBottomSheet,
            tooltip: 'Filter records',
          ),
          if (_selectedDate != null || _filterType != 'all')
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: _clearSearch,
              tooltip: 'Clear filter',
            ),
        ],
      ),
      body: Consumer<HealthProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text(
                    'Loading records...',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            );
          }

          if (provider.records.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _filterType == 'all' ? Icons.inbox : Icons.search_off,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _selectedDate != null || _filterType != 'all'
                        ? 'No records found'
                        : 'No health records yet',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _selectedDate != null || _filterType != 'all'
                        ? 'Try selecting a different date or filter'
                        : 'Start adding your health activities',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (_filterType == 'all')
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AddRecordScreen(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('Add First Record'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    )
                  else
                    ElevatedButton.icon(
                      onPressed: _clearSearch,
                      icon: const Icon(Icons.clear),
                      label: const Text('Clear Filter'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Filter indicator
              if (_selectedDate != null || _filterType != 'all')
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  color: Colors.blue.withOpacity(0.1),
                  child: Row(
                    children: [
                      Icon(
                        _filterType == 'today'
                            ? Icons.today
                            : _filterType == 'yesterday'
                                ? Icons.calendar_today
                                : Icons.filter_alt,
                        size: 20,
                        color: Colors.blue,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _filterType == 'today'
                              ? 'Showing today\'s records'
                              : _filterType == 'yesterday'
                                  ? 'Showing yesterday\'s records'
                                  : _selectedDate != null
                                      ? 'Showing records for ${DateFormat('MMMM dd, yyyy').format(_selectedDate!)}'
                                      : 'Filter active',
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                      Text(
                        '${provider.records.length} ${provider.records.length == 1 ? 'record' : 'records'}',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ),
              
              // Records count
              Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${provider.records.length} Records Found',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: _showFilterBottomSheet,
                      icon: const Icon(Icons.tune, size: 18),
                      label: const Text('Filters'),
                    ),
                  ],
                ),
              ),

              // Records list
              Expanded(
                child: ListView.builder(
                  itemCount: provider.records.length,
                  padding: const EdgeInsets.only(bottom: 80),
                  itemBuilder: (context, index) {
                    final record = provider.records[index];
                    return RecordCard(
                      record: record,
                      onEdit: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AddRecordScreen(record: record),
                          ),
                        );
                      },
                      onDelete: () {
                        final formattedDate = DateFormat('MMM dd, yyyy')
                            .format(DateTime.parse(record.date));
                        _confirmDelete(context, record.id!, formattedDate);
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddRecordScreen(),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Record'),
        backgroundColor: Colors.blue,
      ),
    );
  }
}