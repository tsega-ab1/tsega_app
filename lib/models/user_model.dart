class UserModel {
  final String name;
  final DateTime? dob;
  final String region;
  final String phone;
  final String? partnerPhone;
  final String? emergencyContact;
  final String? emergencyName;
  final String language;

  const UserModel({
    required this.name,
    this.dob,
    this.region = 'Addis Ababa',
    required this.phone,
    this.partnerPhone,
    this.emergencyContact,
    this.emergencyName,
    this.language = 'en',
  });

  int get age {
    if (dob == null) return 0;
    final now = DateTime.now();
    int age = now.year - dob!.year;
    if (now.month < dob!.month ||
        (now.month == dob!.month && now.day < dob!.day)) {
      age--;
    }
    return age;
  }

  UserModel copyWith({
    String? name,
    DateTime? dob,
    String? region,
    String? phone,
    String? partnerPhone,
    String? emergencyContact,
    String? emergencyName,
    String? language,
  }) {
    return UserModel(
      name: name ?? this.name,
      dob: dob ?? this.dob,
      region: region ?? this.region,
      phone: phone ?? this.phone,
      partnerPhone: partnerPhone ?? this.partnerPhone,
      emergencyContact: emergencyContact ?? this.emergencyContact,
      emergencyName: emergencyName ?? this.emergencyName,
      language: language ?? this.language,
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'dob': dob?.toIso8601String(),
    'region': region,
    'phone': phone,
    'partnerPhone': partnerPhone,
    'emergencyContact': emergencyContact,
    'emergencyName': emergencyName,
    'language': language,
  };

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    name: json['name'] ?? '',
    dob: json['dob'] != null ? DateTime.parse(json['dob']) : null,
    region: json['region'] ?? 'Addis Ababa',
    phone: json['phone'] ?? '',
    partnerPhone: json['partnerPhone'],
    emergencyContact: json['emergencyContact'],
    emergencyName: json['emergencyName'],
    language: json['language'] ?? 'en',
  );
}
