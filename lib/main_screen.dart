import 'package:flutter/material.dart';
import 'package:conversor/helperdb/currency_db.dart';


class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {

  CurrencyHelper helper = CurrencyHelper();

  final realController = TextEditingController();
  final dolarController = TextEditingController();
  final euroController = TextEditingController();
  final btcController = TextEditingController();

  double dolar;
  double euro;
  double btc;
  double selic;
  double cdi;

  @override
  Widget build(BuildContext context) {

    return FutureBuilder(
      future: _getCurrencies(),
      builder: (context, snapshot){
        switch(snapshot.connectionState){
          case ConnectionState.none:
          case ConnectionState.waiting:
            return Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.amber)),);
          default:
            if(snapshot.hasError)
              Center(
                child: Text(
                  "Erro ao carregar :(",
                  style: TextStyle(
                      color: Colors.orange, fontSize: 25.0),
                  textAlign: TextAlign.center,
                ),
              );
            else
              return SingleChildScrollView(
                padding: EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Icon(Icons.monetization_on, color: Colors.orange,size: 150,),
                    buildTextField("Reais", "R\$ ", realController, _realChanged),
                    Divider(),
                    buildTextField("USD", "U\$ ", dolarController, _dolarChanged),
                    Divider(),
                    buildTextField("Euro", "€ ", euroController,_euroChanged),
                    Divider(),
                    buildTextField("Bitcoin", "BTC ", btcController, _btcChanged),
                    Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text("SELIC: $selic %  ", style:  TextStyle(color: Colors.orange, fontSize: 20.0),),
                        Text("CDI: $cdi %", style:  TextStyle(color: Colors.orange, fontSize: 20.0)),
                      ],
                    ),
                    Padding(padding: EdgeInsets.all(20))
                  ],
                ),
              );
            return Container();
        }
      }
    );
  }

  Future _getCurrencies() async{
    try {
      Currency c = await helper.getCurrency("dolar");
      dolar = c.value;
      c = await helper.getCurrency("euro");
      euro = c.value;
      c = await helper.getCurrency("btc");
      btc = c.value;
      c = await helper.getCurrency("selic");
      this.selic = c.value;
      c = await helper.getCurrency("cdi");
      this.cdi = c.value;
    }catch(e){
      throw(e);
    }
  }

  void _realChanged(String txt){
    if(txt.isEmpty){
      dolarController.text = "";
      euroController.text = "";
      btcController.text = "";
    }
    double real = double.parse(txt);
    dolarController.text = (real/dolar).toStringAsFixed(2);
    euroController.text = (real/euro).toStringAsFixed(2);
    btcController.text = (real/btc).toStringAsFixed(4);
  }
  void _dolarChanged(String txt){
    if(txt.isEmpty){
      realController.text = "";
      euroController.text = "";
      btcController.text = "";
    }
    double dolar = double.parse(txt);
    realController.text = (dolar * this.dolar).toStringAsFixed(2);
    euroController.text = (dolar * this.dolar / euro).toStringAsFixed(2);
    btcController.text = (dolar * this.dolar / btc).toStringAsFixed(4);
  }
  void _euroChanged(String txt){
    if(txt == ""){
      realController.text = "";
      dolarController.text = "";
      btcController.text = "";
    }
    double euro = double.parse(txt);
    realController.text = (euro * this.euro).toStringAsFixed(2);
    dolarController.text = (euro * this.euro / dolar).toStringAsFixed(2);
    btcController.text = (euro * this.euro / btc).toStringAsFixed(4);
  }
  void _btcChanged(String txt){
    if(txt == ""){
      realController.text = "";
      dolarController.text = "";
      euroController.text = "";
    }
    double btc = double.parse(txt);
    realController.text = (btc * this.btc).toStringAsFixed(2);
    dolarController.text = (btc * this.btc / dolar).toStringAsFixed(2);
    euroController.text = (btc * this.btc / euro).toStringAsFixed(2);
  }

}

Widget buildTextField(String label, String prefix, TextEditingController c, Function f){
  return TextField(
    controller: c,
    decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.orange, fontSize: 20,),
        border: OutlineInputBorder(),
        prefixText: prefix
    ),
    style: TextStyle(color: Colors.orange,fontSize: 25.0, ),
    onChanged: f,
    keyboardType: TextInputType.number,
  );
}
