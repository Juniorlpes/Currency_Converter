import 'package:conversor/helperdb/currency_db.dart';
import 'package:flutter/material.dart';
import 'main_screen.dart';
import 'model/api_request.dart';

void main() async {
  runApp(MaterialApp(
    home: Home(),
    theme: ThemeData(
      hintColor: Colors.orange,
      primaryColor: Colors.white,
    ),
  ));
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  CurrencyHelper helper = CurrencyHelper();

  ApiRequest request = ApiRequest();

  double dolar;
  double euro;
  double btc;
  double selic;
  double cdi;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: Text(
            " Conversor ",
            style: TextStyle(fontSize: 25.0),
          ),
          backgroundColor: Colors.orange,
          centerTitle: true,
        ),
        body: FutureBuilder<Map> (
            future: request.getData(),
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.none:
                case ConnectionState.waiting:
                  return Center(
                    child: Text(
                      "Carregando dados...",
                      style: TextStyle(color: Colors.orange, fontSize: 25.0),
                      textAlign: TextAlign.center,
                    ),
                  );
                default:
                  if(!snapshot.hasError){
                    dolar = snapshot.data["results"]["currencies"]["USD"]["buy"];
                    euro = snapshot.data["results"]["currencies"]["EUR"]["buy"];
                    btc = snapshot.data["results"]["currencies"]["BTC"]["buy"];
                    selic = snapshot.data["results"]["taxes"][0]["selic"];
                    cdi = snapshot.data["results"]["taxes"][0]["cdi"];
                    _saveCurrencies(snapshot.data["results"]["currencies"]["USD"]["buy"],
                        snapshot.data["results"]["currencies"]["EUR"]["buy"],
                        snapshot.data["results"]["currencies"]["BTC"]["buy"],
                        snapshot.data["results"]["taxes"][0]["selic"],
                        snapshot.data["results"]["taxes"][0]["cdi"]);
                    return MainScreen();
                  }
                  else if(snapshot.hasError)
                    return MainScreen();
              }
              return null;
            })
    );
  }

  void _saveCurrencies(double dolar, double euro, double btc, double selic, double cdi) async{
    helper.deleteCurrencies();

    Currency c = Currency("dolar", dolar);
    helper.saveCurrency(c);

    c = Currency("euro", euro);
    helper.saveCurrency(c);

    c = Currency("btc", btc);
    helper.saveCurrency(c);

    c = Currency("selic", selic);
    helper.saveCurrency(c);

    c = Currency("cdi", cdi);
    helper.saveCurrency(c);
  }

}
