// currency_picker_widget.dart
import 'package:flutter/material.dart';
import 'package:currency_picker/currency_picker.dart';

Future<void> showCustomCurrencyPicker(BuildContext context, Function(String) onCurrencySelected) async {
  showCurrencyPicker(
    context: context,
    showFlag: true,
    showSearchField: true,
    onSelect: (Currency currency) {
      onCurrencySelected(currency.code);
    },
    currencyFilter: <String>['EUR', 'GBP', 'USD', 'AUD', 'CAD', 'JPY', 'HKD', 'CHF', 'SEK', 'ILS'],
  );
}
