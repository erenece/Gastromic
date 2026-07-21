class SettingsProfileModel {
  final String name;
  final String bio;
  final String photoUrl;
  final int visitCount;
  final int membershipYears;
  final bool notificationsEnabled;

const SettingsProfileModel({
  required this.name,
  required this.bio,
  required this.photoUrl,
  required this.visitCount,
  required this.membershipYears,
  required this.notificationsEnabled,

});

factory SettingsProfileModel.fromMap(Map<String, dynamic> map){
  return SettingsProfileModel(
    name: map['name'] ?? '',
    bio: map['bio'] ?? '',
    photoUrl: map['photoUrl'] ?? '',
    visitCount: map['visitCount'] ?? 0,
    membershipYears: map['membershipYears'] ?? 0,
    notificationsEnabled: map['notificationsEnabled'] ?? true,
  );
}

Map<String, dynamic> toMap() {
  return{
    'name': name,
    'bio' : bio,
    'photoUrl' : photoUrl,
    'visitCount' : visitCount,
    'membershipYears' : membershipYears,
    'notificationsEnabled' : notificationsEnabled,
  };
}  


}