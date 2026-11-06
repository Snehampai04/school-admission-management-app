
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/firestore_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> registerParent({
    required String name,
    required String email,
    required String password,
  });

  Future<UserModel> loginWithEmail({
    required String email,
    required String password,
  });

  Future<UserModel?> getCurrentUser();

  Future<void> logout();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuth firebaseAuth;
  final FirebaseFirestore firestore;

  AuthRemoteDataSourceImpl({
    required this.firebaseAuth,
    required this.firestore,
  });

  CollectionReference<Map<String, dynamic>> get _usersCollection =>
      firestore.collection(FirestoreConstants.usersCollection);

  @override
  Future<UserModel> registerParent({
    required String name,
    required String email,
    required String password,
  }) async {
    UserCredential? credential;

    try {
      credential = await firebaseAuth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final firebaseUser = credential.user;

      if (firebaseUser == null) {
        throw const AuthException('Account creation failed.');
      }

      final userModel = UserModel(
        uid: firebaseUser.uid,
        email: firebaseUser.email ?? email.trim(),
        name: name.trim(),
        role: AppConstants.roleParent,
        createdAt: DateTime.now(),
      );

      await _usersCollection.doc(firebaseUser.uid).set({
        FirestoreConstants.uid: userModel.uid,
        FirestoreConstants.email: userModel.email,
        FirestoreConstants.name: userModel.name,
        FirestoreConstants.role: AppConstants.roleParent,
        FirestoreConstants.createdAt:
            Timestamp.fromDate(userModel.createdAt),
      });

      return userModel;
    } on FirebaseAuthException catch (e) {
      throw AuthException(e.message ?? 'Registration failed.');
    } catch (e) {
      if (credential?.user != null) {
        try {
          await credential!.user!.delete();
        } catch (_) {
          throw const ServerException(
            'Profile creation failed. Please contact support.',
          );
        }
      }

      if (e is AppException) rethrow;

      throw const ServerException(
        'Unable to complete registration. Please try again.',
      );
    }
  }

  @override
  Future<UserModel> loginWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await firebaseAuth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final firebaseUser = credential.user;

      if (firebaseUser == null) {
        throw const AuthException('Login failed.');
      }

      return await _getVerifiedUser(firebaseUser);
    } on FirebaseAuthException catch (e) {
      throw AuthException(e.message ?? 'Login failed.');
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Unable to access user profile.');
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    final firebaseUser = firebaseAuth.currentUser;

    if (firebaseUser == null) return null;

    try {
      return await _getVerifiedUser(firebaseUser);
    } on NotFoundException {
      await firebaseAuth.signOut();
      return null;
    }
  }

  Future<UserModel> _getVerifiedUser(User firebaseUser) async {
    final document = await _usersCollection.doc(firebaseUser.uid).get();

    if (!document.exists || document.data() == null) {
      throw const NotFoundException('User profile not found.');
    }

    final data = document.data()!;

    final uid = data[FirestoreConstants.uid];
    final email = data[FirestoreConstants.email];
    final role = data[FirestoreConstants.role];

    if (uid != firebaseUser.uid ||
        email != firebaseUser.email ||
        (role != AppConstants.roleParent &&
            role != AppConstants.roleAdmin)) {
      throw const PermissionException(
        'Your account profile is invalid or does not match your permissions.',
      );
    }

    return UserModel.fromMap(data);
  }

  @override
  Future<void> logout() async {
    try {
      await firebaseAuth.signOut();
    } on FirebaseAuthException catch (e) {
      throw AuthException(e.message ?? 'Logout failed.');
    }
  }
}
