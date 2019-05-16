import 'dart:html';
import 'dart:convert';
import 'CSSClasses.dart';
import 'DBClient.dart';
import 'DesignElements/TopHeaderButton.dart';
import 'Requests/RequestGetComponents.dart';
import 'Requests/RequestGetRoles.dart';
import 'Requests/RequestPing.dart';
import 'Structures/Component.dart';
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
  PageError      _pageError;

  TopHeaderButton _butBrowse;
  TopHeaderButton _butHome;
  TopHeaderButton _butLogin;
  TopHeaderButton _butLogout;
  TopHeaderButton _butMyProjects;
  TopHeaderButton _butRegister;
  TopHeaderButton _butComments;

  DivElement _divUI;
  DivElement _divUIHeader;
  DivElement _divUIBody;
  DivElement _divUIBodyContent;
  DivElement _divUIBodyPane;

  DivElement _divTopHeaderText;

  String _authUsername;
  String _authPass;
  String _uid;

  Map<String, Role> _roles;
  Map<String, Project> _projects;

  List<Role> _awaitedProjectRoles;
  String _awaitingProject;
  bool _firstPull;
  bool _contentAdded;

  UIManager(DBClient dbClient) {
    querySelector("#output").classes.add(CSSClasses.hidden);
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
    _pageError = new PageError(this);

    // Add pages with content to list.
    _pagesWithContent = new List();
    _pagesWithContent.add(_pageBrowse);
    _pagesWithContent.add(_pageHome);
    _pagesWithContent.add(_pageLogin);
    _pagesWithContent.add(_pageMyProjects);
    _pagesWithContent.add(_pageProject);
    _pagesWithContent.add(_pageRegister);
    _pagesWithContent.add(_pageError);

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
    _butComments = new TopHeaderButton("Comments", () => toggleCommentsPane());

    // Add page header buttons to div.
    // PageProject does not have a button.
    _divUIHeader.append(_butHome.getElement());
    _divUIHeader.append(_butBrowse.getElement());

    _divUIHeader.append(_butRegister.getElement());
    _divUIHeader.append(_butLogin.getElement());

    _divUIHeader.append(_butMyProjects.getElement());
    _divUIHeader.append(_butLogout.getElement());;

    DivElement headerSpacer1 = new DivElement();
    headerSpacer1.style.flex = "1";
    _divUIHeader.append(headerSpacer1);

    _divTopHeaderText = new DivElement();
    _divTopHeaderText.append(new Text("Home"));
    _divTopHeaderText.classes.add(CSSClasses.topHeaderText);
    _divUIHeader.append(_divTopHeaderText);

    DivElement headerSpacer2 = new DivElement();
    headerSpacer2.style.flex = "1";
    _divUIHeader.append(headerSpacer2);

    _divUIHeader.append(_butComments.getElement());

    // Add divs to parent divs.
    _divUIBody.append(_divUIBodyContent);
    _divUIBody.append(_divUIBodyPane);

    // Prepare data elements.
    _contentAdded = false;
    _firstPull = true;
    _projects = new Map();
    _roles = new Map();

    _dbClient = dbClient;
    _dbClient.setUimii(this);
    _dbClient.makeRequest(new RequestPing());

    // Prepare event listeners.
    window.onPopState.listen((PopStateEvent e) => loadPageFromHash());

    userLoggedOut();
    refreshProjectsAndRoles();
  }

  void loadPageFromHash() {
    if(window.location.hash.isNotEmpty && window.location.hash[0] == '#') {
      String hashlessHash = window.location.hash.substring(1);
      _pagesWithContent.forEach((UIPage page) {
        if(!(page.needsProjectSustenance() && _firstPull) &&
            page.loadFromUrl(hashlessHash) &&
            page != _pageError) {
          _firstPull = false;
          setActivePageWithoutHistory(page);
        }
      });
    } else {
      window.history.replaceState(null, "", "#" + _pageHome.saveToUrl());
    }
  }

  void updateProjectDependentPages() {
    _pageBrowse.refresh(_projects, _roles);
    _pageMyProjects.refresh(
        _projects.values.where((Project p) =>
            _roles.containsKey(p.getPid()) && _roles[p.getPid()].isOwner()).toList()
    );
  }

  void toggleCommentsPane() {
    _divUIBodyPane.classes.toggle(CSSClasses.hidden);
  }

  void setActivePageWithoutHistory(UIPage activePage) {
    _pagesWithContent.forEach((UIPage page) {
      if(page.hidden == (page == activePage)) {
        page.getElement().classes.toggle(CSSClasses.hidden);
        page.hidden = !page.hidden;
      }
    });

    while(_divTopHeaderText.childNodes.isNotEmpty) {
      _divTopHeaderText.childNodes.last.remove();
    }

    _divTopHeaderText.append(new Text(activePage.headerText));
  }

  void refreshProjectsAndRoles() {
    getDBClient().makeRequest(new RequestBrowseProjects(getAuthUsername(), getAuthPassword()));
  }

  DBClient getDBClient() {
    return _dbClient;
  }

  void setActivePage(UIPage activePage) {
    if(activePage.hidden) {
      addNavigation(activePage.saveToUrl());
    }
    setActivePageWithoutHistory(activePage);
  }

  String getAuthPassword() {
    return _authPass;
  }

  String getAuthUsername() {
    return _authUsername;
  }

  void userLoggedIn(String username, String password, String uid) {
    _authUsername = username;
    _authPass = password;
    _uid = uid;

    _pageRegister.reset();
    _pageLogin.reset();

    _butRegister.setHidden(true);
    _butLogin.setHidden(true);
    _butMyProjects.setHidden(false);
    _butLogout.setHidden(false);

    _pageRegister.enabled = false;
    _pageLogin.enabled = false;
    _pageMyProjects.enabled = true;

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

    _pageRegister.enabled = true;
    _pageLogin.enabled = true;
    _pageMyProjects.enabled = false;
  }

  void pongReceived() {
    if(!_contentAdded) {
      _divUI.append(_divUIHeader);
      _divUI.append(_divUIBody);
      _contentAdded = true;
    }
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
    _projects[p.getPid()] = p;
    _roles[p.getPid()] = new Role(getAuthPassword(), getUid(), p.getPid(), true, true);

    updateProjectDependentPages();
  }

  /*

  pid	is_public	is_owner	is_developer	data

   */
  void receivedUpdatedProjects(List<dynamic> rawProjectQuery) {
    // 0 pid
    // 1 is_public
    // 2 is_owner
    // 3 is_developer
    // 4 data

    //TODO check if anything changed instead of always setting and refreshing
    _projects.clear();
    _roles.clear();

    rawProjectQuery.forEach((dynamic projInfo) {
      projInfo = projInfo as List<dynamic>;
      String name;
      if(projInfo[4] != null) {
        Map<String, dynamic> jsonData = jsonDecode(projInfo[4]);
        name = jsonData["data"];
      }
      if(name == null || name.isEmpty) {
        name = "[project not named]";
      }

      _projects[projInfo[0]] = new Project(projInfo[0], projInfo[1], name);
      bool isOwner = projInfo[2];
      bool isDeveloper = projInfo[3];

      if(isOwner == null) {
        isOwner = false;
      }

      if(isDeveloper == null) {
        isDeveloper = false;
      }
      _roles[projInfo[0]] = new Role(getAuthUsername(), getUid(), projInfo[0], isOwner, isDeveloper);
    });

    updateProjectDependentPages();
    if(_firstPull) {
      _firstPull = false;
      loadPageFromHash();
    }
  }

  void openProject(String pid) {
    _awaitingProject = pid;
    _pageProject.openProject(_projects[pid], _roles[pid]);
    setActivePage(_pageProject);
    getDBClient().makeRequest(new RequestGetComponents(getAuthUsername(), getAuthPassword(), pid));
    getDBClient().makeRequest(new RequestGetRoles(getAuthUsername(), getAuthPassword(), pid));
    //TODO waiting for components
  }

  void updatedProject(String pid, bool isPublic, String name) {
    Project p = new Project(pid, isPublic, name);
    _projects[pid] = p;
    _pageProject.openProject(p, _roles[p.getPid()]);

    updateProjectDependentPages();
  }

  void addNavigation(String url) {
    window.history.pushState(null, "", "#" + url);
  }

  void receivedComponents(String pid, List<List<Component>> components) {
    _pageProject.refreshComponents(pid, components);
    _awaitingProject = null;
    if(_awaitedProjectRoles != null) {
      _pageProject.refreshProjectRoles(pid, _awaitedProjectRoles);
      _awaitedProjectRoles = null;
    }
  }

  void receivedProjectRoles(String pid, List<Role> roles) {
    if(_awaitingProject != null) {
      if(_awaitingProject == pid) {
        _awaitedProjectRoles = roles;
      }
    } else {
      _pageProject.refreshProjectRoles(pid, roles);
    }
  }

  void receivedSetRoleFailed() {
    _pageProject.receivedSetRoleFailed();
  }

  String getUid() {
    return _uid;
  }

  void authenticationError() {
    _pageError.setError(PageErrorTypes.NotAuthorized);
    setActivePage(_pageError);
  }

  void setHeaderText(String text) {
    while(_divTopHeaderText.childNodes.isNotEmpty) {
      _divTopHeaderText.childNodes.last.remove();
    }

    _divTopHeaderText.append(new Text(text));
  }
}