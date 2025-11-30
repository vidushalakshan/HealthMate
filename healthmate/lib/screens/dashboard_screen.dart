import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/health_provider.dart';
import '../widgets/summary_card.dart';
import 'add_record_screen.dart';
import 'records_list_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Map<String, int> _todayStats = {'steps': 0, 'calories': 0, 'water': 0};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    final provider = Provider.of<HealthProvider>(context, listen: false);
    await provider.loadRecords();
    
    final stats = await provider.getTodayStats();
    
    setState(() {
      _todayStats = stats;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('HealthMate Dashboard'),
        centerTitle: true,
        elevation: 0,
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
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Today's Summary",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        children: [
                          SummaryCard(
                            title: 'Steps',
                            value: _todayStats['steps'].toString(),
                            icon: Icons.directions_walk,
                            color: Colors.green,
                          ),
                          SummaryCard(
                            title: 'Calories',
                            value: _todayStats['calories'].toString(),
                            icon: Icons.local_fire_department,
                            color: Colors.orange,
                          ),
                          SummaryCard(
                            title: 'Water (ml)',
                            value: _todayStats['water'].toString(),
                            icon: Icons.water_drop,
                            color: Colors.blue,
                          ),
                          SummaryCard(
                            title: 'Total Records',
                            value: context.watch<HealthProvider>().records.length.toString(),
                            icon: Icons.assessment,
                            color: Colors.purple,
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const AddRecordScreen(),
                                  ),
                                );
                                _loadData();
                              },
                              icon: const Icon(Icons.add),
                              label: const Text('Add Record'),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const RecordsListScreen(),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.list),
                              label: const Text('View Records'),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                backgroundColor: Colors.purple,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Card(
                        elevation: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Health Tips',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 10),
                              _buildTip('💧', 'Drink at least 2000ml of water daily'),
                              _buildTip('🚶', 'Aim for 10,000 steps per day'),
                              _buildTip('🔥', 'Maintain a balanced calorie intake'),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildTip(String emoji, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(color: Colors.grey[700]),
            ),
          ),
        ],
      ),
    );
  }
}