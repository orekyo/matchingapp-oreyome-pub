import 'package:flutter/material.dart';
import 'package:matchingappweb/providers/profile_provider.dart';
import 'package:matchingappweb/widgets/drawer_widget.dart';
import 'package:provider/provider.dart';

import '../widgets/bottom_nav_bar_widget.dart';
import '../widgets/profile_list_widget.dart';


class ApproachedScreen extends StatelessWidget {
  const ApproachedScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('いいねをくれた人'),
      ),
      body: Consumer<ProfileProvider>(
        builder: (context, profileProvider, _) {
          return ProfileListWidget(profiles: profileProvider.profileApproachedList);
        },
      ),
      drawer: DrawerWidget(),
      bottomNavigationBar: BottomNavBarWidget(),
    );
  }
}