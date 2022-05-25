import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/profile_provider.dart';
import 'location_picker.dart';

class LocationPickerWidget extends StatelessWidget {
  const LocationPickerWidget({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileProvider>(
      builder: (context, profileProvider, _) {
        return Row(
          children: [
            const Text('居住エリア ',),
            Text(locationPicker[profileProvider.myProfile.location] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
            TextButton(
              child: const Text('選択'),
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  builder: (BuildContext context) {
                    return Container(
                      height: MediaQuery.of(context).size.height / 2,
                      child: Column(
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              TextButton(
                                child: const Text('戻る'),
                                onPressed: () => Navigator.pop(context),
                              ),
                              TextButton(
                                child: const Text('決定'),
                                onPressed: () {
                                  profileProvider.notifyListeners();
                                  Navigator.pop(context);
                                },
                              ),
                            ],
                          ),
                          Container(
                            height: MediaQuery.of(context).size.height / 3,
                            child: CupertinoPicker(
                              itemExtent: 40,
                              children: [
                                for (String key in locationPicker.keys) ... {
                                  Text(locationPicker[key] ?? '居住地不明')
                                },
                              ],
                              onSelectedItemChanged: (int index) => profileProvider.myProfile.location = locationPicker.keys.elementAt(index),
                            ),
                          )
                        ],
                      ),
                    );
                  }
                );
              },
            ),
          ],
        );
      }
    );
  }
}