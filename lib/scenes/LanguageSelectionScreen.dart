


import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:smart_labels2/model/Constants.dart';
import 'package:smart_labels2/model/Language.dart';
import 'package:smart_labels2/scenes/components/LanguageSelectionCell.dart';
import 'package:smart_labels2/model/AppState.dart';
import 'package:hive/hive.dart';

class LanguageSelectionScreen extends StatefulWidget {
    @override
    State<StatefulWidget> createState() {
        return LanguageSelectionScreenState();
    }
}

class LanguageSelectionScreenState extends State<LanguageSelectionScreen> implements LanguageSelectionCellDelegate {
    AppState _appState = AppState();

    @override
    Widget build(BuildContext context) {
        return Scaffold(
            appBar: AppBar(
                title: const Text('Select a language'),
                actions: <Widget>[
                    FlatButton(
                        child: Text('Done', style: TextStyle(fontSize: 20, color: _appState.selectedLanguage == null ? Colors.white60 : Colors.white),),
                        onPressed: _appState.selectedLanguage == null ? null : () async {
                                await Hive.openBox(_appState.selectedLanguage.code);
                                Hive.box(HiveKeys.configBox).put(HiveKeys.selectedLanguageKey, _appState.selectedLanguage.code);
                                Navigator.pushNamed(context, Routes.mainScreen);
                            },
                    )
                ],
            ),
            body: ListView.builder(itemBuilder: (context, index) {
                if(index >= Language.values.length) {
                    return null;
                }
                return LanguageSelectionCell(Language.values[index], Language.values[index] == _appState.selectedLanguage, this);
            }),
        );
    }

    @override
    void didTapCell(Language language) {
        setState(() {
          if(language == _appState.selectedLanguage) {
              _appState.selectedLanguage = null;
          } else {
              _appState.selectedLanguage = language;
          }
        });
    }
}