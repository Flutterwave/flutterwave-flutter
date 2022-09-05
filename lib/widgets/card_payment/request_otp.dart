import 'package:flutter/material.dart';

class RequestOTP extends StatefulWidget {
  final String descriptionText;

  RequestOTP(this.descriptionText);

  @override
  _RequestOTPState createState() => _RequestOTPState();
}

class _RequestOTPState extends State<RequestOTP> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _otpController = TextEditingController();

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
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  this.widget.descriptionText,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.black, fontSize: 20),
                ),
                SizedBox(
                  height: 30,
                ),
                Container(
                  margin: EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: TextFormField(
                    decoration: InputDecoration(
                      hintText: "OTP",
                      labelText: "OTP",
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
                    controller: this._otpController,
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
    return value != null && value.trim().isEmpty ? "Otp is required" : null;
  }

  void _continuePayment() {
    if (this._formKey.currentState!.validate()) {
      Navigator.of(this.context).pop(this._otpController.value.text);
    }
  }
}
