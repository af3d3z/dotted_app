import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // hace que te logees con google
  Future<UserCredential> signInWithGoogle() async {
    try {
      UserCredential userCredentials;
      final GoogleSignInAuthentication googleAuth;
      final OAuthCredential credential;
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw FirebaseAuthException(
          code: 'ERROR_ABORTED_BY_USER',
          message: 'Sign in aborted by user.',
        );
      }

      googleAuth = await googleUser.authentication;
      credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      userCredentials = await _auth.signInWithCredential(credential);

      _firestore.collection("users").doc(userCredentials.user!.uid).set({
        'uid': userCredentials.user!.uid,
        'email': userCredentials.user!.email,
      });

      return userCredentials;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  Stream<User?> get user => _auth.authStateChanges();
}
