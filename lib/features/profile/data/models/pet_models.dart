class PetDetailPayload {
  final int petId;
  final double weight;
  final int activityLevel;
  final int bcs;
  final bool neutered;
  final bool? lactation;
  final bool? gestation;
  final String? gestationStartDate;

  const PetDetailPayload({
    required this.petId,
    required this.weight,
    required this.activityLevel,
    required this.bcs,
    required this.neutered,
    this.lactation,
    this.gestation,
    this.gestationStartDate,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'pet_id': petId,
      'weight': weight,
      'activity_level': activityLevel,
      'bcs': bcs,
      'neutered': neutered,
    };
    if (lactation != null) {
      map['lactation'] = lactation;
    }
    if (gestation != null) {
      map['gestation'] = gestation;
    }
    if (gestationStartDate != null && gestationStartDate!.trim().isNotEmpty) {
      map['gestation_startdate'] = gestationStartDate!.trim();
    }
    return map;
  }
}

class PetInfoPayload {
  final int petId;
  final String name;
  final int type;
  final String breed;
  final int sexType;
  final String birthDate;
  final String? imagePath;

  const PetInfoPayload({
    required this.petId,
    required this.name,
    required this.type,
    required this.breed,
    required this.sexType,
    required this.birthDate,
    this.imagePath,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'id': petId,
      'name': name.trim(),
      'type': type,
      'breed': breed.trim(),
      'sex_type': sexType,
      'birth_date': birthDate.trim(),
    };
    if (imagePath != null && imagePath!.trim().isNotEmpty) {
      map['image_path'] = imagePath!.trim();
    }
    return map;
  }
}

class CreatePetPayload {
  final PetInfoPayload petInfo;
  final PetDetailPayload petDetail;

  const CreatePetPayload({required this.petInfo, required this.petDetail});

  Map<String, dynamic> toJson() {
    return {
      'pet_info': petInfo.toJson()
        ..remove('id')
        ..remove('pet_id'),
      'pet_detail': petDetail.toJson()..remove('pet_id'),
    };
  }
}

class PetProfileData {
  final int id;
  final String name;
  final String weightLabel;
  final String type;
  final String breed;
  final String gender;
  final String birthDate;
  final String weight;

  const PetProfileData({
    required this.id,
    required this.name,
    required this.weightLabel,
    required this.type,
    required this.breed,
    required this.gender,
    required this.birthDate,
    required this.weight,
  });
}
