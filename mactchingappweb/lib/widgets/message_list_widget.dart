import 'package:flutter/material.dart';
import 'package:matchingappweb/models/message_model.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../providers/profile_provider.dart';

class MessageListWidget extends StatelessWidget {
  MessageListWidget({
    Key? key,
    required List<MessageModel> messages,
  }) : _messages = messages, super(key: key);

  final List<MessageModel> _messages;
  // Flutter Web の場合 dotenv.get('BACKEND_URL_HOST_CASE_FLUTTER_WEB')
  final Uri _uriHost = Uri.parse(dotenv.get('BACKEND_URL_HOST'));

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileProvider>(
      builder: (context, profileProvider, _) {
        return ListView.builder(
          itemCount: _messages.length,
          itemBuilder: (BuildContext context, int index) {
            String imageUrl = profileProvider.myProfile.topImage ?? '';
            String sender = profileProvider.myProfile.nickname;
            String createdAt = _messages[index].createdAt ?? '';
            if(_messages[index].sender == profileProvider.profileDetail!.user) {
              imageUrl = profileProvider.profileDetail!.topImage ?? '';
              sender = profileProvider.profileDetail!.nickname;
            }
            if(imageUrl != '') imageUrl.replaceFirst(dotenv.get('STORAGE_URL_HOST'), _uriHost.toString());
            return ListTile(
              leading: imageUrl != '' ?
                Image.network(imageUrl,
                  errorBuilder: (context, error, stackTrace) {
                    return Image.asset('images/nophotos.png',);
                  },
                ) :
                Image.asset('images/nophotos.png',),
              title: Text('$index ${_messages[index].message}'),
              subtitle: Text('$sender $createdAt'),
            );
          },
        );
      }
    );
  }
}