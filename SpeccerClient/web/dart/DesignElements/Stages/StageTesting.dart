
import 'dart:html';
import '../../CSSClasses.dart';
import '../../Structures/Component.dart';
import '../../Structures/Project.dart';
import '../../Structures/Role.dart';
import '../AbstractStage.dart';
import '../../UIManagerInteractionInterface.dart';
import '../../UIPages/PageProjectInteractionInterface.dart';
import '../FeatureTestProgressForm.dart';
import '../ProgressForm.dart';

class StageTesting extends AbstractStage {

  FeatureTestProgressForm _featureTests;
  ProgressForm _otherTests;

  Role _r;

  StageTesting(UIManagerInteractionInterface uimii, PageProjectInteractionInterface ppii) :
        super(uimii, ppii, 5, "Testing") {
    content.classes.add(CSSClasses.stageBottom);

    _featureTests = new FeatureTestProgressForm("Feature Use Cases", ppii, true, ComponentTypes.Features);
    _otherTests = new ProgressForm("Other Use Cases", ppii, true, ComponentTypes.UseCases, acceptText: "Passing", rejectText: "Failing");

    content.append(_featureTests.content);
    content.append(_otherTests.content);
  }

  void refreshComponents() {
    _featureTests.refreshComponent();
    _otherTests.refreshComponent();

    _featureTests.setPermissions(_r);
    _otherTests.setPermissions(_r);
  }

  void refreshProject(Project p, Role r) {
    if(r == null) {
      r = Role("", "", "", false, false);
    }
    _r = r;
    _featureTests.setPermissions(r);
    _otherTests.setPermissions(r);
  }

  void adjustScrollHeight() {}
}