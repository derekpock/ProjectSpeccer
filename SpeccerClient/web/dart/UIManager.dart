import 'dart:html';
import 'CSSClasses.dart';
import 'DBClient.dart';
import 'Requests/RequestPing.dart';
import 'UIManagerInteractionInterface.dart';
import 'UIPage.dart';

class UIManager implements UIManagerInteractionInterface {

  DBClient _dbClient;

  List<UIPage> _pages;
  PageHome _pageHome;
  PageLogin _pageLogin;
  PageRegister _pageRegister;
  PageLogout _pageLogout;

  DivElement _divUIManager;
  DivElement _divHeader;

  String _authUsername;
  String _authPass;

  UIManager(DBClient dbClient) {
    _dbClient = dbClient;
    _dbClient.setUimii(this);
    _dbClient.makeRequest(new RequestPing());

    _divUIManager = document.getElementById("uiManager");

    _divHeader = new DivElement();
    _divHeader.id = "topHeader";

    _pages = new List();
    _pages.add(_pageHome = new PageHome(this));
    _pages.add(_pageLogin = new PageLogin(this));
    _pages.add(_pageRegister = new PageRegister(this));
    _pages.add(_pageLogout = new PageLogout(this));


    _divUIManager.append(_divHeader);
    _pageHome.getTopHeaderButton().onClick.listen((_) => setActivePage(_pageHome));
    _pageLogin.getTopHeaderButton().onClick.listen((_) => setActivePage(_pageLogin));
    _pageRegister.getTopHeaderButton().onClick.listen((_) => setActivePage(_pageRegister));
    _pageLogout.getTopHeaderButton().onClick.listen((_) => userLoggedOut());

    _pages.forEach((UIPage page) {
      _divUIManager.append(page.getElement());
      _divHeader.append(page.getTopHeaderButton());
    });

    userLoggedOut();
  }

  DBClient getDBClient() {
    return _dbClient;
  }

  void setActivePage(UIPage activePage) {
    _pages.forEach((UIPage page) {
      if(page.hidden == (page == activePage)) {
        page.getElement().classes.toggle(CSSClasses.hidden);
        page.hidden = !page.hidden;
      }
    });
  }

  String getAuthPassword() {
    return _authPass;
  }

  String getAuthUsername() {
    return _authUsername;
  }

  void userLoggedIn(String username, String password) {
    _authUsername = username;
    _authPass = password;

    _pageRegister.reset();
    _pageLogin.reset();

    _pageRegister.getTopHeaderButton().classes.toggle(CSSClasses.hidden, true);
    _pageLogin.getTopHeaderButton().classes.toggle(CSSClasses.hidden, true);
    _pageLogout.getTopHeaderButton().classes.toggle(CSSClasses.hidden, false);

    setActivePage(_pageHome);
  }

  void userLoggedOut() {
    _authUsername = null;
    _authPass = null;

    _pageRegister.getTopHeaderButton().classes.toggle(CSSClasses.hidden, false);
    _pageLogin.getTopHeaderButton().classes.toggle(CSSClasses.hidden, false);
    _pageLogout.getTopHeaderButton().classes.toggle(CSSClasses.hidden, true);
  }

  void pongReceived() {
    querySelector("#output").text += " Response received from server.";
  }

  void newPasswordInvalid() {
    setActivePage(_pageRegister);
    _pageRegister.invalidPassword();
  }

  void usernameTaken() {
    setActivePage(_pageRegister);
    _pageRegister.usernameTaken();
  }

  void badLogin() {
    _pageLogin.invalidLogin();
  }

}