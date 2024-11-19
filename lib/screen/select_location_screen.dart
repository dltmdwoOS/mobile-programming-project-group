import 'package:csc_picker/csc_picker.dart';
import 'package:flutter/material.dart';
import '../widget/home_icon_widget.dart';
import 'budget_screen.dart';

class SelectLocationScreen extends StatefulWidget {
  final String planName;
  final VoidCallback onPlanAdded;
  SelectLocationScreen({required this.planName, required this.onPlanAdded});
  @override
  _SelectLocationScreenState createState() => _SelectLocationScreenState();
}

class _SelectLocationScreenState extends State<SelectLocationScreen> {
  String countryValue = "";
  String stateValue = "";
  String cityValue = "";
  String noStateMessage = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Row(
        children: [
          Text('Select Location'),
          Expanded(child: Container()),
          HomeIconWidget(hasQuestion: true),
        ],
      )),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CSCPicker(
              /*
              dropdownDecoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(5),
              ),
              selectedItemStyle: TextStyle(
                color: Colors.white,
              ),
              dropdownHeadingStyle: TextStyle(
                color: Colors.white,
              ),
              dropdownItemStyle: TextStyle(
                color: Colors.white,
              ),*/
              showStates: true,
              showCities: false,
              flagState: CountryFlag.SHOW_IN_DROP_DOWN_ONLY,

              onCountryChanged: (value) {
                setState(() {
                  countryValue = value;
                  // Check if the selected country has no states
                  if (isCountryWithoutStates(countryValue)) {
                    noStateMessage = "$countryValue does not have a state.";
                  } else {
                    noStateMessage = ""; // Clear message if states are available
                  }
                });
              },
              onStateChanged: (value) {
                setState(() {
                  stateValue = value ?? "";
                });
              },
              onCityChanged: (value) {
                setState(() {
                  cityValue = value ?? "";
                });
              },
            ),
            // Display the message below the country picker
            SizedBox(height: 10), // Add some space
            if (noStateMessage.isNotEmpty)
              Text(
                noStateMessage,
                style: TextStyle(color: Colors.red), // Change text color if desired
              ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                bool isCountrySelected = countryValue.isNotEmpty;
                bool isStateSelected = stateValue.isNotEmpty || isCountryWithoutStates(countryValue);

                if (isCountrySelected && isStateSelected) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BudgetScreen(
                        planName: widget.planName,
                        country: countryValue,
                        state: stateValue,
                        onPlanAdded: widget.onPlanAdded
                      ),
                    ),
                  );
                }
              },
              child: Text('Check location'),
            ),
          ],
        ),
      ),
    );
  }

  bool isCountryWithoutStates(String country) {
    // List of countries without states
    const countriesWithoutStates = [
      "Aland Islands",
      "American Samoa",
      "Anguilla",
      "Aruba",
      "Ascension Island",
      "Bahamas",
      "Bermuda",
      "Bonaire, Sint Eustatius and Saba",
      "British Indian Ocean Territory",
      "Cayman Islands",
      "Christmas Island",
      "Cocos (Keeling) Islands",
      "Cook Islands",
      "Curacao",
      "Falkland Islands",
      "Faroe Islands",
      "French Guiana",
      "French Polynesia",
      "Gibraltar",
      "Greenland",
      "Guadeloupe",
      "Hong Kong",
      "Isle of Man",
      "Jersey",
      "Montserrat",
      "New Caledonia",
      "Niue",
      "Northern Mariana Islands",
      "Pitcairn Islands",
      "Puerto Rico",
      "Reunion",
      "Saint Barthélemy",
      "Saint Helena",
      "Saint Martin",
      "Svalbard",
      "Tokelau",
      "Turks and Caicos Islands",
      "United States Virgin Islands",
      "Wallis and Futuna",
    ];

    return countriesWithoutStates.contains(country);
  }
}