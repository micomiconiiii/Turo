import 'package:firebase_auth/firebase_auth.dart';

class FirebaseOtpService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<bool> sendSignInLinkToEmail(String email) async {
    var acs = ActionCodeSettings(
      url: 'https://turo-31805.firebaseapp.com/verify',
      handleCodeInApp: true,
      iOSBundleId: 'com.example.turo',
      androidPackageName: 'com.example.turo',
      androidInstallApp: true,
      androidMinimumVersion: '12',
    );

    try {
      await _auth.sendSignInLinkToEmail(
        email: email,
        actionCodeSettings: acs,
      );
      print('Successfully sent sign-in link to $email');
      return true;
    } catch (e) {
      print('Error sending sign-in link: $e');
      return false;
    }
  }

  Future<bool> handleSignInLink(String link, String email) async {
    if (_auth.isSignInWithEmailLink(link)) {
      try {
        final userCredential = await _auth.signInWithEmailLink(
          email: email,
          emailLink: link,
        );
        return userCredential.user != null;
      } catch (e) {
        print('Error signing in with email link: $e');
        return false;
      }
    }
    return false;
  }
}
