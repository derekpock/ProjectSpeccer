
import 'dart:html';
import '../CSSClasses.dart';

typedef TopHeaderButtonClickedCallback();

class TopHeaderButton {
  DivElement _topHeaderButton;

  TopHeaderButton(String title, TopHeaderButtonClickedCallback thbcc) {
    _topHeaderButton = new DivElement();
    _topHeaderButton.setInnerHtml(title);
    _topHeaderButton.classes.add(CSSClasses.button);
    _topHeaderButton.classes.add(CSSClasses.clickable);
    _topHeaderButton.classes.add(CSSClasses.uiHeaderButton);
    _topHeaderButton.onClick.listen((_) => thbcc());
  }

  void setHidden(bool hidden) {
    _topHeaderButton.classes.toggle(CSSClasses.hidden, hidden);
  }

  DivElement getElement() {
    return _topHeaderButton;
  }
}