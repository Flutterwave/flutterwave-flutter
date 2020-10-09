<p align="center">
   <img title="Flutterwave" height="200" src="https://flutterwave.com/images/logo-colored.svg" width="50%"/>
</p>

# Flutterwave Flutter SDK

## Table of Contents

- [About](#about)
- [Getting Started](#getting-started)
- [Usage](#usage)
- [Deployment](#deployment)
- [Built Using](#build-tools)
- [References](#references)
- [Support](#support)

<a id="about"></a>
## About
Flutterwave's Flutter SDK is Flutterwave's offical flutter sdk to integrate the Flutterwave payment into your flutter app. It comes with a readymade Drop In UI.
The payment methods currently supported are Cards, USSD, Mpesa, GH Mobile Money, UG Mobile Money, ZM Mobile Money, Rwanda Mobile Money, Franc Mobile Money and Nigeria Bank Account.


<a id="getting-started"></a>

## Getting Started

These instructions will get you a copy of the project up and running on your local machine for development and testing purposes. See [deployment](#deployment) for notes on how to deploy the project on a live system.
See [references](#references) for links to dashboard and API documentation.

### Prerequisite

- Ensure you have your test (and live) [API keys](https://developer.flutterwave.com/docs/api-keys).
```
Flutter version >= 1.22.0
Flutterwave version 3 API keys
```

 ### Installing
 
**Step 1.** Add it in your root build.gradle at the end of repositories:

**Step 2.** Add the dependency

In your `pubspec.yaml` file add:

1. `flutterwave: 0.1.0`
2. run `flutter pub get`

<a id="usage"></a>
## Usage

### 1. Create a `Flutterwave` instance

Create a `Flutterwave` instance by calling the constructor `Flutterwave.UiPayment()` The `UiPayment` accepts a mandatory instance of the calling `Context` , `publicKey`, `encryptionKey`, `amount`, `currency`, `email`, `fullName`, `txRef`, `isDebugMode` and `phoneNumber` . It returns an instance of `Flutterwave`  which we then call the `async` method `.initializeForUiPayments()` on.

    void beginPayment async () { 
       try { 
		     final ChargeResponse response = await Flutterwave.UiPayment(  
	            context: build_context_here,
	            publicKey: "public_key_here",
	            encryptionKey: "encryption_key_here",  
	            isDebugMode: true/false,
	            currency: FlutterwaveCurrency.NGN,
	            amount: "10",
	            email: "test_user@test.com",
	            fullName: "Flutterwave Test User",
	            txRef: your_unique_ref_here,
	            narration: your_payment_narration_here, 
	            phoneNumber: user_phone_number, 
	            acceptBankTransferPayment: true/false,  
	            acceptAccountPayment = true/false,
	            acceptCardPayment = true/false,  
	            acceptUSSDPayment = true/false)
	            .initializeForUiPayments();
	         } catch(error) {
		         handleError(error);
	         }



### 2. Handle the response

  Calling the `.initialiazeForUiPayments()` method returns a `Future`
 of `ChargeResponse` which we await for the actual response as seen above.
 
#### Please note that:
 - `ChargeResponse` can be null, depending on if the user cancels
   the transaction by pressing back.
 - You need to check the status of the transaction from the instance of `ChargeResponse` returned from calling `.initializeForUiPayments()`, the `amount`, `currency` and `txRef` are correct before providing value to the customer
 - To accept payment of different kinds, you need set the currency to the correspending payment type i.e, `KES` for `Mpesa`, `RWF` for `Rwanda Mobile Money`, `NGN` for `USSD`,
`Bank Accounts Payment` and so on.

>  **PLEASE NOTE**

> We advise you to do a further verification of transaction's details on your server to be sure everything checks out before providing service or goods.

<a id="deployment"></a>
## Deployment

- Switch to Live Mode on the Dashboard settings page
- Use the Live Public API key from the API tab, see [here](https://developer.flutterwave.com/docs/api-keys) for more details.

<a id="build-tools"></a>
## Built Using
- [flutter](https://flutter.dev/)
- [dart](https://dart.dev/)
- [http](https://pub.dev/packages/http)
- [tripledes](https://pub.dev/packages/tripledes)
- [hexcolor](https://pub.dev/packages/hexcolor)  
- [webview_flutter](https://pub.dev/packages/webview_flutter)

<a id="references"></a>
## Flutterwave API  References

- [Flutterwave API Doc](https://developer.flutterwave.com/docs)
- [Flutterwave Inline Payment Doc](https://developer.flutterwave.com/docs/flutterwave-inline)
- [Flutterwave Dashboard](https://dashboard.flutterwave.com/login)  

<a id="support"></a>
## Support
* Have issues integrating? Reach out via [our Developer forum](https://developer.flutterwave.com/discuss) for support

