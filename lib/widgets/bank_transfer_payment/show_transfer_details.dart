import 'package:flutter/material.dart';
import 'package:flutterwave/models/responses/bank_transfer_response/bank_transfer_response.dart';

class AccountDetails extends StatelessWidget {
  final Function _onTransferMade;
  final BankTransferResponse _bankTransferResponse;

  AccountDetails(this._bankTransferResponse, this._onTransferMade);

  @override
  Widget build(BuildContext context) {
    final authorization = this._bankTransferResponse.meta!.authorization;
    final String note = authorization!.transferNote;

    return Container(
      width: double.infinity,
      margin: EdgeInsets.fromLTRB(20, 40, 20, 20),
      child: Column(
        children: [
          Text(
            note != null && note.isNotEmpty && note != "N/A"
                ? note
                : "Please make a bank transfer to this account",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.black, fontSize: 18),
          ),
          SizedBox(height: 70),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: double.infinity,
                margin: EdgeInsets.fromLTRB(20, 10, 20, 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Amount",
                      textAlign: TextAlign.start,
                      style: TextStyle(color: Colors.black, fontSize: 18),
                    ),
                    Text(authorization.transferAmount.toString(),
                      textAlign: TextAlign.end,
                      style: TextStyle(color: Colors.black, fontSize: 18),
                    ),
                  ],
                ),
              ),
              Container(
                width: double.infinity,
                margin: EdgeInsets.fromLTRB(20, 10, 20, 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Account Number",
                      textAlign: TextAlign.start,
                      style: TextStyle(color: Colors.black, fontSize: 18),
                    ),
                    Text(authorization.transferAccount,
                      textAlign: TextAlign.end,
                      style: TextStyle(color: Colors.black, fontSize: 18),
                    ),
                  ],
                ),
              ),
              Container(
                width: double.infinity,
                margin: EdgeInsets.fromLTRB(20, 10, 20, 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Bank Name",
                      textAlign: TextAlign.start,
                      style: TextStyle(color: Colors.black, fontSize: 18),
                    ),
                    Text(authorization.transferBank,
                      textAlign: TextAlign.end,
                      style: TextStyle(color: Colors.black, fontSize: 18),
                    ),
                  ],
                ),
              ),
              Container(
                width: double.infinity,
                margin: EdgeInsets.fromLTRB(20, 10, 20, 20),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Beneficiary Name",
                      textAlign: TextAlign.start,
                      style: TextStyle(color: Colors.black, fontSize: 18),
                    ),
                    Text(this._extractNameFromNote(authorization.transferNote),
                      textAlign: TextAlign.end,
                      style: TextStyle(color: Colors.black, fontSize: 18),
                    ),
                  ],
                ),
              ),
              Container(
                height: 40,
                width: double.infinity,
                margin: EdgeInsets.fromLTRB(5, 10, 20, 5),
                child: ElevatedButton(
                  onPressed: _handleTransferMade,
                  style: ElevatedButton.styleFrom(primary: Colors.orangeAccent),
                  child: Text(
                    "I have made the transfer",
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  void _handleTransferMade() {
    this._onTransferMade();
  }

  String _extractNameFromNote(final String note) {
    if (note == null || note.isEmpty || note == "N/A") return "";
    final list = note.split(" ");
    final lastName = list.elementAt(list.length - 1);
    final firstName = list.elementAt(list.length - 2);
    return "$firstName $lastName";
  }
}
