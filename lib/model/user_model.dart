class UserModel {
  late String uid;
  late String name;
  late String email;

  late int dt;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.dt,
  });

  factory UserModel.fromJson(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'],
      name: map['name'],
      email: map['email'],
      dt: map['dt'],
    );
  }
}
