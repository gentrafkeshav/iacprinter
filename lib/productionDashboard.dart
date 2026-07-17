import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iac_login_app/AppHeader.dart'; // Import your custom header

class ProductionDashboard extends StatelessWidget {
  const ProductionDashboard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[800],
      appBar: AppHeader(), // Use custom header
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                DashboardCard(title: "TOTAL PRODUCTION", value: "2379", color: Colors.blue),
                DashboardCard(title: "TOTAL MACHINES", value: "20", color: Colors.green),
                DashboardCard(title: "TODAYS PRODUCTION", value: "7", color: Colors.purple),
                DashboardCard(title: "TODAYS DISPATCH", value: "0", color: Colors.orange),
              ],
            ),
            SizedBox(height: 20),
            Expanded(
              child: Row(
                children: [
                  Expanded(child: ProductionChart(title: "Machine Production in Three Shifts")),
                  SizedBox(width: 10), // Added spacing between charts
                  Expanded(child: ProductionChart(title: "Machine Part Wise Production in Three Shifts")),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class DashboardCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;

  const DashboardCard({
    Key? key,
    required this.title,
    required this.value,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220, // Increased width for better layout
      height: 130, // Increased height for better spacing
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black45, blurRadius: 6, offset: Offset(2, 3)), // Shadow for better UI
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
            maxLines: 2, // Prevents text overflow
            overflow: TextOverflow.ellipsis, // Adds "..." if text is too long
          ),
          SizedBox(height: 10),
          Text(
            value,
            style: GoogleFonts.poppins(fontSize: 30, color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

// ✅ FIXED: Added the missing `ProductionChart` class below
class ProductionChart extends StatelessWidget {
  final String title;

  const ProductionChart({
    Key? key,
    required this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Expanded(
              child: BarChart(
                BarChartData(
                  barGroups: [
                    BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: 400, color: Colors.blue)]),
                    BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: 600, color: Colors.red)]),
                    BarChartGroupData(x: 3, barRods: [BarChartRodData(toY: 200, color: Colors.green)]),
                  ],
                  titlesData: FlTitlesData(show: false),
                  borderData: FlBorderData(show: false),
                  barTouchData: BarTouchData(enabled: false),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
