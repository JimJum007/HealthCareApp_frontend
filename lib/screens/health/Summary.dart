import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:provider/provider.dart';
import 'package:healthcare/providers/auth_provider.dart';
import 'package:healthcare/providers/food_record_provider.dart';
import 'package:healthcare/screens/health/FoodRecord.dart';
import 'package:intl/intl.dart';

class SummaryGraphScreen extends StatefulWidget {
  @override
  _SummaryGraphScreenState createState() => _SummaryGraphScreenState();
}

class _SummaryGraphScreenState extends State<SummaryGraphScreen> {
  // ตัวแปรสำหรับ Summary
  String averageMeal = '0';
  String averageCalories = '0';

  String averageMealDate = '';
  String averageCaloriesDate = '';

  String maxMeal = '0';
  String maxMealDate = '';
  String maxCalories = '0';
  String maxCalorieDate = '';

  String minMeal = '0';
  String minMealDate = '';
  String minCalories = '0';
  String minCalorieDate = '';

  List<ChartData> _chartData = [];

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () => _fetchData());
  }

  Future<void> _fetchData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final foodProvider = Provider.of<FoodRecordProvider>(context, listen: false);

    if (authProvider.isTokenExpired()) {
      print('Token expired! Logging out...');
      await authProvider.logout(context);
      return;
    }

    try {
      await foodProvider.fetchRecords(context);
      _processData(foodProvider.records);
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  void _processData(List<Map<String, dynamic>> records) {
    if (records.isEmpty) {
      print("No data available");
      return;
    }

    final now = DateTime.now();
    final dayMap = {
      'Sun': now.subtract(Duration(days: now.weekday % 7)),
      'Mon': now.subtract(Duration(days: now.weekday - 1)),
      'Tue': now.subtract(Duration(days: now.weekday - 2)),
      'Wed': now.subtract(Duration(days: now.weekday - 3)),
      'Thu': now.subtract(Duration(days: now.weekday - 4)),
      'Fri': now.subtract(Duration(days: now.weekday - 5)),
      'Sat': now.subtract(Duration(days: now.weekday - 6)),
    };

    Map<String, int> mealCounts = {
      for (var day in dayMap.keys) day: 0
    };
    Map<String, double> calorieSums = {
      for (var day in dayMap.keys) day: 0.0
    };
    Map<String, String> dateMapping = {};

    for (var record in records) {
      String dayName = record['date']; // เช่น "Fri", "Sat", ฯลฯ
      DateTime? actualDate = dayMap[dayName];

      if (actualDate == null) {
        print("❌ Error: Unknown day name '$dayName'");
        continue;
      }

      String formattedDate = DateFormat('dd/MM/yyyy').format(actualDate);
      dateMapping[dayName] = formattedDate;

      int meals = (record['meals'] ?? 0) as int;
      double calories = (record['calories'] ?? 0.0) as double;

      mealCounts.update(dayName, (value) => value + meals, ifAbsent: () => meals);
      calorieSums.update(dayName, (value) => value + calories, ifAbsent: () => calories);
    }

    setState(() {
      _chartData = mealCounts.entries.map((entry) =>
          ChartData(entry.key, calorieSums[entry.key] ?? 0.0)).toList();
      _calculateSummary(mealCounts, calorieSums, dateMapping);
    });
  }

  void _calculateSummary(Map<String, int> mealCounts, Map<String, double> calorieSums, Map<String, String> dateMapping) {
    if (mealCounts.isNotEmpty && calorieSums.isNotEmpty) {
      final int avgMeal = (mealCounts.values.reduce((a, b) => a + b) / mealCounts.length).round();
      final int avgCalories = (calorieSums.values.reduce((a, b) => a + b) / calorieSums.length).round();

      var maxMealEntry = mealCounts.entries.reduce((a, b) => a.value > b.value ? a : b);
      var minMealEntry = mealCounts.entries.reduce((a, b) => a.value < b.value ? a : b);
      var maxCalorieEntry = calorieSums.entries.reduce((a, b) => a.value > b.value ? a : b);
      var minCalorieEntry = calorieSums.entries.reduce((a, b) => a.value < b.value ? a : b);

      // ✅ เรียงลำดับวันที่ก่อนใช้งาน
      List<String> allDates = dateMapping.values.toList();
      allDates.sort((a, b) => DateFormat('dd/MM/yyyy').parse(a).compareTo(DateFormat('dd/MM/yyyy').parse(b)));

      if (allDates.length > 1) {
        averageMealDate = '${allDates.first} - ${allDates.last}';
        averageCaloriesDate = '${allDates.first} - ${allDates.last}';
      } else if (allDates.isNotEmpty) {
        averageMealDate = allDates.first;
        averageCaloriesDate = allDates.first;
      } else {
        averageMealDate = 'No Data';
        averageCaloriesDate = 'No Data';
      }

      setState(() {
        averageMeal = avgMeal.toString();
        averageCalories = avgCalories.toString();

        maxMeal = maxMealEntry.value.toString();
        maxMealDate = dateMapping[maxMealEntry.key] ?? 'N/A';
        maxCalories = maxCalorieEntry.value.round().toString();
        maxCalorieDate = dateMapping[maxCalorieEntry.key] ?? 'N/A';

        minMeal = minMealEntry.value.toString();
        minMealDate = dateMapping[minMealEntry.key] ?? 'N/A';
        minCalories = minCalorieEntry.value.round().toString();
        minCalorieDate = dateMapping[minCalorieEntry.key] ?? 'N/A';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final foodProvider = Provider.of<FoodRecordProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Summary Graph',
          style: TextStyle(
            color: Colors.cyan,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: foodProvider.isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 10),
              SizedBox(
                height: 200,
                child: SfCartesianChart(
                  primaryXAxis: CategoryAxis(
                    labelRotation: 0, // แสดงข้อความแนวตรง
                  ),
                  series: <LineSeries<ChartData, String>>[
                    LineSeries<ChartData, String>(
                      dataSource: _chartData,
                      xValueMapper: (ChartData data, _) => data.x,
                      yValueMapper: (ChartData data, _) => data.y,
                      color: Colors.cyan,
                      markerSettings: MarkerSettings(isVisible: true),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              _buildSummaryBox('Average', averageMeal, averageMealDate, averageCalories, averageCaloriesDate),
              const SizedBox(height: 7),
              _buildSummaryBox('Max', maxMeal, maxMealDate, maxCalories, maxCalorieDate),
              const SizedBox(height: 7),
              _buildSummaryBox('Min', minMeal, minMealDate, minCalories, minCalorieDate),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryBox(
      String title,
      String mealValue, String mealDate,
      [String? kcalValue, String? kcalDate]) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Meals: $mealValue',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.cyan,
                ),
              ),
              Text(
                'Date: $mealDate',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.cyan,
                ),
              ),
            ],
          ),
          if (kcalValue != null && kcalDate != null) ...[
            const SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Calories: $kcalValue',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.cyan,
                  ),
                ),
                Text(
                  'Date: $kcalDate',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.cyan,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class ChartData {
  final String x;
  final double y;
  ChartData(this.x, this.y);
}
