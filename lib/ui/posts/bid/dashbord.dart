import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:charts_flutter/flutter.dart' as charts;

class DashboardPage extends StatefulWidget {
  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final DatabaseReference _databaseReference =
      FirebaseDatabase.instance.reference().child('product_bids');

  int runningBids = 0;
  int completedBids = 0;
  int totalValueOfCompletedBids = 0;

  List<TimeSeriesBidData> runningData = [];
  List<TimeSeriesBidData> completedData = [];

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  void fetchData() {
    _databaseReference.onValue.listen((event) {
      DataSnapshot snapshot = event.snapshot;
      if (snapshot.value != null && snapshot.value is Map<dynamic, dynamic>) {
        // Clear previous data
        runningBids = 0;
        completedBids = 0;
        totalValueOfCompletedBids = 0;
        runningData.clear();
        completedData.clear();

        // Get all bids
        Map<dynamic, dynamic> bids = snapshot.value as Map<dynamic, dynamic>;

        // Current time in milliseconds since epoch
        int currentTime = DateTime.now().millisecondsSinceEpoch;

        // Iterate through each bid
        bids.forEach((key, value) {
          // Check if the bid is still running or completed
          int timestamp = value['timestamp'];
          if (currentTime < timestamp) {
            // Running bid
            runningBids++;
          } else {
            // Completed bid
            completedBids++;
            // Calculate total value of completed bids
            int winningBidPrice = value['bidAmount'];
            int quantityOfProducts =
                1; // Replace this with the actual quantity of products if available in the data
            totalValueOfCompletedBids += (winningBidPrice * quantityOfProducts);
          }

          // Create data points for time series chart
          DateTime bidTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
          runningData.add(TimeSeriesBidData(bidTime, runningBids));
          completedData.add(TimeSeriesBidData(bidTime, completedBids));
        });
        // Update the UI with new data
        setState(() {});
      }
    });
  }

  List<charts.Series<TimeSeriesBidData, DateTime>> _createSampleData() {
    return [
      charts.Series<TimeSeriesBidData, DateTime>(
        id: 'Running Bids',
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
        domainFn: (TimeSeriesBidData data, _) => data.time,
        measureFn: (TimeSeriesBidData data, _) => data.value,
        data: runningData,
      ),
      charts.Series<TimeSeriesBidData, DateTime>(
        id: 'Completed Bids',
        colorFn: (_, __) => charts.MaterialPalette.red.shadeDefault,
        domainFn: (TimeSeriesBidData data, _) => data.time,
        measureFn: (TimeSeriesBidData data, _) => data.value,
        data: completedData,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Dashboard'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Display statistics

            Text(
              'Running Bids: $runningBids',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue),
            ),
            Text(
              'Completed Bids: $completedBids',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.green),
            ),
            Text(
              'Total Value of Completed Bids: \$$totalValueOfCompletedBids',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange),
            ),
            // Display line chart
            Expanded(
              child: charts.TimeSeriesChart(
                _createSampleData(),
                animate: true,
                dateTimeFactory: const charts.LocalDateTimeFactory(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TimeSeriesBidData {
  final DateTime time;
  final int value;

  TimeSeriesBidData(this.time, this.value);
}
