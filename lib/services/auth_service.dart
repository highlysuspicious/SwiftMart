import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttercommerce/models/user_model.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final GoogleSignIn _googleSignIn = GoogleSignIn();

  static User? get currentUser => _auth.currentUser;
  static Stream<User?> get authStateChanges => _auth.authStateChanges();

  static Future<AuthResult> registerWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );


        return AuthResult(
          success: true,
          message: 'Registration successful! Check your email for verification.',
        );

    } on FirebaseAuthException catch (e) {
      return AuthResult(success: false, message: _getErrorMessage(e.code));
    } catch (_) {
      return AuthResult(success: false, message: 'Unexpected error occurred.');
    }
  }

  static Future<AuthResult> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      // Example Firebase logic
      final credential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      return AuthResult(
        success: true,
        message: 'Signed in successfully.',
      );
    } on FirebaseAuthException catch (e) {
      return AuthResult(success: false, message: _getErrorMessage(e.code));
    } catch (_) {
      return AuthResult(success: false, message: 'Unexpected error occurred.');
    }
  }

  static Future<AuthResult> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return AuthResult(success: false, message: 'Google sign-in cancelled.');
      }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
        accessToken: googleAuth.accessToken,
      );

      final result = await _auth.signInWithCredential(credential);
      return AuthResult(
        success: true,
        user: result.user,
        message: 'Signed in with Google.',
      );
    } catch (e) {
      return AuthResult(success: false, message: 'Google sign-in failed: $e');
    }
  }


  static Future<AuthResult> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return AuthResult(success: true, message: 'Reset email sent.');
    } on FirebaseAuthException catch (e) {
      return AuthResult(success: false, message: _getErrorMessage(e.code));
    } catch (_) {
      return AuthResult(success: false, message: 'Error sending reset email.');
    }
  }

  static Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  static Future<AuthResult> deleteAccount() async {
    try {
      final user = _auth.currentUser;
      await user?.delete();
      return AuthResult(success: true, message: 'Account deleted.');
    } on FirebaseAuthException catch (e) {
      return AuthResult(success: false, message: _getErrorMessage(e.code));
    } catch (_) {
      return AuthResult(success: false, message: 'Failed to delete account.');
    }
  }

  static String _getErrorMessage(String code) {
    switch (code) {
      case 'weak-password':
        return 'Password is too weak.';
      case 'email-already-in-use':
        return 'Email already in use.';
      case 'invalid-email':
        return 'Invalid email address.';
      case 'user-not-found':
        return 'User not found.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'user-disabled':
        return 'Account disabled.';
      case 'too-many-requests':
        return 'Too many attempts. Try again later.';
      case 'operation-not-allowed':
        return 'Operation not allowed.';
      case 'requires-recent-login':
        return 'Please sign in again to proceed.';
      default:
        return 'Authentication error.';
    }
  }
}

class AuthResult {
  final bool success;
  final User? user;
  final String message;

  AuthResult({required this.success, this.user, required this.message});
}
