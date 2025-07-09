// // import 'package:http/http.dart' as http;
// // import 'dart:convert';

// // class MpesaService {
// //   static Future<String> initiateStkPush({
// //     required String phoneNumber,
// //     required double amount,
// //     required String bookingId,
// //   }) async {
// //     try {
// //       // Use Daraja sandbox or your real endpoint here
// //       final url = Uri.parse('https://sandbox.safaricom.co.ke/mpesa/stkpush/v1/processrequest');

// //       // Dummy access token (normally retrieved via auth endpoint)
// //       final token = 'YOUR_ACCESS_TOKEN_HERE';

// //       final headers = {
// //         'Authorization': 'Bearer $token',
// //         'Content-Type': 'application/json',
// //       };

// //       final body = jsonEncode({
// //         "BusinessShortCode": "174379", // Replace with yours
// //         "Password": "MTc0Mzc5YmZiMjc5ZjlhYTliZGJjZjE1OGU5N2RkNzFhNDY3Y2QyZTBjODkzMDU5YjEwZjc4ZTZiNzJhZGExZWQyYzkxOTIwMTYwMjE2MTY1NjI3", // base64 encoded (Shortcode+Passkey+Timestamp)
// //         "Timestamp": "20240521093000", // Format: yyyymmddhhmmss
// //         "TransactionType": "CustomerPayBillOnline",
// //         "Amount": amount.round(),
// //         "PartyA": phoneNumber,
// //         "PartyB": "174379",
// //         "PhoneNumber": phoneNumber,
// //         "CallBackURL": "https://sandbox.safaricom.co.ke", // use a dummy ngrok link or Supabase function
// //         "AccountReference": "PawPalBooking-$bookingId",
// //         "TransactionDesc": "Booking Payment"
// //       });

// //       final response = await http.post(url, headers: headers, body: body);

// //       if (response.statusCode == 200) {
// //         return "success"; // You can parse more details if needed
// //       } else {
// //         print('M-Pesa STK error: ${response.body}');
// //         return "error";
// //       }
// //     } catch (e) {
// //       print('M-Pesa STK Exception: $e');
// //       return "error";
// //     }
// //   }
// // }




// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:intl/intl.dart';
// import 'package:pawpal/services/mpesa_credentials.dart';

// class MpesaService {
//   static Future<String> initiateStkPush({
//     required String phoneNumber,
//     required double amount,
//     required String bookingId,
//   }) async {
//     try {
//       // Step 1: Get access token
//       final authResponse = await http.get(
//         Uri.parse('https://sandbox.safaricom.co.ke/oauth/v1/generate?grant_type=client_credentials'),
//         headers: {
//           'Authorization': 'Basic ${base64Encode(utf8.encode('${MpesaCredentials.consumerKey}:${MpesaCredentials.consumerSecret}'))}',
//         },
//       );

//       if (authResponse.statusCode != 200) {
//         print('Failed to get token: ${authResponse.body}');
//         return 'error';
//       }

//       final authData = json.decode(authResponse.body);
//       final token = authData['access_token'];

//       // Step 2: Build STK Push request
//       final timestamp = DateFormat('yyyyMMddHHmmss').format(DateTime.now());

//       final password = base64Encode(utf8.encode(
//         '${MpesaCredentials.shortCode}${MpesaCredentials.passKey}$timestamp',
//       ));

//       final body = jsonEncode({
//         "BusinessShortCode": MpesaCredentials.shortCode,
//         "Password": password,
//         "Timestamp": timestamp,
//         "TransactionType": "CustomerPayBillOnline",
//         "Amount": amount.round(),
//         "PartyA": phoneNumber,
//         "PartyB": MpesaCredentials.shortCode,
//         "PhoneNumber": phoneNumber,
//         "CallBackURL": MpesaCredentials.callbackUrl,
//         "AccountReference": "PawPalBooking-$bookingId",
//         "TransactionDesc": "Booking Payment"
//       });

//       final response = await http.post(
//         Uri.parse('https://sandbox.safaricom.co.ke/mpesa/stkpush/v1/processrequest'),
//         headers: {
//           'Authorization': 'Bearer $token',
//           'Content-Type': 'application/json',
//         },
//         body: body,
//       );

//       if (response.statusCode == 200) {
//         print('STK Push success: ${response.body}');
//         return 'success';
//       } else {
//         print('STK Push failed: ${response.body}');
//         return 'error';
//       }
//     } catch (e) {
//       print('M-Pesa Exception: $e');
//       return 'error';
//     }
//   }
// }




import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:pawpal/services/mpesa_credentials.dart';

class MpesaService {
  static Future<String> initiateStkPush({
    required String phoneNumber,
    required double amount,
    required String bookingId,
  }) async {
    try {
      // Step 1: Get access token
      final authResponse = await http.get(
        Uri.parse('https://sandbox.safaricom.co.ke/oauth/v1/generate?grant_type=client_credentials'),
        headers: {
          'Authorization': 'Basic ${base64Encode(utf8.encode('${MpesaCredentials.consumerKey}:${MpesaCredentials.consumerSecret}'))}',
        },
      );

      if (authResponse.statusCode != 200) {
        print('Failed to get token: ${authResponse.body}');
        return 'error';
      }

      final authData = json.decode(authResponse.body);
      final token = authData['access_token'];

      // Step 2: Build STK Push request
      final timestamp = DateFormat('yyyyMMddHHmmss').format(DateTime.now());

      final password = base64Encode(utf8.encode(
        '${MpesaCredentials.shortCode}${MpesaCredentials.passKey}$timestamp',
      ));

      final body = jsonEncode({
        "BusinessShortCode": MpesaCredentials.shortCode,
        "Password": password,
        "Timestamp": timestamp,
        "TransactionType": "CustomerPayBillOnline",
        "Amount": amount.round(),
        "PartyA": phoneNumber,
        "PartyB": MpesaCredentials.shortCode,
        "PhoneNumber": phoneNumber,
        "CallBackURL": MpesaCredentials.callbackUrl,
        "AccountReference": "PawPalBooking-$bookingId",
        "TransactionDesc": "Booking Payment"
      });

      final response = await http.post(
        Uri.parse('https://sandbox.safaricom.co.ke/mpesa/stkpush/v1/processrequest'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: body,
      );

      if (response.statusCode == 200) {
        print('STK Push success: ${response.body}');
        return 'success';
      } else {
        print('STK Push failed: ${response.body}');
        return 'error';
      }
    } catch (e) {
      print('M-Pesa Exception: $e');
      return 'error';
    }
  }
}
