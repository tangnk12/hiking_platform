class User {
  int id;
  String name;
  String password;
  String ic;
  String email;
  String address;
  String phone;
  String emergencyCall;

  User({
    required this.id,
    required this.name,
    required this.password,
    required this.ic,
    required this.email,
    required this.address,
    required this.phone,
    required this.emergencyCall,
  });

  int get userId => id;

  set userId(int id) => this.id = id;

  String get userName => name;

  set userName(String name) => this.name = name;

  String get userPassword => password;

  set userPassword(String password) => this.password = password;

  String get userIdentificationCard => ic;

  set userIdentificationCard(String ic) => this.ic = ic;

  String get userEmail => email;

  set userEmail(String email) => this.email = email;

  String get userAddress => address;

  set userAddress(String address) => this.address = address;

  String get userPhone => phone;

  set userPhone(String phone) => this.phone = phone;

  String get userEmergencyCall => emergencyCall;

  set userEmergencyCall(String emergencyCall) =>
      this.emergencyCall = emergencyCall;

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      password: json['password'],
      ic: json['ic'],
      email: json['email'],
      address: json['address'],
      phone: json['phone'],
      emergencyCall: json['emergencyCall'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'password': password,
      'ic': ic,
      'email': email,
      'address': address,
      'phone': phone,
      'emergencyCall': emergencyCall,
    };
  }
}
