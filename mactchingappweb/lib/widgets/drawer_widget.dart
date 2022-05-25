import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/login_provider.dart';
import '../providers/profile_provider.dart';


class DrawerWidget extends StatelessWidget {
  const DrawerWidget({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Consumer2<LoginProvider, ProfileProvider>(
        builder: (context, loginProvider, profileProvider, _) {
          return ListView(
            children: [
              const DrawerHeader(
                child: Text('ようこそ俺の嫁探しへ', style: TextStyle(color: Colors.white),),
                decoration: BoxDecoration(
                  color: Colors.blue,
                ),
              ),
              ListTile(
                title: const Text("相手を探す"),
                trailing: const Icon(Icons.arrow_forward),
                onTap: () async {
                  bool _isSuccess = await profileProvider.fetchProfileList();
                  if (_isSuccess) Navigator.pushNamed(context, '/looking');
                },
              ),
              ListTile(
                title: const Text("いいねした人を確認する"),
                trailing: const Icon(Icons.arrow_forward),
                onTap: () async {
                  bool _isSuccess = await profileProvider.fetchProfileApproachingList();
                  if (_isSuccess) Navigator.pushNamed(context, '/favorite');
                },
              ),
              ListTile(
                title: const Text("いいねをくれた人を確認する"),
                trailing: const Icon(Icons.arrow_forward),
                onTap: () async {
                  bool _isSuccess = await profileProvider.fetchProfileApproachedList();
                  if (_isSuccess) Navigator.pushNamed(context, '/chance');
                },
              ),
              ListTile(
                title: const Text("メッセージをする"),
                trailing: const Icon(Icons.arrow_forward),
                onTap: () async {
                  bool _isSuccess = await profileProvider.fetchProfileMatchingList();
                  if (_isSuccess) Navigator.pushNamed(context, '/matching');
                },
              ),
              ListTile(
                title: const Text("自己プロフィール"),
                trailing: const Icon(Icons.arrow_forward),
                onTap: () {
                  profileProvider.fetchMyProfile(loginProvider.getUserId())
                    .then( (_) {
                       Navigator.pushNamed(context, '/my-profile');
                    });
                }
              ),
            ],
          );
        }
      )
    );
  }
}