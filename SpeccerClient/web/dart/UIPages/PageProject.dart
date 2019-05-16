
part of '../UIPage.dart';

class PageProject extends UIPage implements PageProjectInteractionInterface {

  DivElement _stageContent;
  DivElement _waitContent;
  DivElement _uhohContent;
  Project _p;
  Role _r;
  List<List<Component>> _c;
  StageAccessibility _stageAccessibility;
  List<AbstractStage> _stages;
  int _activeId = 0;
  int _numOfBlockingEvents = 0;
  int _watchScrolling;
  int sx;
  int sy;

  PageProject(UIManagerInteractionInterface uimii) :
        super(uimii, true, true, true, "Project", "project") {

    _watchScrolling = 0;
    sx = 0;
    sy = 0;

    _stages = new List();
    _stages.addAll([
      _stageAccessibility = new StageAccessibility(uimii, this),
      new StageRequirements(uimii, this),
      new StageSpecifications(uimii, this),
      new StageDesign(uimii, this),
      new StageImplementation(uimii, this),
      new StageTesting(uimii, this),
      new StageDistribution(uimii, this)
    ]);

    _stageContent = new DivElement();
    _stages.forEach((AbstractStage stage) {
      _stageContent.append(stage.getElement());
    });

    _waitContent = new DivElement();
    _waitContent.classes.add(CSSClasses.maskContent);
    _waitContent.setInnerHtml("We're pulling the lastest on this project now...");

    _uhohContent = new DivElement();
    _uhohContent.classes.add(CSSClasses.maskContent);
    _uhohContent.setInnerHtml("We're pulling the lastest on this project now...");

    _content.append(_stageContent);
    _content.append(_waitContent);
    _content.append(_uhohContent);
    _setActiveStageWithoutHistory(_stages.first);

    _element.onScroll.listen((_) {
      if(_watchScrolling > 0) {
        _element.scroll(sx, sy);
        _watchScrolling--;
      }
    });

    _element.onMouseWheel.listen((_) {
      _watchScrolling = 0;
    });

  }

  Map<String, String> _saveToUrlData() {
    Map<String, String> saveData = new Map();
    saveData["pid"] = _p?.getPid();
    saveData["stage"] = _activeId.toString();
    return saveData;
  }

  void _loadFromUrlData(Map<String, String> saveData) {
    String pid = saveData["pid"];
    if(pid != null && pid != "null") {
      _uimii.openProject(saveData["pid"]);
      _activeId = int.tryParse(saveData["stage"]);
      if(_activeId == null) {
        _activeId = 0;
      }
      _setActiveStageWithoutHistory(_stages[_activeId]);
    }
  }

  /// Called when a project is selected.
  /// Make do with what you have concerning components - a refreshComponents is
  /// on its way.
  void openProject(Project p, Role r) {
    if(p == null) {
      _p = null;
      _r = null;
      _c = null;
      _numOfBlockingEvents = 2;
      _waitContent.classes.toggle(CSSClasses.hidden, true);
      _uhohContent.classes.toggle(CSSClasses.hidden, false);
      _stageContent.classes.toggle(CSSClasses.hidden, true);
    } else {
      if(_p == null || _p.getPid() != p.getPid()) {
        _numOfBlockingEvents = 2;
        _waitContent.classes.toggle(CSSClasses.hidden, false);
        _uhohContent.classes.toggle(CSSClasses.hidden, true);
        _stageContent.classes.toggle(CSSClasses.hidden, true);
      }

      if(r == null) {
        r = new Role("", "", p.getPid(), false, false);
      }

      _p = p;
      _c = null;
      _r = r;

      _stages.forEach((AbstractStage s) => s.refreshProject(p, r));
    }
  }

  /// You should already be on a project.
  /// Here are its components (either for the first time or again as an update).
  void refreshComponents(String pid, List<List<Component>> c) {
    if(_p != null) {
      if(pid != _p.getPid()) {
        throw "Refreshing components for a different project!";
      } else {
        _c = c;
        sx = _element.scrollLeft;
        sy = _element.scrollTop;
        _stages.forEach((AbstractStage s) => s.refreshComponents());
        if(--_numOfBlockingEvents == 0) {
          _waitContent.classes.toggle(CSSClasses.hidden, true);
          _uhohContent.classes.toggle(CSSClasses.hidden, true);
          _stageContent.classes.toggle(CSSClasses.hidden, false);
        }

        _uimii.setHeaderText(getLiveComponent(ComponentTypes.ProjectName).getDataElement("data", "Project"));

        _watchScrolling = 1;
      }
    }
  }

  void refreshProjectRoles(String pid, List<Role> roles) {
    if(_p != null) {
      if(pid != _p.getPid()) {
        throw "Refreshing project roles for wrong project!";
      } else {
        _stageAccessibility.refreshRoles(roles);
        if(--_numOfBlockingEvents == 0) {
          _waitContent.classes.toggle(CSSClasses.hidden, true);
          _uhohContent.classes.toggle(CSSClasses.hidden, true);
          _stageContent.classes.toggle(CSSClasses.hidden, false);
        }
      }
    }
  }

  void receivedSetRoleFailed() {
    _stageAccessibility.receivedSetRoleFailed();
  }

  void setActiveStage(AbstractStage activeStage) {
    _setActiveStageWithoutHistory(activeStage);
    _uimii.addNavigation(saveToUrl());
  }

  void _setActiveStageWithoutHistory(AbstractStage activeStage) {
    _activeId = activeStage.getId();
    _stages.forEach((AbstractStage stage) {
      stage.setContentVisible(stage == activeStage);
    });
    activeStage.adjustScrollHeight();
  }

  Project getProject() {
    return _p;
  }

  Role getRole() {
    return _r;
  }

  Component getLiveComponent(int type) {
    if(_c == null) {
      return null;
    } else {
      while(_c.length <= type) {
        _c.add(new List());
      }
      if(_c[type].isEmpty) {
        return new Component.newBase(_p.getPid(), _uimii.getUid(), type);
      } else {
        return _c[type].last;
      }
    }
  }

  void addComponent(Component newComponent) {
    int type = newComponent.getType();

    // Check if the pid matches to our current projects.
    if(newComponent.getPid() != _p.getPid()) {
      throw "Tried adding a component to the wrong project!";
    } else if (_c == null) {
      throw "Tried adding a component to a null project!";
    } else {
      // Create new empty lists if we don't have a list for our type yet.
      while(_c.length <= type) {
        _c.add(new List());
      }

      // Get the list of revisions for our type - may be empty.
      List<Component> componentTypeRevisions = _c[type];

      // Check if the list contains an older revision and our's isn't "next in line"
      if((componentTypeRevisions.isNotEmpty && componentTypeRevisions.last.getRevision() != newComponent.getRevision() - 1 ) ||
          (componentTypeRevisions.isEmpty && newComponent.getRevision() != 1 )) {
        throw "Tried adding a component with an invalid revision! ${newComponent.getRevision()}";
      } else {
        componentTypeRevisions.add(newComponent);
        _uimii.getDBClient().makeRequest(new RequestAddComponent(_uimii.getAuthUsername(), _uimii.getAuthPassword(), newComponent));
      }
    }
  }

  Component getNewRevision(int type) {
    return new Component.newRevision(getLiveComponent(type), _uimii.getUid());
  }

  void addRevisionWithOneItem(int type, String key, dynamic value) {
    addComponent(getNewRevision(type)..addDataElement(key, value));
  }
}