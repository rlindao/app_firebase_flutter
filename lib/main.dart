import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import './home.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Pets',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Registrar mascota'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
          child: SingleChildScrollView(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text("Registra tu mascota ",
                  style: TextStyle(
                      fontWeight: FontWeight.w200,
                      fontSize: 30,
                      fontFamily: 'Roboto',
                      fontStyle: FontStyle.italic)),
              RegisterPet(),
            ]),
      )),
    );
  }
}

class RegisterPet extends StatefulWidget {
  RegisterPet({Key key}) : super(key: key);

  @override
  _RegisterPetState createState() => _RegisterPetState();
}

class _RegisterPetState extends State<RegisterPet> {
  final _formKey = GlobalKey<FormState>();
  final listOfPets = ["Gato", "Perro", "Conejo"];
  String dropdownValue = 'Gato';
  final nameController = TextEditingController();
  final ageController = TextEditingController();
  final dbRef = FirebaseDatabase.instance.reference().child("mascotas");

  @override
  Widget build(BuildContext context) {
    return Form(
        key: _formKey,
        child: SingleChildScrollView(
            child: Column(children: <Widget>[
          Padding(
            padding: EdgeInsets.all(20.0),
            child: TextFormField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: "nombre",
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              // The validator receives the text that the user has entered.
              validator: (value) {
                if (value.isEmpty) {
                  return 'Ingrese el nombre';
                }
                return null;
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.all(20.0),
            child: DropdownButtonFormField(
              value: dropdownValue,
              icon: Icon(Icons.arrow_downward),
              decoration: InputDecoration(
                labelText: "Tipo",
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              items: listOfPets.map((String value) {
                return new DropdownMenuItem<String>(
                  value: value,
                  child: new Text(value),
                );
              }).toList(),
              onChanged: (String newValue) {
                setState(() {
                  dropdownValue = newValue;
                });
              },
              validator: (value) {
                if (value.isEmpty) {
                  return 'Seleccione el tipo';
                }
                return null;
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.all(20.0),
            child: TextFormField(
              keyboardType: TextInputType.number,
              controller: ageController,
              decoration: InputDecoration(
                labelText: "Edad",
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              // The validator receives the text that the user has entered.
              validator: (value) {
                if (value.isEmpty) {
                  return 'Ingrese la edad';
                }
                return null;
              },
            ),
          ),
          Padding(
              padding: EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState.validate()) {
                        dbRef.push().set({
                          "name": nameController.text,
                          "age": ageController.text,
                          "type": dropdownValue
                        }).then((_) {
                          Scaffold.of(context).showSnackBar(SnackBar(
                              content: Text('mascota agregada con exito')));
                          ageController.clear();
                          nameController.clear();
                        }).catchError((onError) {
                          Scaffold.of(context)
                              .showSnackBar(SnackBar(content: Text(onError)));
                        });
                      }
                    },
                    child: Text('Agregar'),
                  ),
                  RaisedButton(
                    color: Colors.amber,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                Home(title: "Pagina principal")),
                      );
                    },
                    child: Text('Listar'),
                  ),
                ],
              )),
        ])));
  }

  @override
  void dispose() {
    super.dispose();
    ageController.dispose();
    nameController.dispose();
  }
}
