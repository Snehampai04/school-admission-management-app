import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String uid;
  final String email;
  final String name;
  final String role;
  final DateTime createdAt;

  const UserEntity({
    required this.uid,
    required this.email,
    required this.name,
    required this.role,
    required this.createdAt,
  });

  bool get isAdmin => role == 'admin';

  bool get isParent => role == 'parent';

  @override
  List<Object?> get props => [
        uid,
        email,
        name,
        role,
        createdAt,
      ];
}