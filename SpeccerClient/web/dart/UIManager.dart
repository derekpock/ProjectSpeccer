import 'dart:html';
import 'CSSClasses.dart';
import 'UIManagerInteractionInterface.dart';
import 'UIPage.dart';

class UIManager implements UIManagerInteractionInterface {

  List<UIPage> _pages;

  DivElement _divUIManager;
  DivElement _divHeader;

  UIManager() {
    _divUIManager = document.getElementById("uiManager");

    _divHeader = new DivElement();
    _divHeader.id = "topHeader";

    _pages = new List();
    _pages.add(new PageHome(this));
    _pages.add(new PageLogin(this));
    _pages.add(new PageRegister(this));

    _divUIManager.append(_divHeader);

    _pages.forEach((UIPage page) {
      _divUIManager.append(page.getElement());
      _divHeader.append(
          page.getTopHeaderButton()
            ..onClick.listen((_) => setActivePage(page))
      );
    });
  }

  void setActivePage(UIPage activePage) {
    _pages.forEach((UIPage page) {
      if(page.hidden == (page == activePage)) {
        page.getElement().classes.toggle(CSSClasses.hidden);
        page.hidden = !page.hidden;
      }
    });
  }
}