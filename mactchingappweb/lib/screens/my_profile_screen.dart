import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:matchingappweb/pickers/graduation_picker_widget.dart';
import 'package:matchingappweb/pickers/passion_picker_widget.dart';
import 'package:matchingappweb/providers/login_provider.dart';
import 'package:matchingappweb/providers/profile_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../pickers/location_picker_widget.dart';
import '../pickers/sex_picker.dart';
import '../utils/show_snack_bar.dart';
import '../widgets/bottom_nav_bar_widget.dart';
import '../widgets/drawer_widget.dart';


class MyProfileScreen extends StatelessWidget {
  const MyProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Flutter Web の場合 dotenv.get('BACKEND_URL_HOST_CASE_FLUTTER_WEB')
    final Uri _uriHost = Uri.parse(dotenv.get('BACKEND_URL_HOST'));

    return Scaffold(
      appBar: AppBar(
        title: const Text('マイプロフィール'),
      ),
      body: Consumer2<ProfileProvider, LoginProvider>(
        builder: (context, profileProvider, loginProvider, _) {
          return Padding(
              padding: const EdgeInsets.all(32.0),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Stack(
                      children: <Widget>[
                        profileProvider.uploadTopImage != null ? 
                          Image.file(profileProvider.uploadTopImage!)  :
                          profileProvider.myProfile.topImage != null ?
                            Image.network('${profileProvider.myProfile.topImage?.replaceFirst(dotenv.get('STORAGE_URL_HOST'), _uriHost.toString())}',
                              width: 100, fit: BoxFit.fill,
                              errorBuilder: (context, error, stackTrace) {
                                return Image.asset('images/nophotos.png',width: 100, fit: BoxFit.fill,);
                              },
                            ) :
                            Image.asset('images/nophotos.png', width: 100, fit: BoxFit.fill,),
                        profileProvider.myProfile.isKyc ?
                          const Icon(Icons.check_circle, color: Colors.greenAccent, size: 16,) :
                          const SizedBox(),
                      ],
                    ),
                    TextButton(
                      child: const Text('画像変更'),
                      onPressed: () => profileProvider.pickTopImage(),
                    ),
                    TextFormField(
                      onChanged: (value) => profileProvider.myProfile.nickname = value,
                      decoration: const InputDecoration(labelText: 'ニックネーム', hintText: 'このフィールドは必須です'),
                      maxLength: 50,
                      initialValue: profileProvider.myProfile.nickname,
                    ),
                    TextFormField(
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      onChanged: (value) => profileProvider.myProfile.age = int.parse(value),
                      decoration: const InputDecoration(labelText: '年齢', hintText: '18歳未満は登録出来ません',),
                      enabled: profileProvider.myProfile.user == null,
                      maxLength: 2,
                      initialValue: profileProvider.myProfile.age.toString(),
                    ),
                    for (String key in sexPicker.keys) ... {
                      RadioListTile(
                        value: key,
                        groupValue: profileProvider.myProfile.sex,
                        title: Text(sexPicker[key] ?? '性別不詳'),
                        selected: profileProvider.myProfile.sex == key,
                        onChanged: (value) {
                          if (profileProvider.myProfile.user == null) {
                            profileProvider.myProfile.sex = value.toString();
                            profileProvider.notifyListeners();
                          }
                          else {
                            null;
                          }
                        },
                      )
                    },
                    TextFormField(
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      onChanged: (value) => profileProvider.myProfile.height = int.parse(value),
                      decoration: const InputDecoration(labelText: '身長cm', hintText: '140cm以上200cm未満で入力してください'),
                      maxLength: 3,
                      initialValue: profileProvider.myProfile.height != null ? profileProvider.myProfile.height.toString() : '',
                    ),
                    const LocationPickerWidget(),
                    TextFormField(
                      onChanged: (value) => profileProvider.myProfile.work = value,
                      decoration: const InputDecoration(labelText: '仕事',),
                      maxLength: 20,
                      initialValue: profileProvider.myProfile.work,
                    ),
                    TextFormField(
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      onChanged: (value) => profileProvider.myProfile.revenue = int.parse(value),
                      decoration: const InputDecoration(labelText: '収入(万円)',),
                      maxLength: 4,
                      initialValue: profileProvider.myProfile.revenue.toString(),
                    ),
                    const GraduationPickerWidget(),
                    TextFormField(
                      onChanged: (value) => profileProvider.myProfile.hobby = value,
                      decoration: const InputDecoration(labelText: '趣味',),
                      maxLength: 20,
                      initialValue: profileProvider.myProfile.hobby,
                    ),
                    const PassionPickerWidget(),
                    TextFormField(
                      onChanged: (value) => profileProvider.myProfile.tweet = value,
                      decoration: const InputDecoration(labelText: 'つぶやき',),
                      maxLength: 10,
                      initialValue: profileProvider.myProfile.tweet,
                    ),
                    TextFormField(
                      keyboardType: TextInputType.multiline,
                      onChanged: (value) => profileProvider.myProfile.introduction = value,
                      decoration: const InputDecoration(labelText: '自己紹介',),
                      maxLength: 1000,
                      maxLines: null,
                      initialValue: profileProvider.myProfile.introduction,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: ElevatedButton(
                        child: profileProvider.myProfile.user == null ? const Text('プロフィールを作成する') : const Text('プロフィールを更新する'),
                        style: ElevatedButton.styleFrom(
                          fixedSize: Size(MediaQuery.of(context).size.width * 0.95, 32),
                        ),
                        onPressed: () {
                          if (profileProvider.myProfile.user == null) {
                            profileProvider.createMyProfile(loginProvider.getUserId()).then((isSuccess) {
                              if (isSuccess) {
                                Navigator.pushReplacementNamed(context, '/my-profile');
                                showSnackBar(context, 'プロフィールが新規作成されました');
                              } else {
                                showSnackBar(context, 'エラーが発生しました');
                              }
                            });
                          }
                          else {
                            profileProvider.updateMyProfile(loginProvider.getUserId()).then((isSuccess) {
                              if (isSuccess) {
                                Navigator.pushReplacementNamed(context, '/my-profile');
                                showSnackBar(context, 'プロフィール更新が完了しました');
                              } else {
                                showSnackBar(context, 'エラーが発生しました');
                              }
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
          );
        },
      ),
      drawer: const DrawerWidget(),
      bottomNavigationBar: const BottomNavBarWidget(),
    );
  }
}
