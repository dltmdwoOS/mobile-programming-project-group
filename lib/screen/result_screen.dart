import 'dart:math';
import 'package:flutter/material.dart';
import '../service/file_service.dart';
import '../widget/home_icon_widget.dart';

class ResultScreen extends StatefulWidget {
  final String planName;
  ResultScreen({required this.planName});
  @override
  _ResultScreenState createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  Map<String, Map<String, dynamic>>? data;
  List<String> linesIfItNotExists = [
    "Embrace the freedom to explore the world",
    "Wander without boundaries, let your spirit roam",
    "Set your soul free with each new adventure",
    "Discover the beauty of traveling without limits",
    "Go where the road takes you, no plans needed",
    "Journey beyond the maps and into the unknown",
    "Travel with no strings attached, just you and the world",
    "Find freedom in every step you take",
    "Let your heart lead the way to new horizons",
    "Venture freely and live life without a compass"
  ];

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    try {
      final path = "outputs/${widget.planName}.txt";
      Map<String, Map<String, dynamic>>? result = await readJsonFromFile(path);

      if (result == null) {
        throw Exception("Data is null. Check file content or path.");
      }

      setState(() {
        data = result;
      });
    } catch (e) {
      print("Error loading data: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to load data: $e")),
      );
    }
  }
  int getRandomNumberTen() {
    final random = Random();
    return random.nextInt(10);
  }
  @override
  Widget build(BuildContext context) {
    if (data == null) {
      return Scaffold(
        appBar: AppBar(title: Row(
          children: [
            Text('Recommended Plan'),
            Expanded(child: Container()),
            HomeIconWidget(hasQuestion: false),
          ],
        )),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    print("before sort : "+data!.keys.toList().length.toString());
    List<String> sortedKeys = data!.keys.toList()
      ..sort((a, b) {
        DateTime dateA = DateTime.parse('${a.split('/')[0]}-${a.split('/')[1].padLeft(2, '0')}-${a.split('/')[2].padLeft(2, '0')}');
        DateTime dateB = DateTime.parse('${b.split('/')[0]}-${b.split('/')[1].padLeft(2, '0')}-${b.split('/')[2].padLeft(2, '0')}');
        return dateA.compareTo(dateB);
      });

    return Scaffold(
      appBar: AppBar(title: Row(
        children: [
          Text('Recommended Plan'),
          Expanded(child: Container()),
          HomeIconWidget(hasQuestion: false),
        ],
      )),
      body: ListView.builder(
        itemCount: sortedKeys.length,
        itemBuilder: (context, index) {
          String date = sortedKeys[index];
          Map<String, dynamic> daySchedule = data![date]!;

          return Card(
            margin: EdgeInsets.all(10),
            child: ExpansionTile(
              title: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  date,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 4, horizontal: 16),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      daySchedule.containsKey('Morning')
                          ? 'Morning: ${daySchedule['Morning']}'
                          : 'Morning: ${linesIfItNotExists[getRandomNumberTen()]}',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 4, horizontal: 16),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      daySchedule.containsKey('Afternoon')
                          ? 'Afternoon: ${daySchedule['Afternoon']}'
                          : 'Afternoon: ${linesIfItNotExists[getRandomNumberTen()]}',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 4, horizontal: 16),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      daySchedule.containsKey('Night')
                          ? 'Night: ${daySchedule['Night']}'
                          : 'Night: ${linesIfItNotExists[getRandomNumberTen()]}',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

}
