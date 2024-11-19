import 'package:flutter/material.dart';
import 'service/shared_preferences_service.dart';
import 'widget/plan_list_tile.dart';
import 'widget/plan_add_button_widget.dart';



class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<String> planNames = [];

  @override
  void initState() {
    super.initState();
    _loadPlanNames();
  }
  Future<void> _loadPlanNames() async {
    List<String> loadedPlanNames = await SharedPrefUtil.getPlanNames();
    setState(() {
      planNames = loadedPlanNames;
    });
  }
  Future<void> _deletePlan(String planName) async {
    bool confirmDelete = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Alert'),
        content: Text('Are you sure you want to delete this plan?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Delete'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancel'),
          ),
        ],
      ),
    );
    if (confirmDelete) {
      setState(() {
        planNames.remove(planName);
      });
      await SharedPrefUtil.savePlanNames(planNames);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Screen'),
        actions: [
          PlanAddButton(onPlanAdded: () {
            _loadPlanNames();
          },),
        ],
      ),
      body: planNames.isEmpty
          ? Center(child: Text('Press add button to make plans!'))
          : ListView.builder(
        itemCount: planNames.length,
        itemBuilder: (context, index) {
          return Container(
              padding: EdgeInsets.symmetric(),
              child: PlanListTile(planName: planNames[index], onDelete: () => _deletePlan(planNames[index]))
          );
        },
      ),
    );
  }
}
