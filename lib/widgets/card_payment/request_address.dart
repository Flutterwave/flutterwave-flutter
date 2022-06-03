import 'package:flutter/material.dart';
import 'package:flutterwave/models/requests/charge_card/charge_request_address.dart';

class RequestAddress extends StatefulWidget {
  @override
  _RequestAddressState createState() => _RequestAddressState();
}

class _RequestAddressState extends State<RequestAddress> {
  final _addressFormKey = GlobalKey<FormState>();

  final TextEditingController _addressFieldController = TextEditingController();
  final TextEditingController _cityFieldController = TextEditingController();
  final TextEditingController _stateFieldController = TextEditingController();
  final TextEditingController _zipCodeFieldController = TextEditingController();
  final TextEditingController _countryFieldController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    this._addressFieldController.dispose();
    this._cityFieldController.dispose();
    this._stateFieldController.dispose();
    this._zipCodeFieldController.dispose();
    this._countryFieldController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 30.0),
        child: Form(
          key: _addressFormKey,
          child: Container(
              margin: EdgeInsets.fromLTRB(0, 50, 0, 0),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Text(
                      "Enter your billing address details",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: "Address",
                        hintText: "Address e.g 10, Lincoln boulevard",
                      ),
                      controller: this._addressFieldController,
                      validator: (value) =>
                      value != null && value.isNotEmpty ? null : "Address is required",
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.text,
                      autocorrect: false,
                    ),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: "City",
                        hintText: "City e.g Chicago",
                      ),
                      controller: this._cityFieldController,
                      validator: (value) =>
                      value != null && value.isNotEmpty ? null : "City is required",
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.text,
                      autocorrect: false,
                    ),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: "State",
                        hintText: "State e.g Illinois",
                      ),
                      controller: this._stateFieldController,
                      validator: (value) =>
                      value != null && value.isNotEmpty ? null : "State is required",
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.text,
                      autocorrect: false,
                    ),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: "Zipcode",
                        hintText: "Zipcode e.g 1002293",
                      ),
                      controller: this._zipCodeFieldController,
                      validator: (value) =>
                      value != null && value.isNotEmpty ? null : "Zipcode is required",
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.text,
                      autocorrect: false,
                    ),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: "Country",
                        hintText: "Country e.g Nigeria",
                      ),
                      controller: this._countryFieldController,
                      validator: (value) =>
                          value != null && value.isNotEmpty ? null : "Country is required",
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.text,
                      autocorrect: false,
                    ),
                    Container(
                      width: double.infinity,
                      height: 50,
                      margin: EdgeInsets.fromLTRB(0, 20, 0, 0),
                      child: ElevatedButton(
                        onPressed: this._onAddressFilled,
                        color: Colors.orangeAccent,
                        child: Text(
                          "CONTINUE PAYMENT",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ),
        ),
      ),
    );
  }

  void _onAddressFilled() {
    if (this._addressFormKey.currentState!.validate()) {
      Map<String, String> addressValue = Map<String, String>();
      addressValue["address"] = this._addressFieldController.text;
      addressValue["city"] = this._cityFieldController.text;
      addressValue["state"] = this._stateFieldController.text;
      addressValue["country"] = this._countryFieldController.text;
      addressValue["zipcode"] = this._zipCodeFieldController.text;
      return Navigator.of(this.context).pop(ChargeRequestAddress.fromJson(addressValue));
    }
  }
}
