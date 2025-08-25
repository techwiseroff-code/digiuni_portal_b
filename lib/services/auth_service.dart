import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../firebase_options.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Get current user stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign in with email and password
  Future<UserCredential> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update last login time (non-blocking; ignore permission issues)
      if (userCredential.user != null) {
        try {
          await _firestore
              .collection('users')
              .doc(userCredential.user!.uid)
              .update({'lastLoginAt': FieldValue.serverTimestamp()});
        } catch (_) {
          // Do not surface this to the user – login should succeed even if this field cannot be updated
        }
      }

      return userCredential;
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Get user role from Firestore
  Future<String> getUserRole(String uid) async {
    try {
      DocumentSnapshot userDoc = await _firestore
          .collection('users')
          .doc(uid)
          .get();
      if (userDoc.exists) {
        final data = userDoc.data() as Map<String, dynamic>?;
        return data?['role'] ?? 'student';
      }
      return 'student';
    } catch (e) {
      return 'student';
    }
  }

  // Get user data from Firestore
  Future<UserModel?> getUserData(String uid) async {
    try {
      DocumentSnapshot userDoc = await _firestore
          .collection('users')
          .doc(uid)
          .get();
      if (userDoc.exists) {
        return UserModel.fromMap(userDoc.data() as Map<String, dynamic>, uid);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Create user account (admin only) using a secondary FirebaseApp to avoid switching the current session
  Future<void> createUserAccount({
    required String email,
    required String password,
    required String name,
    required String role,
  }) async {
    try {
      // Use a secondary app so we don't sign out the current admin
      FirebaseApp? secondaryApp;
      try {
        secondaryApp = Firebase.app('admin_secondary');
      } catch (_) {
        secondaryApp = await Firebase.initializeApp(
          name: 'admin_secondary',
          options: DefaultFirebaseOptions.currentPlatform,
        );
      }

      final secondaryAuth = FirebaseAuth.instanceFor(app: secondaryApp);

      UserCredential userCredential = await secondaryAuth
          .createUserWithEmailAndPassword(email: email, password: password);

      // Create user document in Firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'email': email,
        'name': name,
        'role': role,
        'createdAt': FieldValue.serverTimestamp(),
        'lastLoginAt': FieldValue.serverTimestamp(),
        'isActive': true,
      });

      // Create role-specific document
      if (role == 'student') {
        await _firestore
            .collection('students')
            .doc(userCredential.user!.uid)
            .set({
              'name': name,
              'email': email,
              'studentId': '',
              'className': '',
              'section': '',
              'dateOfBirth': DateTime.now(),
              'phoneNumber': '',
              'address': '',
              'parentName': '',
              'parentPhone': '',
              'admissionDate': DateTime.now(),
              'isActive': true,
            });
      } else if (role == 'teacher') {
        await _firestore
            .collection('teachers')
            .doc(userCredential.user!.uid)
            .set({
              'name': name,
              'email': email,
              'teacherId': '',
              'department': '',
              'qualification': '',
              'dateOfBirth': DateTime.now(),
              'phoneNumber': '',
              'address': '',
              'joiningDate': DateTime.now(),
              'assignedClasses': [],
              'subjects': [],
              'isActive': true,
            });
      }

      // Clean up secondary auth session (sign it out to free resources)
      await secondaryAuth.signOut();
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  // Change password
  Future<void> changePassword(String newPassword) async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        await user.updatePassword(newPassword);
      }
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  // Admin-only: Delete a Firebase Auth user by UID using admin reauthentication flow.
  // Note: Client SDK cannot delete arbitrary users; here we delete the currently signed-in user if matching.
  // For admin panel bulk deletion, we first try to sign in to the target account temporarily via secondary app
  // and delete it, without affecting admin session.
  Future<bool> deleteAuthUserByEmailPassword(
    String email,
    String password,
  ) async {
    try {
      FirebaseApp? secondaryApp;
      try {
        secondaryApp = Firebase.app('admin_secondary_delete');
      } catch (_) {
        secondaryApp = await Firebase.initializeApp(
          name: 'admin_secondary_delete',
          options: DefaultFirebaseOptions.currentPlatform,
        );
      }
      final secondaryAuth = FirebaseAuth.instanceFor(app: secondaryApp);
      final cred = await secondaryAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      await cred.user?.delete();
      await secondaryAuth.signOut();
      return true;
    } catch (_) {
      return false;
    }
  }

  // Handle authentication errors
  String _handleAuthError(dynamic e) {
    if (e is FirebaseAuthException) {
      switch (e.code) {
        case 'user-not-found':
          return 'No user found with this email.';
        case 'wrong-password':
          return 'Wrong password provided.';
        case 'email-already-in-use':
          return 'An account already exists with this email.';
        case 'weak-password':
          return 'The password provided is too weak.';
        case 'invalid-email':
          return 'The email address is invalid.';
        case 'operation-not-allowed':
          return 'Sign-up is disabled, contact admin.';
        case 'user-disabled':
          return 'This user account has been disabled.';
        case 'too-many-requests':
          return 'Too many attempts. Please try again later.';
        default:
          return 'Authentication failed: ${e.message}';
      }
    }
    // For non-Firebase errors, surface the real message for easier debugging
    try {
      return e?.toString() ?? 'An unknown error occurred.';
    } catch (_) {
      return 'An unknown error occurred.';
    }
  }

  // Check if user is admin
  Future<bool> isAdmin(String uid) async {
    try {
      String role = await getUserRole(uid);
      return role == 'admin';
    } catch (e) {
      return false;
    }
  }

  // Check if user is teacher
  Future<bool> isTeacher(String uid) async {
    try {
      String role = await getUserRole(uid);
      return role == 'teacher';
    } catch (e) {
      return false;
    }
  }

  // Check if user is student
  Future<bool> isStudent(String uid) async {
    try {
      String role = await getUserRole(uid);
      return role == 'student';
    } catch (e) {
      return false;
    }
  }
}
