class MessageModel {
  late int? id = 0;
  late String sender = '';
  late String receiver = '';
  late String message = '';
  late String? createdAt;

  MessageModel({
    this.id,
    required this.sender,
    required this.receiver,
    required this.message,
    this.createdAt,
  });
}