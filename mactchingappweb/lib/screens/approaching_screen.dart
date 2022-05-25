import 'package:flutter/material.dart';
import 'package:matchingappweb/providers/profile_provider.dart';
import 'package:matchingappweb/widgets/drawer_widget.dart';
import 'package:provider/provider.dart';

import '../widgets/bottom_nav_bar_widget.dart';
import '../widgets/profile_list_widget.dart';


class ApproachingScreen extends StatelessWidget {
  const ApproachingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('いいねした人'),
      ),
      body: Consumer<ProfileProvider>(
        builder: (context, profileProvider, _) {
          return ProfileListWidget(profiles: profileProvider.profileApproachingList);
        },
      ),
      drawer: DrawerWidget(),
      bottomNavigationBar: BottomNavBarWidget(),
    );
  }
}