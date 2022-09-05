import 'package:flutter/material.dart';

class RequestPin extends StatefulWidget {
  RequestPin();

  @override
  _RequestPinState createState() => _RequestPinState();
}

class _RequestPinState extends State<RequestPin> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _pinController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Container(
          width: double.infinity,
          margin: EdgeInsets.fromLTRB(20, 70, 20, 50),
          child: Form(
            key: this._formKey,
            child: Column(
              children: [
                Container(
                  child: Text(
                    "Please enter your card pin to continue your transaction.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.black, fontSize: 20),
                  ),
                ),
                Container(
                  margin: EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: TextFormField(
                    decoration: InputDecoration(
                      hintText: "PIN",
                      labelText: "PIN",
                      prefixIcon: Icon(
                        Icons.lock,
                        size: 20,
                      ),
                    ),
                    textInputAction: TextInputAction.next,
                    keyboardType: TextInputType.number,
                    obscureText: true,
                    autocorrect: false,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 20.0,
                    ),
                    controller: this._pinController,
                    validator: this._pinValidator,
                  ),
                ),
                Container(
                  margin: EdgeInsets.all(20),
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: this._continuePayment,
                    style: ElevatedButton.styleFrom(
                        backgroundColor:  Colors.orangeAccent,
                      ),
                    child: Text(
                      "CONTINUE PAYMENT",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  String? _pinValidator(String? value) {
    return value != null && value.trim().isEmpty ? "Pin is required" : null;
  }

  void _continuePayment() {
    if (this._formKey.currentState!.validate()) {
      Navigator.of(this.context).pop(this._pinController.value.text);
    }
  }
}
