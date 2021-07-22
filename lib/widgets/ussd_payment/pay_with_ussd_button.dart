import 'package:flutter/material.dart';

class PayWithUssdButton extends StatefulWidget {
  final Function _paywithUssd;
  final Function showBottomSheet;
  final TextEditingController bankController;

  PayWithUssdButton(
      this._paywithUssd, this.bankController, this.showBottomSheet);

  @override
  _PayWithUssdButtonState createState() => _PayWithUssdButtonState();
}

class _PayWithUssdButtonState extends State<PayWithUssdButton> {
  GlobalKey<FormState> _formState = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Container(
        width: double.infinity,
        margin: EdgeInsets.fromLTRB(20, 50, 20, 20),
        child: Form(
          key: this._formState,
          child: Column(
            children: [
              TextFormField(
                controller: this.widget.bankController,
                readOnly: true,
                onTap: this._showBottomSheet,
                validator: (value) => value != null && value.isEmpty
                    ? "Please select a bank"
                    : null,
                textAlign: TextAlign.center,
                decoration: InputDecoration(labelText: "Bank Name"),
              ),
              Container(
                width: double.infinity,
                height: 50,
                margin: EdgeInsets.fromLTRB(0, 50, 0, 0),
                child: ElevatedButton(
                  onPressed: this._handlePayPressed,
                  style: ElevatedButton.styleFrom(primary: Colors.orangeAccent),
                  child: Text(
                    "PAY WITH USSD",
                    style: TextStyle(color: Colors.white, fontSize: 15),
                  ),
                ),
              )
            ],
          ),
        ));
  }

  void _handlePayPressed() {
    if (this._formState.currentState!.validate()) {
      this.widget._paywithUssd();
    }
  }

  void _showBottomSheet() {
    this.widget.showBottomSheet();
  }
}
