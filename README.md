# Flutterwave Flutter SDK

  

Flutterwave's Flutter SDK is Flutterwave's offical flutter sdk to integrate the Flutterwave payment into your flutter app. It comes with a readymade Drop In UI.

  
The payment methods currently supported are Cards, USSD, Mpesa, GH Mobile Money, UG Mobile Money, ZM Mobile Money, Rwanda Mobile Money, Franc Mobile Money and Nigeria Bank Account.


  

## Before you begin

- Ensure you have your test (and live) [API keys](https://developer.flutterwave.com/docs/api-keys).

  

## Adding it to your project
  

**Step 1.** Add it in your root build.gradle at the end of repositories:

  

**Step 2.** Add the dependency

In your `pubspec.yaml` file add:

1. `flutterwave: 1.0.0`
2. run `pub get`



## Usage

### 1. Create a `Flutterwave` instance

Create a `Flutterwave` instance by calling the constructor `Flutterwave.UiPayment()` The `UiPayment` accepts a mandatory instance of the calling `Context` , `publicKey`, `encryptionKey`, `amount`, `currency`, `email`, `fullName`, `txRef`, `isDebugMode` and `phoneNumber` . It returns an instance of `Flutterwave`  which we then call the `async` method `.initializeForUiPayments()` on.

    void beginPayment async () { 
      try {  
		     final ChargeResponse response = await Flutterwave.UiPayment(  
	            context: build_context_here,
	            publicKey: "public_key_here",
	            encryptionKey: "encryption_key_here",  
	            isDebugMode: this.isDebug,
	            currency: FlutterwaveCurrency.NGN,
	            amount: "10",
	            email: "test_user@test.com",
	            fullName: "Flutterwave Test User",
	            txRef: "your_unique_ref_here",
	            narration: "your_payment_narration_here", 
	            phoneNumber: "user_phone_number", 
	            acceptBankTransferPayment: true,  
	            acceptAccountPayment = true,
	            acceptCardPayment = true,  
	            acceptUSSDPayment = true)
	            .initializeForUiPayments();
	         } catch(error) {
		         print(error.toString());
	         }



### 2. Handle the response

  Calling the `.initialiazeForUiPayments()` method returns a `Future`
 of `ChargeResponse` which we await for the actual response as seen above.
 
#### Please note that:
 - `ChargeResponse` can be null, depending on if the user cancels
   the transaction by pressing back.
 - You need to check the status of the transaction from the instance of `ChargeResponse` returned from calling `.initializeForUiPayments()`, the `amount`, `currency` and `txRef` are correct before providing value to the customer



>  **PLEASE NOTE**

> We advise you to do a further verification of transaction's details on your server to be sure everything checks out before providing service or goods.
 

## Help

* Have issues integrating? Join our [Slack community](https://join.slack.com/t/flutterwavedevelopers/shared_invite/enQtMjU2MjkyNDM5MTcxLWFlOWNlYmE5MTIxNjAwYzc5MDVjZjNhYTJjNTA0ZTQyNDJlMDhhZjJkN2QwZGJmNWMyODhlYjMwNGUyZDQxNTE) for support

* Find a bug? [Open an issue](https://github.com/Flutterwave/flutterwave-flutter/issues)

* Want to contribute? [Check out contributing guidelines]() and [submit a pull request](https://help.github.com/articles/creating-a-pull-request).

  

## Want to contribute?

Feel free to create issues and pull requests. The more concise the pull requests the better :)

  
 
## License 

```

Flutterwave's Flutter SDK

MIT License

  

Copyright (c) 2020

  

Permission is hereby granted, free of charge, to any person obtaining a copy

of this software and associated documentation files (the "Software"), to deal

in the Software without restriction, including without limitation the rights

to use, copy, modify, merge, publish, distribute, sublicense, and/or sell

copies of the Software, and to permit persons to whom the Software is

furnished to do so, subject to the following conditions:

  

The above copyright notice and this permission notice shall be included in all

copies or substantial portions of the Software.

  

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR

IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,

FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE

AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER

LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,

OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE

SOFTWARE.

```