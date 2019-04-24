library UIPage;

import 'dart:html';
import 'CSSClasses.dart';
import 'UIManagerInteractionInterface.dart';
import 'DesignElements/Form.dart';
import 'Requests/RequestAddUser.dart';
import 'Requests/RequestLogin.dart';

part 'UIPages/PageHome.dart';
part 'UIPages/PageLogin.dart';
part 'UIPages/PageLogout.dart';
part 'UIPages/PageRegister.dart';

class UIPage {
  UIManagerInteractionInterface _uimii;

  DivElement _element;
  DivElement _topHeaderButton;

  HeadingElement _header;
  DivElement _content;

  bool hidden;

  UIPage(UIManagerInteractionInterface uimii, bool hidden, String title) {
    this.hidden = hidden;
    _uimii = uimii;

    _element = new DivElement();
    _element.classes.add(CSSClasses.uiPage);
    if(hidden) {
      _element.classes.add(CSSClasses.hidden);
    }

    _topHeaderButton = new DivElement();
    _topHeaderButton.setInnerHtml(title);
    _topHeaderButton.classes.add(CSSClasses.button);
    _topHeaderButton.classes.add(CSSClasses.clickable);
    _topHeaderButton.classes.add(CSSClasses.topHeaderButton);

    _header = new HeadingElement.h2();
    _header.setInnerHtml(title);
    _header.classes.add(CSSClasses.uiPageHeader);

    _content = new DivElement();
    _content.classes.add(CSSClasses.uiPageContent);

    _element.append(_header);
    _element.append(_content);
  }

  DivElement getElement() {
    return _element;
  }

  DivElement getTopHeaderButton() {
    return _topHeaderButton;
  }
}