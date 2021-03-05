import 'package:cryptocurrency_tracker/constants.dart';
import 'package:cryptocurrency_tracker/screens/chat_screen.dart';
import 'package:cryptocurrency_tracker/screens/settings_screen.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'chat_screen.dart';
import 'settings_screen.dart';

class TrackerScreen extends StatefulWidget {
  TrackerScreen({
    this.cryptoCurrenciesList,
    this.currenciesList,
    this.pricesList,
  });
  final List cryptoCurrenciesList;
  final List pricesList;
  final List currenciesList;
  @override
  _TrackerScreenState createState() => _TrackerScreenState();
}

Timer timer;

class _TrackerScreenState extends State<TrackerScreen> {
  void updatePrices() async {
    for (int i = 0; i < widget.pricesList.length; i++) {
      String requestURL =
          '$URL/${widget.cryptoCurrenciesList[i]}/${widget.currenciesList[i]}?apikey=$APIKey';
      http.Response response = await http.get(requestURL);
      if (response.statusCode == 200) {
        var decodedData = jsonDecode(response.body);
        var price = decodedData['rate'];

        setState(() {
          if (widget.pricesList.isNotEmpty) {
            finalPrice = price.toStringAsFixed(5);
            widget.pricesList[i] = finalPrice;
          }
        });

        print(finalPrice);
      } else {
        throw Exception('API Request Limit Reached');
      }
    }
  }

  @override
  void initState() {
    super.initState();

    timer = Timer.periodic(Duration(seconds: kDropdownValue), (Timer timer) {
      updatePrices();
    });
  }

  @override
  void deactivate() {
    if (timer.isActive) {
      timer.cancel();
    } else {}
    super.deactivate();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            timer.cancel();
            Navigator.pop(context);
          },
        ),
        title: Text('Tracker'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              Navigator.pushNamed(context, SettingsScreen.id);
            },
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          SizedBox(
            height: 10.0,
          ),
          Container(
            padding: EdgeInsets.symmetric(vertical: 10.0),
            child: Center(
              child: Text(
                'Currencies',
                style: TextStyle(fontSize: 30.0),
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.only(bottom: 10.0),
            child: Center(
              child: Text(
                'Swipe to dismiss',
                style: TextStyle(fontSize: 15.0),
              ),
            ),
          ),
          Flexible(
            child: widget.currenciesList.isNotEmpty
                ? ListView.builder(
                    itemBuilder: (context, index) {
                      final item = widget.currenciesList[index];
                      return Dismissible(
                        background: Container(color: Colors.red),
                        key: Key(item),
                        onDismissed: (direction) {
                          setState(() {
                            widget.currenciesList.removeAt(index);
                            widget.pricesList.removeAt(index);
                            widget.cryptoCurrenciesList.removeAt(index);
                          });
                          Scaffold.of(context).showSnackBar(
                              SnackBar(content: Text("Currency Deleted")));
                        },
                        child: Card(
                          elevation: 3.0,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: ListTile(
                              title: Center(
                                child: Text(
                                  widget.cryptoCurrenciesList[index],
                                  style: TextStyle(fontSize: 24.0),
                                ),
                              ),
                              subtitle: Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8.0),
                                child: Center(
                                  child: Text(
                                    '${widget.pricesList[index]} ${widget.currenciesList[index]}',
                                    style: TextStyle(fontSize: 18.0),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                    itemCount: widget.pricesList.length,
                  )
                : Padding(
                    padding: EdgeInsets.only(
                        top: MediaQuery.of(context).size.height * 0.40),
                    child: Text(
                      'No Currencies Added!',
                      style: TextStyle(fontSize: 17.0),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
