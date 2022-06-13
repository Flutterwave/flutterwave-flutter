
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

```  
Please note that this library is no more supported, and so no updates would be published. 
You can find the new, supported library [here](https://pub.dev/packages/flutterwave_standard) 
```  
Flutterwave's Flutter SDK is Flutterwave's offical flutter sdk to integrate the Flutterwave payment into your flutter app. It comes with a readymade Drop In UI.  
The payment methods currently supported are Cards, USSD, Mpesa, GH Mobile Money, UG Mobile Money, ZM Mobile Money, Rwanda Mobile Money, Franc Mobile Money and Nigeria Bank Account.  
  
  
<a id="getting-started"></a>  
  
## Getting Started  
  
These instructions will get you a copy of the project up and running on your local machine for development and testing purposes. See [deployment](#deployment) for notes on how to deploy the project on a live system.  
See [references](#references) for links to dashboard and API documentation.  
  
## Requirements  
  
- Ensure you have your test (and live) [API keys](https://developer.flutterwave.com/docs/api-keys).  
- This Library runs and the V3 API, and so you **need** to be PCI-DSS certified to use this.  
```  
Flutter version >= 1.17.0  
Flutterwave version 3 API keys  
```  
  
  ## Installation  
Add the dependency  
  
In your `pubspec.yaml` file add:  
  
1. `flutterwave: 1.0.2`  
2. run `flutter pub get`  
  
<a id="usage"></a>  
## Usage  
  
### 1. Create a `Flutterwave` instance  
  
Create a `Flutterwave` instance by calling the constructor `Flutterwave.forUIPayment()` The constructor accepts a mandatory instance of the following:  
 the calling `Context` , `publicKey`, `encryptionKey`, `amount`, `currency`, `email`, `fullName`, `txRef`, `isDebugMode` and `phoneNumber` . It returns an instance of `Flutterwave` which we then call the `async` method `.initializeForUiPayments()` on.  
  

        beginPayment async () {      
     try {   
            Flutterwave flutterwave = Flutterwave.forUIPayment(  
    			context: this.context, 
    			encryptionKey: "Your_test_encryption_key_here", 
    			publicKey: "Your_test_public_key_here", 
    			currency: currency, 
    			amount: amount, 
    			email: "valid@email.com", 
    			fullName: "Valid Full Name", 
    			txRef: txref, 
    			isDebugMode: true, 
    			phoneNumber: "0123456789", 
    			acceptCardPayment: true, 
    			acceptUSSDPayment: false, 
    			acceptAccountPayment: false, 
    			acceptFrancophoneMobileMoney: false, 
    			acceptGhanaPayment: false, 
    			acceptMpesaPayment: false, 
    			acceptRwandaMoneyPayment: true, 
    			acceptUgandaPayment: false, 
    			acceptZambiaPayment: false)              
    	final ChargeResponse response = awaitflutterwave.initializeForUiPayments();  
                 } catch(error) {  
     handleError(error); }  

  ### 2. Handle the response Calling the `.initialiazeForUiPayments()` method returns a `Future`  
of `ChargeResponse` which we await for the actual response as seen above. An example of how to make payment in a Widget would look like this: 

    class PaymentWidget extends StatefulWidget { 
    
    @override 
    _PaymentWidgetState createState() => _PaymentWidgetState(); 
    
    } 
    
    class _PaymentWidgetState extends State<PaymentWidget> {  
        final String txref = "My_unique_transaction_reference_123";
        final String amount = "200"; 
        final String currency = FlutterwaveCurrency.RWF; 
        
        @override  
        Widget build(BuildContext context) { 
        return Container(); 
        } 
        
        beginPayment() async {  
        final Flutterwave flutterwave = Flutterwave.forUIPayment( context: this.context, 
        encryptionKey: "your_test_encryption_key", 
        publicKey: "your_public_key", 
        currency: this.currency, 
        amount: this.amount, 
        email: "[valid@email.com](mailto:valid@email.com)", 
        fullName: "Valid Full Name", 
        txRef: this.txref, 
        isDebugMode: true, 
        phoneNumber: "0123456789", 
        acceptCardPayment: true, 
        acceptUSSDPayment: false, 
        acceptAccountPayment: false, 
        acceptFrancophoneMobileMoney: false, 
        acceptGhanaPayment: false, 
        acceptMpesaPayment: false, 
        acceptRwandaMoneyPayment: true, 
        acceptUgandaPayment: false, 
        acceptZambiaPayment: false); 
        
        try {  
        final ChargeResponse response = await flutterwave.initializeForUiPayments(); 
        if (response == null) { 
        // user didn't complete the transaction.
         } else { 
	         final isSuccessful = checkPaymentIsSuccessful(response); 
	         if (isSuccessful) {
	          // provide value to customer 
	          } else { 
	          // check message print(response.message); 
	          // check status  
		        print(response.status); // check processor error  
		        print(response.data.processorResponse); 
			    } 
		    } 
        } catch (error, stacktrace) {
         // handleError(error); 
	         } 
         } 
         bool checkPaymentIsSuccessful(final ChargeResponse response){  
        return response.data.status == FlutterwaveConstants.SUCCESSFUL
        && response.data.currency == this.currency 
        && response.data.amount == this.amount 
        && response.data.txRef == this.txref; 
	        } 
        }

 #### Please note that:  
- `ChargeResponse` can be null, depending on if the user cancels  
the transaction by pressing back.  
- You need to check the status of the transaction from the instance of `ChargeResponse` returned from calling `.initializeForUiPayments()`, the `amount`, `currency` and `txRef` are correct before providing value to the customer  
- To accept payment of different kinds, you need set the currency to the correspending payment type i.e, `KES` for `Mpesa`, `RWF` for `Rwanda Mobile Money`, `NGN` for `USSD`,  
`Bank Accounts Payment` and so on.> 

**PLEASE NOTE** 
We advise you to do a further verification of transaction's details on your server to be sure everything checks out before providing service or goods as seen in the `checkPaymentIsSuccessful()` method above.


## Testing


## Debugging Errors
We understand that you may run into some errors while integrating our library. You can read more about our error messages [here](https://developer.flutterwave.com/docs/integration-guides/errors).

For `authorization` and `validation` error responses, double-check your API keys and request. If you get a `server` error, kindly engage the team for support.

<a id="support"></a>  
## Support  
For additional assistance using this library, contact the developer experience (DX) team via [email](mailto:developers@flutterwavego.com) or on [slack](https://bit.ly/34Vkzcg).

You can also follow us [@FlutterwaveEng](https://twitter.com/FlutterwaveEng) and let us know what you think 😊

## Contribution guidelines
Read more about our community contribution guidelines [here](https://www.notion.so/flutterwavego/Community-contribution-guide-ca1d8a876ba04d45ab4b663c758ae42a).
 
## License
By contributing to the Flutter library, you agree that your contributions will be licensed under its [MIT license](https://opensource.org/licenses/MIT).
  
<a id="build-tools"></a>  
## Built Using  
- [flutter](https://flutter.dev/)  
- [dart](https://dart.dev/)  
- [http](https://pub.dev/packages/http)  
- [tripledes](https://pub.dev/packages/tripledes)  
- [webview_flutter](https://pub.dev/packages/webview_flutter)  
  
<a id="references"></a>  
## Flutterwave API  References  
  
- [Flutterwave API Doc](https://developer.flutterwave.com/docs)  
- [Flutterwave Inline Payment Doc](https://developer.flutterwave.com/docs/flutterwave-inline)  
- [Flutterwave Dashboard](https://dashboard.flutterwave.com/login)    
  