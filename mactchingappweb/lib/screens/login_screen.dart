import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:matchingappweb/providers/profile_provider.dart';
import 'package:provider/provider.dart';
import '../providers/login_provider.dart';
import 'my_profile_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ログインページ'),
      ),
      body: Consumer2<LoginProvider, ProfileProvider>(
        builder: (context, loginProvider, profileProvider, _) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextFormField(
                    onChanged: (value) => loginProvider.email = value,
                    decoration: const InputDecoration(
                      labelText: 'email',
                    ),
                    maxLength: 50,
                  ),
                  Text(loginProvider.message, style: const TextStyle(color: Colors.red),),
                  TextFormField(
                    onChanged: (value) => loginProvider.password = value,
                    decoration: InputDecoration(
                      labelText: 'password',
                      suffixIcon: IconButton(
                          onPressed: () => loginProvider.togglePasswordVisible(),
                          icon: const Icon(Icons.remove_red_eye)
                      ),
                    ),
                    obscureText: loginProvider.hidePassword,
                    maxLength: 50,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: ElevatedButton(
                      child: const Text('ログイン'),
                      style: ElevatedButton.styleFrom(
                        fixedSize: Size(MediaQuery.of(context).size.width * 0.95, 32),
                      ),
                      onPressed: () {
                        loginProvider.setMessage('');
                        if( !EmailValidator.validate(loginProvider.email) ) {
                          loginProvider.setMessage('Email形式で入力してください');
                          return ;
                        }
                        loginProvider.auth()
                          .then( (isSuccess) {
                            if (isSuccess) {
                              profileProvider.fetchMyProfile(loginProvider.getUserId())
                                .then((isSuccess) {
                                  if (isSuccess) {
                                    print('プロフィール作成済みユーザーです');
                                    Navigator.pushAndRemoveUntil(
                                      context,
                                      MaterialPageRoute(builder: (context) => const MyProfileScreen()),
                                          (route) => false,
                                    );
                                  }
                                  else {
                                    print('プロフィール未作成ユーザーです');
                                    Navigator.pushAndRemoveUntil(
                                      context,
                                      MaterialPageRoute(builder: (context) => const MyProfileScreen()),
                                          (route) => false,
                                    );
                                  }
                                });
                            }
                          })
                          .catchError((error) => print(error));
                      },
                    ),
                  )
                ],
              ),
            ),
          );
        }
      ),
    );
  }
}



