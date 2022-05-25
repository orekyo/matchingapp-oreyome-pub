import 'package:flutter/material.dart';
import 'package:matchingappweb/providers/profile_provider.dart';
import 'package:matchingappweb/widgets/drawer_widget.dart';
import 'package:matchingappweb/widgets/message_list_widget.dart';
import 'package:provider/provider.dart';
import '../utils/show_snack_bar.dart';
import '../widgets/bottom_nav_bar_widget.dart';


class MessageScreen extends StatelessWidget {
  const MessageScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileProvider>(
      builder: (context, profileProvider, _) {
        return Scaffold(
          appBar: AppBar(
            title: Text('${profileProvider.profileDetail!.nickname}とのメッセージ'),
          ),
          body: Column(
            children: [
              Expanded(child: MessageListWidget(messages: profileProvider.messageList,),),
              Padding(
                padding: const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 4.0),
                child: TextFormField(
                  onChanged: (value) => profileProvider.newMessage = value,
                  decoration: InputDecoration(
                    labelText: 'メッセージを送りましょう',
                    suffixIcon: IconButton(
                        onPressed: () {
                          profileProvider.createMessage().then((isSuccess) {
                            if (isSuccess) {
                              showSnackBar(context, 'メッセージが送信されました');
                            } else {
                              showSnackBar(context, 'エラーが発生しました');
                            }
                          });
                        },
                        icon: const Icon(Icons.send)
                    ),
                  ),
                  maxLength: 500,
                ),
              ),
            ],
          ),
          drawer: const DrawerWidget(),
          bottomNavigationBar: const BottomNavBarWidget(),
        );
      },
    );

  }
}