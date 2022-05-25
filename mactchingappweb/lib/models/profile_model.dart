class ProfileModel {
  late String? user = '';
  late bool isSpecial = false;
  late bool isKyc = false;
  late String? topImage = '';
  late String nickname = '';
  late String? createdAt = '';
  late String? updatedAt = '';
  late int age = 0;
  late String sex = '';
  late int? height = 0;
  late String? location = '';
  late String? work = '';
  late int? revenue = 0;
  late String? graduation = '';
  late String? hobby = '';
  late String? passion = '';
  late String? tweet = '';
  late String? introduction = '';
  late int? sendFavorite = 0;
  late int? receiveFavorite = 0;
  late int? stockFavorite = 0;
  // late String? fromLastLogin = '';

  ProfileModel({
    this.user,
    required this.isSpecial,
    required this.isKyc,
    this.topImage,
    required this.nickname,
    this.createdAt,
    this.updatedAt,
    required this.age,
    required this.sex,
    this.height,
    this.location,
    this.work,
    this.revenue,
    this.graduation,
    this.hobby,
    this.passion,
    this.tweet,
    this.introduction,
    this.sendFavorite,
    this.receiveFavorite,
    this.stockFavorite,
    // this.fromLastLogin,
  });
}