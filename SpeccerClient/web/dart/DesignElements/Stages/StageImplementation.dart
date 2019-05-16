
import 'dart:html';
import '../../Structures/Component.dart';
import '../../Structures/Project.dart';
import '../../Structures/Role.dart';
import '../AbstractStage.dart';
import '../../UIManagerInteractionInterface.dart';
import '../../UIPages/PageProjectInteractionInterface.dart';
import '../../CSSClasses.dart';
import '../ProgressForm.dart';

class StageImplementation extends AbstractStage {

  ProgressForm _objectives;
  ProgressForm _features;

  Role _r;

  StageImplementation(UIManagerInteractionInterface uimii, PageProjectInteractionInterface ppii) :
        super(uimii, ppii, 4, "Implementation") {
    content.classes.add(CSSClasses.stageBottom);

    _objectives = new ProgressForm("Objectives", ppii, true, ComponentTypes.Objectives);
    _features = new ProgressForm("Features", ppii, true, ComponentTypes.Features);

    content.append(_objectives.content);
    content.append(_features.content);
  }

  void refreshComponents() {
    _objectives.refreshComponent();
    _features.refreshComponent();

    _objectives.setPermissions(_r);
    _features.setPermissions(_r);
  }

  void refreshProject(Project p, Role r) {
    if(r == null) {
      r = Role("", "", "", false, false);
    }
    _r = r;
    _objectives.setPermissions(r);
    _features.setPermissions(r);
  }

  void adjustScrollHeight() {}
}