class MatchingModel {
  late int? id = 0;
  late String? approaching = '';
  late String approached = '';
  late bool approved;
  late String? createdAt;

  MatchingModel({
    this.id,
    this.approaching,
    required this.approached,
    required this.approved,
    this.createdAt,
  });
}