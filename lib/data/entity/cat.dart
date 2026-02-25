class Cat {
  final int catId;
  final String catName;
  final String ownerName;
  final String ownerPhone;
  final String breed;
  final String gender; // "Male", "Female"
  final int dob;
  final String profilePhotoPath; // Legacy
  final String? imagePath;
  final String permanentAlert; // e.g. "Galak", "Jantung Lemah"
  final String furColor;
  final String eyeColor;
  final double weight;
  final bool isSterile;

  const Cat({
    this.catId = 0,
    this.catName = '',
    this.ownerName = '',
    this.ownerPhone = '',
    this.breed = '',
    this.gender = 'Male',
    this.dob = 0,
    this.profilePhotoPath = '',
    this.imagePath,
    this.permanentAlert = '',
    this.furColor = '',
    this.eyeColor = '',
    this.weight = 0.0,
    this.isSterile = false,
  });

  Cat copyWith({
    int? catId,
    String? catName,
    String? ownerName,
    String? ownerPhone,
    String? breed,
    String? gender,
    int? dob,
    String? profilePhotoPath,
    String? imagePath,
    String? permanentAlert,
    String? furColor,
    String? eyeColor,
    double? weight,
    bool? isSterile,
  }) {
    return Cat(
      catId: catId ?? this.catId,
      catName: catName ?? this.catName,
      ownerName: ownerName ?? this.ownerName,
      ownerPhone: ownerPhone ?? this.ownerPhone,
      breed: breed ?? this.breed,
      gender: gender ?? this.gender,
      dob: dob ?? this.dob,
      profilePhotoPath: profilePhotoPath ?? this.profilePhotoPath,
      imagePath: imagePath ?? this.imagePath,
      permanentAlert: permanentAlert ?? this.permanentAlert,
      furColor: furColor ?? this.furColor,
      eyeColor: eyeColor ?? this.eyeColor,
      weight: weight ?? this.weight,
      isSterile: isSterile ?? this.isSterile,
    );
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'catName': catName,
      'ownerName': ownerName,
      'ownerPhone': ownerPhone,
      'breed': breed,
      'gender': gender,
      'dob': dob,
      'profilePhotoPath': profilePhotoPath,
      'imagePath': imagePath,
      'permanentAlert': permanentAlert,
      'furColor': furColor,
      'eyeColor': eyeColor,
      'weight': weight,
      'isSterile': isSterile ? 1 : 0,
    };
    if (catId != 0) {
      map['catId'] = catId;
    }
    return map;
  }

  factory Cat.fromMap(Map<String, dynamic> map) {
    // Helper to safely get bool from int (0/1) or bool (true/false)
    bool parseBool(dynamic value) {
      if (value is bool) return value;
      if (value is int) return value == 1;
      return false;
    }

    return Cat(
      catId: int.tryParse(map['catId'].toString()) ?? 0,
      catName: map['catName'] as String? ?? '',
      ownerName: map['ownerName'] as String? ?? '',
      ownerPhone: map['ownerPhone'] as String? ?? '',
      breed: map['breed'] as String? ?? '',
      gender: map['gender'] as String? ?? 'Male',
      dob: int.tryParse(map['dob'].toString()) ?? 0,
      profilePhotoPath: map['profilePhotoPath'] as String? ?? '',
      imagePath: map['imagePath'] as String?,
      permanentAlert: map['permanentAlert'] as String? ?? '',
      furColor: map['furColor'] as String? ?? '',
      eyeColor: map['eyeColor'] as String? ?? '',
      weight: double.tryParse(map['weight'].toString()) ?? 0.0,
      isSterile: parseBool(map['isSterile']),
    );
  }
}
