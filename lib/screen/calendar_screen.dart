import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../widget/home_icon_widget.dart';
import 'travel_option_screen.dart';
class CalendarScreen extends StatefulWidget {
  final String planName;
  final String country;
  final String state;
  final String currency;
  final String budget;
  final VoidCallback onPlanAdded;
  CalendarScreen({
    required this.planName,
    required this.country,
    required this.state,
    required this.currency,
    required this.budget,
    required this.onPlanAdded
  });

  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime? _firstSelectedDate;
  DateTime? _secondSelectedDate;
  DateTime _focusedDay = DateTime.now();

  @override
  Widget build(BuildContext context) {
    // Get the current date to restrict date selection to future dates
    DateTime now = DateTime.now();

    // Calculate the start and end dates of the range
    DateTime? startDate = _firstSelectedDate != null && _secondSelectedDate != null
        ? (_firstSelectedDate!.isBefore(_secondSelectedDate!)
        ? _firstSelectedDate
        : _secondSelectedDate)
        : null;
    DateTime? endDate = _firstSelectedDate != null && _secondSelectedDate != null
        ? (_firstSelectedDate!.isAfter(_secondSelectedDate!)
        ? _firstSelectedDate
        : _secondSelectedDate)
        : null;

    return Scaffold(
      appBar: AppBar(title: Row(
        children: [
          Text('Select Date'),
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
                    Text('Budget: ${widget.budget}')
                  ],
                )
              ],
            ),
            SizedBox(height: 20),

            // Calendar widget
            TableCalendar(
              firstDay: now, // Restrict to today and future dates
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) =>
              isSameDay(_firstSelectedDate, day) || isSameDay(_secondSelectedDate, day),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _focusedDay = focusedDay;

                  // Handle the date selection
                  if (_firstSelectedDate == null) {
                    // Set the first selected date
                    _firstSelectedDate = selectedDay;
                  } else if (_secondSelectedDate == null) {
                    // Set the second selected date
                    _secondSelectedDate = selectedDay;
                  } else {
                    // Reset the selection if both dates are selected
                    _firstSelectedDate = selectedDay;
                    _secondSelectedDate = null;
                  }
                });
              },
              calendarStyle: CalendarStyle(
                todayDecoration: BoxDecoration(
                  color: Colors.blueAccent,
                  shape: BoxShape.circle,
                ),
                selectedDecoration: BoxDecoration(
                  color: Colors.deepOrange,
                  shape: BoxShape.circle,
                ),
                rangeHighlightColor: Colors.redAccent.withOpacity(0.3),
                withinRangeDecoration: BoxDecoration(
                  color: Colors.redAccent.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
              ),
              rangeStartDay: startDate,
              rangeEndDay: endDate,
              headerStyle: HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: () {
                    if (_firstSelectedDate != null && _secondSelectedDate != null) {
                      int daysDifference = _firstSelectedDate!.isBefore(_secondSelectedDate!)
                          ? _secondSelectedDate!.difference(_firstSelectedDate!).inDays
                          : _firstSelectedDate!.difference(_secondSelectedDate!).inDays;
                      if (daysDifference > 10){
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text("Date Error"),
                              content: Text("Departure and arrival dates must be within 10 days of each other."),
                              actions: [
                                TextButton(
                                  child: Text("Check"),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            );
                          },
                        );
                        return;
                      }
                      DateTime departureDate = _firstSelectedDate!.isBefore(_secondSelectedDate!)
                          ? _firstSelectedDate!
                          : _secondSelectedDate!;
                      DateTime arrivalDate = _firstSelectedDate!.isAfter(_secondSelectedDate!)
                          ? _firstSelectedDate!
                          : _secondSelectedDate!;


                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TravelOptionScreen(
                            planName: widget.planName,
                            country: widget.country,
                            state: widget.state,
                            currency: widget.currency,
                            budget: widget.budget,
                            departureDate: departureDate,
                            arrivalDate: arrivalDate,
                            onPlanAdded: widget.onPlanAdded
                          ),
                        ),
                      );
                    }
                  },
                  child: Text('Check date'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

