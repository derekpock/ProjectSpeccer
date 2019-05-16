
import 'dart:html';
import '../../CSSClasses.dart';
import '../../Structures/Component.dart';
import '../../Structures/Project.dart';
import '../../Structures/Role.dart';
import '../AbstractStage.dart';
import '../../UIManagerInteractionInterface.dart';
import '../../UIPages/PageProjectInteractionInterface.dart';
import '../TextInputForm.dart';

class StageDistribution extends AbstractStage {

  TextInputForm _whereDistributed;
  TextInputForm _whereForums;
  TextInputForm _updatesHow;

  StageDistribution(UIManagerInteractionInterface uimii, PageProjectInteractionInterface ppii) :
        super(uimii, ppii, 6, "Distribution") {
    content.classes.add(CSSClasses.stageBottom);
    content.classes.add(CSSClasses.stageDist);

    _whereDistributed = new TextInputForm("Where is this project being distributed?", ppii, false, componentType: ComponentTypes.WhereDistributed);
    _whereForums = new TextInputForm("Where can someone using this product find help?", ppii, true, componentType: ComponentTypes.WhereForums);
    _updatesHow = new TextInputForm("Are manual updates for this project necessary? If so, how will they be distributed?", ppii, true, componentType: ComponentTypes.WhereUpdates);

    content.append(_whereDistributed.content);
    content.append(_whereForums.content);
    content.append(_updatesHow.content);
  }

  void refreshComponents() {
    _whereDistributed.refreshComponent();
    _whereForums.refreshComponent();
    _updatesHow.refreshComponent();
  }

  void refreshProject(Project p, Role r) {
    if(r == null) {
      r = new Role("", "", "", false, false);
    }

    _whereDistributed.setPermissions(r);
    _whereForums.setPermissions(r);
    _updatesHow.setPermissions(r);
  }

  void adjustScrollHeight() {}
}