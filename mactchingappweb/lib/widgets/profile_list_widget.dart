import 'package:flutter/material.dart';
import 'package:matchingappweb/models/profile_model.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../providers/profile_provider.dart';

class ProfileListWidget extends StatelessWidget {
  ProfileListWidget({
    Key? key,
    required List<ProfileModel> profiles,
    String? nextUrl,
    Function? nextAction
  }) : _profiles = profiles, _nextUrl = nextUrl ?? '/profile-detail', super(key: key);

  final List<ProfileModel> _profiles;
  final String _nextUrl;
  // Flutter Web の場合 dotenv.get('BACKEND_URL_HOST_CASE_FLUTTER_WEB')
  final Uri _uriHost = Uri.parse(dotenv.get('BACKEND_URL_HOST'));

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileProvider>(
      builder: (context, profileProvider, _) {
        return ListView.builder(
          itemCount: _profiles.length,
          itemBuilder: (BuildContext context, int index) {
            return ListTile(
              leading: Stack(
                children: <Widget>[
                  _profiles[index].topImage != null ?
                  Image.network('${_profiles[index].topImage?.replaceFirst(
                      dotenv.get('STORAGE_URL_HOST'), _uriHost.toString())}',
                    errorBuilder: (context, error, stackTrace) {
                      return Image.asset('images/nophotos.png',);
                    },
                  ) :
                  Image.asset('images/nophotos.png',),
                  _profiles[index].isKyc
                      ?
                  const Icon(
                    Icons.check_circle, color: Colors.greenAccent, size: 16,)
                      :
                  const SizedBox(),
                ],
              ),
              title: Text('${_profiles[index].nickname} ${_profiles[index].age}歳'),
              subtitle: Text(_profiles[index].tweet ?? ''),
              trailing: Icon(
                profileProvider.checkSendFavorite(_profiles[index].user ?? '') ? Icons.favorite : Icons.favorite_border,
                color: Colors.pinkAccent,
              ),
              onTap: () async {
                profileProvider.setProfileDetail(_profiles[index]);
                if(_nextUrl == '/message') await profileProvider.getMessageList();
                Navigator.pushNamed(context, _nextUrl);
              },
            );
          },
        );
      }
    );
  }
}