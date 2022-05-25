import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:matchingappweb/pickers/graduation_picker.dart';
import 'package:provider/provider.dart';
import '../providers/profile_provider.dart';

class GraduationPickerWidget extends StatelessWidget {
  const GraduationPickerWidget({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileProvider>(
        builder: (context, profileProvider, _) {
          return Row(
            children: [
              const Text('最終学歴 ',),
              Text(graduationPicker[profileProvider.myProfile.graduation] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
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
                                    for (String key in graduationPicker.keys) ... {
                                      Text(graduationPicker[key] ?? '最終学歴不詳')
                                    },
                                  ],
                                  onSelectedItemChanged: (int index) => profileProvider.myProfile.graduation = graduationPicker.keys.elementAt(index),
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