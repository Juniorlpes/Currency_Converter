import 'package:conversor/helperdb/currency_db.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert'; //usar o json

const request = "https://api.hgbrasil.com/finance?format=json&key=c8d612a9"; //constante

void main() async {
  //http.Response response = await http.get(request); /*a resposta ela nn vem na hora,
  //nesse caso está esperando de fato e armanzenando em response*/
  //jsonDecode(response.body); /*a responsta vem "desorganizada", por isso usa o json*/

  runApp(MaterialApp(
    home: Home(),
    theme: ThemeData(
        hintColor: Colors.orange,
        primaryColor: Colors.white
    ),
  ));
}

Future<Map> getData() async {
  http.Response response = await http.get(request);
  return json.decode(response.body);
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  CurrencyHelper helper = CurrencyHelper();

  final realController = TextEditingController();
  final dolarController = TextEditingController();
  final euroController = TextEditingController();
  final btcController = TextEditingController();

  double dolar; //dolar em real (vindo do link)
  double euro; //msm coisa
  double btc;
  double selic;
  double cdi;

  void _realChanged(String txt){
    double real = double.parse(txt);
    dolarController.text = (real/dolar).toStringAsFixed(2);//esse dolar é o declarado aí em cima
    euroController.text = (real/euro).toStringAsFixed(2);//"
    btcController.text = (real/btc).toStringAsFixed(4);
  }
  void _dolarChanged(String txt){
    double dolar = double.parse(txt);
    realController.text = (dolar * this.dolar).toStringAsFixed(2);//esse é o local e o de cima
    euroController.text = (dolar * this.dolar / euro).toStringAsFixed(2);
    btcController.text = (dolar * this.dolar / btc).toStringAsFixed(4);
  }
  void _euroChanged(String txt){
    double euro = double.parse(txt);
    realController.text = (euro * this.euro).toStringAsFixed(2);
    dolarController.text = (euro * this.euro / dolar).toStringAsFixed(2);
    btcController.text = (euro * this.euro / btc).toStringAsFixed(4);
  }
  void _btcChanged(String txt){
    double btc = double.parse(txt);
    realController.text = (btc * this.btc).toStringAsFixed(2);
    dolarController.text = (btc * this.btc / dolar).toStringAsFixed(2);
    euroController.text = (btc * this.btc / euro).toStringAsFixed(2);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //permite a barra de cima
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
          //diz q terá algo no futuro
            future: getData(), //diz oq será
            builder: (context, snapshot) {
              //função anonima
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
                    return _createMainScream();
                  }
                  else if(snapshot.hasError)
                    try{
                      _getCurrencies();
                      return _createMainScream();
                    }
                    catch(e) {
                      return Center(
                        child: Text(
                          "Erro ao carregar :(",
                          style: TextStyle(
                              color: Colors.orange, fontSize: 25.0),
                          textAlign: TextAlign.center,
                        ),
                      );
                    }
              }
            })
    );
  }

  Widget _createMainScream(){
    return SingleChildScrollView(
      padding: EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch, //alargar pra preencher tudo (ficar no centro)
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
          )
        ],
      ),
    );
  }

  void _getCurrencies() async{
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

