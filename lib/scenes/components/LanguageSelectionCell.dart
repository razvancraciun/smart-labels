


import 'package:flutter/cupertino.dart';
import 'package:smart_labels2/model/Constants.dart';
import 'package:smart_labels2/model/Language.dart';
import 'package:flutter/material.dart';

class LanguageSelectionCellDelegate {
    void didTapCell(Language language) {}
}



class LanguageSelectionCell extends StatelessWidget {
    final Language _language;
    final bool _selected;

    final LanguageSelectionCellDelegate delegate;

    LanguageSelectionCell(this._language, this._selected, this.delegate);

    @override
    Widget build(BuildContext context) {

        return GestureDetector(
            child: Container(
                margin: EdgeInsets.only(top: 5, bottom: 5, right: 10, left: 10),
                child:ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: Container(

                        child: Center(
                            child: Text(_language.description, style: TextStyle(fontSize: 25, color: _selected ? Colors.black : Colors.white),
                            ),
                        ),
                        padding: EdgeInsets.all(20),
                        color: _selected ? SmartLabelsColors.blue : SmartLabelsColors.gray2,
                    ),


                    ),
            ),
            onTap: () => delegate.didTapCell(_language),
        );
    }

}