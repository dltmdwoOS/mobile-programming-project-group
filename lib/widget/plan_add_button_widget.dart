import 'package:flutter/material.dart';

import 'dart:convert';
import '../screen/select_location_screen.dart';
import '../service/shared_preferences_service.dart';

class PlanAddButton extends StatefulWidget {
  final VoidCallback onPlanAdded;
  PlanAddButton({required this.onPlanAdded});

  @override
  _PlanAddButtonState createState() => _PlanAddButtonState();
}

class _PlanAddButtonState extends State<PlanAddButton> {


  @override
  void initState() {
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.add),
      onPressed: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            TextEditingController planNameController = TextEditingController();
            return AlertDialog(
              title: Text("Add plan"),
              content: TextField(
                controller: planNameController,
                decoration: InputDecoration(hintText: "Enter your plan name..."),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text("Cancel"),
                ),
                TextButton(
                  onPressed: () async {
                    List<String> planNames = await SharedPrefUtil.getPlanNames();
                    String planName = planNameController.text;
                    if (planName.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Enter your plan name.")),
                      );
                    } else if (!RegExp(r'^[a-zA-Z0-9]+$').hasMatch(planName)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Only alphabets and numbers are allowed.")),
                      );
                    } else if (planName.length > 20) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Plan name cannot exceed 20 characters.")),
                      );
                    } else if (planNames.contains(planName)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("The plan that already exists.")),
                      );
                    } else {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SelectLocationScreen(planName:planName, onPlanAdded: widget.onPlanAdded)),
                      );
                    }
                  },
                  child: Text("Next"),
                ),
              ],
            );
          },
        );
      },
    );
  }
}