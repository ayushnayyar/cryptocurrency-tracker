import 'package:flutter/material.dart';
import 'package:cryptocurrency_tracker/constants.dart';

class SettingsScreen extends StatefulWidget {
  static const id = 'settings_screen';

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Settings'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pop(context);
        },
        child: Icon(Icons.arrow_back),
      ),
      body: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            'Update Interval',
            style: TextStyle(fontSize: 18.0),
          ),
          Container(
            margin: EdgeInsets.only(left: 15.0),
            child: DropdownButton(
              elevation: 5,
              value: kDropdownValue,
              items: [3, 6, 9, 12, 15].map<DropdownMenuItem>((value) {
                return DropdownMenuItem(
                  value: value,
                  child: Text(
                    value.toString(),
                    style: TextStyle(fontSize: 18.0),
                  ),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  kDropdownValue = newValue;
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}
