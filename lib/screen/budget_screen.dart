import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import '../widget/currency_widget.dart';
import '../widget/home_icon_widget.dart';
import 'calendar_screen.dart';

class BudgetScreen extends StatefulWidget {
  final String planName;
  final String country;
  final String state;
  final VoidCallback onPlanAdded;
  BudgetScreen({required this.planName, required this.country, required this.state, required this.onPlanAdded});

  @override
  _Budgetwidget createState() => _Budgetwidget();
}

class _Budgetwidget extends State<BudgetScreen> {
  TextEditingController budgetController = TextEditingController();
  String? selectedCurrency;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Row(
        children: [
          Text('Budget'),
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
                    Text('State: ${widget.state}')
                  ],
                )
              ],
            ),
            SizedBox(height: 20),

            // 통화 선택 버튼
            Text(
              'Select Currency',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                ElevatedButton(
                  onPressed: () {
                    showCustomCurrencyPicker(
                      context,
                          (selectedCurrencyCode) {
                        setState(() {
                          selectedCurrency = selectedCurrencyCode;
                        });
                      },
                    );
                  },
                  child: Text(selectedCurrency == null
                      ? 'Select Currency'
                      : 'Selected Currency: $selectedCurrency'),
                ),
              ],
            ),
            SizedBox(height: 20),

            // 예산 입력 필드
            Text(
              'Enter Budget',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            TextField(
              controller: budgetController,
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly
              ],
              decoration: InputDecoration(
                labelText: 'Budget',
                border: OutlineInputBorder(),
              ),
              enabled: selectedCurrency != null, // 통화 선택 후 활성화
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: () {
                    String budget = budgetController.text;
                    if (budget.isNotEmpty && selectedCurrency != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CalendarScreen(
                            planName: widget.planName,
                            country: widget.country,
                            state: widget.state,
                            currency: selectedCurrency!,
                            budget: budget,
                            onPlanAdded: widget.onPlanAdded
                          ),
                        ),
                      );
                    }
                  },
                  child: Text('Next'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
