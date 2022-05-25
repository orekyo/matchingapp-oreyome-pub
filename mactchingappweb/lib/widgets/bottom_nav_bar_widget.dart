import 'package:flutter/material.dart';


class BottomNavBarWidget extends StatelessWidget {
  const BottomNavBarWidget({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      items: [
        BottomNavigationBarItem(
          label: '相手探し',
          icon: IconButton(
            icon: const Icon(Icons.wc),
            onPressed: () {
              // Navigator.pushNamed(context, '/looking');
            },
          )
        ),
        BottomNavigationBarItem(
            label: 'いいねリスト',
            icon: IconButton(
              icon: const Icon(Icons.volunteer_activism),
              onPressed: () {
                // Navigator.pushNamed(context, '/chance');
              },
            )
        ),
        BottomNavigationBarItem(
            label: 'メッセージ',
            icon: IconButton(
              icon: const Icon(Icons.message),
              onPressed: () {
                // Navigator.pushNamed(context, '/message');
              },
            )
        ),
      ],
    );
  }
}
