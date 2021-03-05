import 'package:cryptocurrency_tracker/screens/settings_screen.dart';
import 'package:cryptocurrency_tracker/screens/tracker_screen.dart';
import 'package:cryptocurrency_tracker/widgets/chat_message.dart';
import 'package:flutter/material.dart';
import 'package:cryptocurrency_tracker/widgets/bot_message.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

const List<String> cryptoList = ['BTC', 'ETH', 'LTC'];
var finalPrice;

const APIKey = '776554C4-FAAC-42AF-8FCC-DBB70BC0AA7D';
const URL = 'https://rest.coinapi.io/v1/exchangerate';
String selectedCurrency = 'USD';
String selectedCrypto = 'BTC';

class ChatScreen extends StatefulWidget {
  static const id = 'chat_screen';
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  Timer timer;
  final List _chats = [];
  final List trackerCurrencies = [];
  final List trackerPrices = [];
  final List trackerCryptoCurrencies = [];

  final _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  int questionCounter = 1;
  bool _activeSend = false;

  void _handleBotSubmit(String text) {
    BotMessage message = BotMessage(
      text: text,
      animationController: AnimationController(
        duration: Duration(milliseconds: 300),
        vsync: this,
        lowerBound: 0.5,
        upperBound: 1.0,
      ),
    );
    setState(() {
      _chats.insert(0, message);
    });
    message.animationController.forward();
  }

  @override
  void initState() {
    _handleBotSubmit(
        'Hi There!\n\nWould you like to add a Crypto Currency?\n\nType yes to add.');
    super.initState();
    timer = Timer.periodic(Duration(seconds: 3), (Timer t) => setState(() {}));
  }

  void _handleSubmit(String text) {
    _textController.clear();
    setState(() {
      _activeSend = false;
    });
    ChatMessage message = ChatMessage(
      text: text,
      animationController: AnimationController(
        duration: Duration(milliseconds: 300),
        vsync: this,
      ),
    );
    setState(() {
      _chats.insert(0, message);
    });
    _focusNode.requestFocus();
    message.animationController.forward();
    _botMessage(text);
  }

  Future _botMessage(String text) async {
    String response;
    if (questionCounter == 1) {
      if (text.toLowerCase() == 'yes') {
        response = 'Please enter a Crypto Currency\n\nFor Example: BTC, ETH...';
        questionCounter++;
      } else {
        response =
            'If you change your mind, type Yes to add a Crypto Currency!';
      }
    } else if (questionCounter == 2) {
      String crypto = text.toUpperCase();
      String requestURL = '$URL/$crypto/$selectedCurrency?apikey=$APIKey';
      http.Response checkCrypto = await http.get(requestURL);
      print(checkCrypto.statusCode);
      if (checkCrypto.statusCode == 200) {
        selectedCrypto = crypto;
        response =
            'Please enter a Currency to view the conversion rates\n\nFor Example:  USD, INR, GBP';
        questionCounter++;
      } else {
        response = 'Please enter a valid Crypto Currency';
      }
    } else if (questionCounter == 3) {
      String currency = text.toUpperCase();
      String requestURL2 = '$URL/$selectedCrypto/$currency?apikey=$APIKey';
      http.Response checkCurrency = await http.get(requestURL2);
      if (checkCurrency.statusCode == 200) {
        selectedCurrency = currency;
        var decodedData = jsonDecode(checkCurrency.body);
        var price = decodedData['rate'];
        finalPrice = price.toStringAsFixed(4);
        response =
            '$selectedCrypto = $finalPrice $selectedCurrency\n\n$selectedCrypto is added to the Tracker Screen!';
        trackerCurrencies.add(selectedCurrency);
        trackerPrices.add(finalPrice);
        trackerCryptoCurrencies.add(selectedCrypto);
        questionCounter++;
        Future.delayed(const Duration(milliseconds: 1000), () {
          setState(() {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => TrackerScreen(
                          currenciesList: trackerCurrencies,
                          cryptoCurrenciesList: trackerCryptoCurrencies,
                          pricesList: trackerPrices,
                        )));
          });
        });
        Future.delayed(const Duration(milliseconds: 1150), () {
          setState(() {
            if (questionCounter > 1) {
              questionCounter = 1;
              _handleBotSubmit(
                  'Would you like to add another Crypto Currency?\n\nType yes to add.');
            }
          });
        });
      } else {
        response = 'Please enter a valid Currency!';
      }
    }

    BotMessage message = BotMessage(
      text: response,
      animationController: AnimationController(
        duration: Duration(milliseconds: 300),
        vsync: this,
      ),
    );
    setState(() {
      _chats.insert(0, message);
    });
    message.animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Chat',
          style: TextStyle(fontSize: 25.0),
        ),
        actions: <Widget>[
          FlatButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TrackerScreen(
                    currenciesList: trackerCurrencies,
                    pricesList: trackerPrices,
                    cryptoCurrenciesList: trackerCryptoCurrencies,
                  ),
                ),
              );
              Future.delayed(const Duration(milliseconds: 200), () {
                if (questionCounter > 1) {
                  questionCounter = 1;
                  _handleBotSubmit(
                      'Would you like to add another Crypto Currency?\n\nType yes to add.');
                }
              });
            },
            child: Text(
              'Tracker',
              style: TextStyle(color: Colors.white, fontSize: 20.0),
            ),
          ),
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, SettingsScreen.id);
            },
            icon: Icon(Icons.settings),
          )
        ],
      ),
      body: Column(
        children: <Widget>[
          Flexible(
            child: ListView.builder(
              padding: EdgeInsets.all(8.0),
              itemBuilder: (context, index) => _chats[index],
              itemCount: _chats.length,
              reverse: true,
            ),
          ),
          SizedBox(
            height: 1.0,
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 10.0),
            child: Row(
              children: <Widget>[
                Flexible(
                  child: TextField(
                    onChanged: (text) {
                      setState(() {
                        _activeSend = text.length > 0;
                      });
                    },
                    controller: _textController,
                    onSubmitted: _activeSend ? _handleSubmit : null,
                    focusNode: _focusNode,
                    decoration:
                        InputDecoration.collapsed(hintText: 'Type a message'),
                  ),
                ),
                Container(
                  child: IconButton(
                    icon: Icon(
                      Icons.send,
                      color: _activeSend ? Colors.blue : Colors.black,
                    ),
                    onPressed: () => _activeSend
                        ? _handleSubmit(_textController.text)
                        : null,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    for (ChatMessage message in _chats) {
      message.animationController.dispose();
    }
    super.dispose();
  }
}
