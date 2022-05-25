import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:matchingappweb/providers/login_provider.dart';
import 'package:matchingappweb/providers/profile_provider.dart';
import 'package:matchingappweb/screens/approached_screen.dart';
import 'package:matchingappweb/screens/approaching_screen.dart';
import 'package:matchingappweb/screens/login_screen.dart';
import 'package:matchingappweb/screens/matching_screen.dart';
import 'package:matchingappweb/screens/menu_screen.dart';
import 'package:matchingappweb/screens/message_screen.dart';
import 'package:matchingappweb/screens/my_profile_screen.dart';
import 'package:matchingappweb/screens/profile_detail_screen.dart';
import 'package:matchingappweb/screens/profiles_screen.dart';
import 'package:matchingappweb/screens/signup_screen.dart';
import 'package:provider/provider.dart';


Future<void> main() async {
  await dotenv.load(fileName: ".env.dev");
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LoginProvider()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget  {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MenuScreen(),
      routes: <String, WidgetBuilder>{
        '/menu': (BuildContext context) => MenuScreen(),
        '/login': (BuildContext context) => LoginScreen(),
        '/signup': (BuildContext context) => SignupScreen(),
        '/my-profile': (BuildContext context) => MyProfileScreen(),
        '/looking': (BuildContext context) => ProfilesScreen(),
        '/favorite': (BuildContext context) => ApproachingScreen(),
        '/chance': (BuildContext context) => ApproachedScreen(),
        '/matching': (BuildContext context) => MatchingScreen(),
        '/message': (BuildContext context) => MessageScreen(),
        '/profile-detail': (BuildContext context) => ProfileDetailScreen(),
      },
    );
  }
}
