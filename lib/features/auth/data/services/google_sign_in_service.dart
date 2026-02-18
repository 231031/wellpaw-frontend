import 'package:google_sign_in/google_sign_in.dart';
import 'package:well_paw/core/config/app_config.dart';

class GoogleSignInService {
  GoogleSignInService()
    : _googleSignIn = GoogleSignIn(
        scopes: const ['email', 'profile'],
        serverClientId: AppConfig.googleWebClientId,
        clientId: AppConfig.googleIosClientId,
      );

  final GoogleSignIn _googleSignIn;

  Future<GoogleSignInAccount?> signIn() async {
    return _googleSignIn.signIn();
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
  }
}
