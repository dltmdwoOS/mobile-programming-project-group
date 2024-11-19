import 'package:flutter/material.dart';
import '../widget/home_icon_widget.dart';
import 'travel_summary_screen.dart';

class TravelOptionScreen extends StatefulWidget {
  final String planName;
  final String country;
  final String state;
  final String currency;
  final String budget;
  final DateTime departureDate;
  final DateTime arrivalDate;
  final VoidCallback onPlanAdded;
  TravelOptionScreen({
    required this.planName,
    required this.country,
    required this.state,
    required this.currency,
    required this.budget,
    required this.departureDate,
    required this.arrivalDate,
    required this.onPlanAdded
  });

  @override
  _TravelOptionScreenState createState() => _TravelOptionScreenState();
}

class _TravelOptionScreenState extends State<TravelOptionScreen> {
  String? selectedCompanion;
  String? selectedStyle;

  // 선택 가능한 옵션 리스트
  final List<String> companions = ['Alone', 'With friend', 'with lover', 'with spouse', 'with children', 'with parents'];
  final List<String> styles = ['Experience·Activity', 'SNS Hot Place', 'With nature', 'With Famous Travel Attraction', 'Relax·Heal', 'Culture·Art·History', 'With Passionate Shopping', 'Mukbang'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Row(
        children: [
          Text('Select Travel Options'),
          Expanded(child: Container()),
          HomeIconWidget(hasQuestion: true),
        ],
      )),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ExpansionTile(
              initiallyExpanded: false,
              title: Padding(
                padding: const EdgeInsets.only(left: 50.0),
                child: Center(
                  child: Text(
                    'Selected Travel Details',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              children: [
                Column(
                  children: [
                    Text('Country: ${widget.country}'),
                    Text('State: ${widget.state}'),
                    Text('Currency: ${widget.currency}'),
                    Text('Budget: ${widget.budget}'),
                    Text('Departure date: ${widget.departureDate.toLocal().year}/${widget.departureDate.toLocal().month}/${widget.departureDate.toLocal().day}'),
                    Text('Arrival date: ${widget.arrivalDate.toLocal().year}/${widget.arrivalDate.toLocal().month}/${widget.arrivalDate.toLocal().day}')
                  ],
                )
              ],
            ),
            SizedBox(height: 20),

            Text(
              'What style of travel are you planning to take?',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Text('With whom'),
            Wrap(
              spacing: 8,
              children: companions.map((companion) {
                return ChoiceChip(
                  label: Text(companion),
                  selected: selectedCompanion == companion,
                  onSelected: (isSelected) {
                    setState(() {
                      selectedCompanion = isSelected ? companion : null;
                    });
                  },
                  selectedColor: Colors.blue,
                );
              }).toList(),
            ),
            SizedBox(height: 20),
            Text('Travel style'),
            Wrap(
              spacing: 8,
              children: styles.map((style) {
                return ChoiceChip(
                  label: Text(style),
                  selected: selectedStyle == style,
                  onSelected: (isSelected) {
                    setState(() {
                      selectedStyle = isSelected ? style : null;
                    });
                  },
                  selectedColor: Colors.blue,
                );
              }).toList(),
            ),
            SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: (selectedCompanion != null && selectedStyle != null) ? () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TravelSummaryPage(
                          planName: widget.planName,
                          country: widget.country,
                          state: widget.state,
                          currency: widget.currency,
                          budget: widget.budget,
                          departureDate: widget.departureDate,
                          arrivalDate: widget.arrivalDate,
                          companion: selectedCompanion!,
                          style: selectedStyle!,
                          onPlanAdded: widget.onPlanAdded
                        ),
                      ),
                    );
                  } : null,
                  child: Text('Complete'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}