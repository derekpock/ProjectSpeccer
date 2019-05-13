
import 'dart:html';
import '../../Structures/Component.dart';
import '../../Structures/Project.dart';
import '../../Structures/Role.dart';
import '../AbstractStage.dart';
import '../../UIManagerInteractionInterface.dart';
import '../../UIPages/PageProjectInteractionInterface.dart';
import '../Form.dart';
import '../../CSSClasses.dart';
import '../ListForm.dart';
import '../TextAreaForm.dart';
import '../TextInputForm.dart';

class StageRequirements extends AbstractStage {

  DivElement _divLeft;
  DivElement _divRight;

  ListForm _features;

  List<TextInputForm> _inputForms;
  List<TextAreaForm> _areaForms;

  Role _r;

  StageRequirements(UIManagerInteractionInterface uimii, PageProjectInteractionInterface ppii) :
        super(uimii, ppii, 1, "Requirements") {

    _inputForms = new List();
    _areaForms = new List();

    content.classes.add(CSSClasses.horizontalFlow);

    _divLeft = new DivElement();
    _divLeft.classes.add(CSSClasses.stageDivLeft);

    _divRight = new DivElement();
    _divRight.classes.add(CSSClasses.stageDivRight);

    // TOP
    _inputForms.add(new TextInputForm("Project Name", ppii, false, componentType: ComponentTypes.ProjectName, defaultValue: "My Project"));
    _divLeft.append(_inputForms.last.content);

    _inputForms.add(new TextInputForm("Subheading", ppii, false, componentType: ComponentTypes.ProjectSubheading, defaultValue: "A new project."));
    _divRight.append(_inputForms.last.content);

    // LEFT
    _areaForms.add(new TextAreaForm("What are we building?", ppii, false, componentType: ComponentTypes.WhatAreWeBuilding));
    _divLeft.append(_areaForms.last.content);

    _features = new ListForm(ListForm.TextInputType, "Features", ppii, false, componentType: ComponentTypes.Features, useLinkedListAndUuids: true);
    _divLeft.append(_features.content);

    _areaForms.add(new TextAreaForm("Who do we need on this project?", ppii, false, componentType: ComponentTypes.WhoWeNeed));
    _divLeft.append(_areaForms.last.content);

    _areaForms.add(new TextAreaForm("What has already been done on this project?", ppii, false, componentType: ComponentTypes.WhatHasBeenDone));
    _divLeft.append(_areaForms.last.content);

    _areaForms.add(new TextAreaForm("Use Examples - Who is our customer?", ppii, false, componentType: ComponentTypes.ExamplesOfUse));
    _divLeft.append(_areaForms.last.content);

    // RIGHT
    _areaForms.add(new TextAreaForm("What is this project not?", ppii, false, componentType: ComponentTypes.WhatAreWeNotBuilding));
    _divRight.append(_areaForms.last.content);

    _areaForms.add(new TextAreaForm("Examples - What is this project similar to?", ppii, false, componentType: ComponentTypes.ExamplesOfSimilar));
    _divRight.append(_areaForms.last.content);

    _areaForms.add(new TextAreaForm("What forms of compensation or benefits do contributors get?", ppii, false, componentType: ComponentTypes.CompensationAndBenefits));
    _divRight.append(_areaForms.last.content);

    _areaForms.add(new TextAreaForm("Links and References - Where is some background on this?", ppii, false, componentType: ComponentTypes.References));
    _divRight.append(_areaForms.last.content);

    // schedule
    // _divRight.append(

    content.append(_divLeft);
    content.append(_divRight);

    _setPermissions(null);
  }

  void _setPermissions(Role r) {
    if(r == null) {
      r = Role("", "", "", false, false);
    }
    _r = r;

    _inputForms.forEach((x) => x.setPermissions(r));
    _areaForms.forEach((x) => x.setPermissions(r));
    _features.setPermissions(r);
  }

  void refreshComponents() {
    _inputForms.forEach((x) => x.refreshComponent());
    _areaForms.forEach((x) => x.refreshComponent());
    _features.refreshComponent();
    _features.setPermissions(_r);
  }

  void refreshProject(Project p, Role r) {
    _setPermissions(r);
  }

  void adjustScrollHeight() {
    _features.adjustScrollHeight();
    _areaForms.forEach((TextAreaForm taf) {
      taf.adjustScrollHeight();
    });
  }
}