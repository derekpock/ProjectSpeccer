
import 'dart:html';
import '../../CSSClasses.dart';
import '../../Structures/Component.dart';
import '../../Structures/Project.dart';
import '../../Structures/Role.dart';
import '../AbstractStage.dart';
import '../../UIManagerInteractionInterface.dart';
import '../../UIPages/PageProjectInteractionInterface.dart';
import '../TreeStructure.dart';

class StageDesign extends AbstractStage {

  TreeStructure _dataStructure;
  TreeStructure _dbStructure;
  TreeStructure _uiStructure;

  StageDesign(UIManagerInteractionInterface uimii, PageProjectInteractionInterface ppii) :
        super(uimii, ppii, 3, "Design") {

    _dataStructure = new TreeStructure(ppii, ComponentTypes.DataStructures, "Data Structures", {
      "class": ["member", "method", "function", "variable"],
      "interface": ["member", "method", "function", "variable"]
    });

    _dbStructure = new TreeStructure(ppii, ComponentTypes.DatabaseStructures, "Database Structure", {
      "table": ["int", "varchar", "char", "other"],
      "constraint": ["unique", "primary", "check", "foreign"]
    });

    _uiStructure = new TreeStructure(ppii, ComponentTypes.UIFormsViews, "UI Forms / Views", {
      "form": ["textInput", "textArea", "int", "double", "button", "date", "other"],
      "view": ["label", "table", "image", "button", "link", "graphics", "other"]
    });

    content.append(_dataStructure.content);
    content.append(_dbStructure.content);
    content.append(_uiStructure.content);
  }

  void refreshComponents() {
    bool useDB = ppii.getLiveComponent(ComponentTypes.UsesDB).getDataElement("value", true);
    bool useUI = ppii.getLiveComponent(ComponentTypes.UsesUI).getDataElement("value", true);

    _dbStructure.content.classes.toggle(CSSClasses.hidden, !useDB);
    _uiStructure.content.classes.toggle(CSSClasses.hidden, !useUI);

    _dataStructure.refreshComponent();
    _dbStructure.refreshComponent();
    _uiStructure.refreshComponent();
  }

  void refreshProject(Project p, Role r) {
    if(r == null) {
      r = Role("", "", "", false, false);
    }
    _dataStructure.setPermissions(r);
    _dbStructure.setPermissions(r);
    _uiStructure.setPermissions(r);
  }

  void adjustScrollHeight() {

  }

}