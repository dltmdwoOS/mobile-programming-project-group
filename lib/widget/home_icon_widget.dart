import 'package:flutter/material.dart';
import 'package:mobile_programming_group/main.dart';
import 'package:mobile_programming_group/plan.dart';

class HomeIconWidget extends StatelessWidget {
  final bool hasQuestion;
  const HomeIconWidget({super.key, required this.hasQuestion});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 10),
      child: IconButton(
        icon: Icon(Icons.home_outlined),
        onPressed: () {
          if (hasQuestion){
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text("Go to home"),
                  content: Text("Are you sure you want to return to the home screen?\nYour progress will be reset."),
                  actions: [
                    TextButton(
                      child: Text("Yes"),
                      onPressed: () {
                        Navigator.of(context).popUntil((route) => route.isFirst);
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => TripPlanningScreen()),
                        );
                      },
                    ),
                    TextButton(
                      child: Text("No"),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                );
              },
            );
          }
          else{
            Navigator.of(context).popUntil((route) => route.isFirst);
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => TripPlanningScreen()),
            );
          }
        },
      ),
    );
  }
}
