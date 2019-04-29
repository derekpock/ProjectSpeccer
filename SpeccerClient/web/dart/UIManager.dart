import 'dart:html';
import 'CSSClasses.dart';
import 'DBClient.dart';
import 'DesignElements/TopHeaderButton.dart';
import 'Requests/RequestPing.dart';
import 'UIManagerInteractionInterface.dart';
import 'UIPage.dart';
import 'Structures/Role.dart';
import 'Structures/Project.dart';
import 'Requests/RequestBrowseProjects.dart';

class UIManager implements UIManagerInteractionInterface {

  DBClient _dbClient;

  List<UIPage> _pagesWithContent;

  PageBrowse     _pageBrowse;
  PageHome       _pageHome;
  PageLogin      _pageLogin;
  PageMyProjects _pageMyProjects;
  PageProject    _pageProject;
  PageRegister   _pageRegister;

  TopHeaderButton _butBrowse;
  TopHeaderButton _butHome;
  TopHeaderButton _butLogin;
  TopHeaderButton _butLogout;
  TopHeaderButton _butMyProjects;
  TopHeaderButton _butRegister;

  DivElement _divUI;
  DivElement _divUIHeader;
  DivElement _divUIBody;
  DivElement _divUIBodyContent;
  DivElement _divUIBodyPane;

  String _authUsername;
  String _authPass;

  Map<String, Role> _roles;
  List<Project> _projects;

  UIManager(DBClient dbClient) {
    _divUI = document.getElementById("ui");

    _divUIHeader = new DivElement();
    _divUIHeader.id = "uiHeader";

    _divUIBody = new DivElement();
    _divUIBody.id = "uiBody";

    _divUIBodyContent = new DivElement();
    _divUIBodyContent.id = "uiBodyContent";

    _divUIBodyPane = new DivElement();
    _divUIBodyPane.id = "uiBodyPane";

    // Create pages.
    _pageBrowse = new PageBrowse(this);
    _pageHome = new PageHome(this);
    _pageLogin = new PageLogin(this);
    _pageMyProjects = new PageMyProjects(this);
    _pageProject = new PageProject(this);
    _pageRegister = new PageRegister(this);

    // Add pages with content to list.
    _pagesWithContent = new List();
    _pagesWithContent.add(_pageBrowse);
    _pagesWithContent.add(_pageHome);
    _pagesWithContent.add(_pageLogin);
    _pagesWithContent.add(_pageMyProjects);
    _pagesWithContent.add(_pageProject);
    _pagesWithContent.add(_pageRegister);

    // Add page content to div.
    _pagesWithContent.forEach((UIPage page) {
      _divUIBodyContent.append(page.getElement());
    });

    // Create top header buttons.
    _butBrowse = new TopHeaderButton("Browse", () => setActivePage(_pageBrowse));
    _butHome = new TopHeaderButton("Home", () => setActivePage(_pageHome));
    _butLogin = new TopHeaderButton("Login", () => setActivePage(_pageLogin));
    _butLogout = new TopHeaderButton("Logout", userLoggedOut);
    _butMyProjects = new TopHeaderButton("My Projects", () => setActivePage(_pageMyProjects));
    _butRegister = new TopHeaderButton("Register", () => setActivePage(_pageRegister));


    // Add page header buttons to div.
    // PageProject does not have a button.
    _divUIHeader.append(_butHome.getElement());
    _divUIHeader.append(_butBrowse.getElement());

    _divUIHeader.append(_butRegister.getElement());
    _divUIHeader.append(_butLogin.getElement());

    _divUIHeader.append(_butMyProjects.getElement());
    _divUIHeader.append(_butLogout.getElement());;

    // Add divs to parent divs.
    _divUIBody.append(_divUIBodyContent);
    _divUIBody.append(_divUIBodyPane);

    _divUI.append(_divUIHeader);
    _divUI.append(_divUIBody);

    // Prepare data elements.
    _projects = new List();
    _roles = new Map();

    _dbClient = dbClient;
    _dbClient.setUimii(this);
    _dbClient.makeRequest(new RequestPing());

    userLoggedOut();
    refreshProjectsAndRoles();
  }

  void updateProjectDependentPages() {
    _pageBrowse.refresh(_projects, _roles);
    _pageMyProjects.refresh(
        _projects.where((Project p) => _roles.containsKey(p.getPid()) && _roles[p.getPid()].isOwner()).toList()
    );
  }

  void refreshProjectsAndRoles() {
    getDBClient().makeRequest(new RequestBrowseProjects(getAuthUsername(), getAuthPassword()));
  }


  DBClient getDBClient() {
    return _dbClient;
  }

  void setActivePage(UIPage activePage) {
    _pagesWithContent.forEach((UIPage page) {
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

    _butRegister.setHidden(true);
    _butLogin.setHidden(true);
    _butMyProjects.setHidden(false);
    _butLogout.setHidden(false);

    refreshProjectsAndRoles();

    setActivePage(_pageHome);
  }

  void userLoggedOut() {
    if(_authUsername != null || _authPass != null) {
      _authUsername = null;
      _authPass = null;

      refreshProjectsAndRoles();
      setActivePage(_pageLogin);
    }

    _butRegister.setHidden(false);
    _butLogin.setHidden(false);
    _butMyProjects.setHidden(true);
    _butLogout.setHidden(true);

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

  void newProjectCreated(Project p) {
    _projects.add(p);
    _roles[p.getPid()] = new Role(p.getPid(), true, true);

    updateProjectDependentPages();
  }

  void receivedUpdatedProjects(List<Project> projects, Map<String, Role> roles) {
    //TODO check if anything changed instead of always setting and refreshing
    _roles = roles;
    _projects = projects;

    updateProjectDependentPages();
  }

  void openProject(Project p) {

  }
}