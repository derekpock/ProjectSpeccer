
part of '../UIPage.dart';

class PageError extends UIPage {
  DivElement _text;

  PageError(UIManagerInteractionInterface uimii) :
        super(uimii, true, true, false, "Uh oh!", "") {
    _text = new DivElement();
    _text.setInnerHtml("This is an error page that hasn't been set! You shouldn't be here!");
    _content.append(_text);
  }

  void setError(PageErrorTypes type) {
    switch(type) {
      case PageErrorTypes.NotAuthorized:
        _text.setInnerHtml("Mr. Server says you're not allowed in there! Try logging in first.");
        break;
    }
  }
}

enum PageErrorTypes {
  NotAuthorized
}