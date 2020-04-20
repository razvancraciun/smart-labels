


import 'package:flutter/cupertino.dart';
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
                    decoration: BoxDecoration(
                        color: _selected ? Colors.lightBlueAccent : Colors.white,
                        border: Border(
                            bottom: BorderSide(width: 1.0, color: Colors.black54),
                        ),
                    ),
                    child: Center(child: Text(_language.description, style: TextStyle(fontSize: 25),),),
                    padding: EdgeInsets.all(10),

            ),
            onTap: () => delegate.didTapCell(_language),
        );
    }

}