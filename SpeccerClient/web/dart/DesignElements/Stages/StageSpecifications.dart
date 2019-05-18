
import 'dart:html';
import '../../CSSClasses.dart';
import '../../Structures/Component.dart';
import '../../Structures/Project.dart';
import '../../Structures/Role.dart';
import '../AbstractStage.dart';
import '../../UIManagerInteractionInterface.dart';
import '../../UIPages/PageProjectInteractionInterface.dart';
import '../FeaturePopulation.dart';
import '../ListForm.dart';
import '../TextInputForm.dart';

class StageSpecifications extends AbstractStage {
  DivElement _div1;
  DivElement _divLeft1;
  DivElement _divRight1;

  DivElement _div2;
  DivElement _divLeft2;
  DivElement _divRight2;

  ListForm _frameworks;
  ListForm _objectives;
  ListForm _otherUseCases;

  TextInputForm _repository;
  TextInputForm _issueTracker;

  DivElement _fpsDiv;
  LabelElement _fpsHead;
  DivElement _fpsBody;
  List<FeaturePopulation> _featurePopulations;

  DivElement _divInvolvesDatabaseDesign;
  LabelElement _labelIDD;
  CheckboxInputElement _butIDD;

  DivElement _divInvolvesUIDesign;
  LabelElement _labelIUID;
  CheckboxInputElement _butIUID;

  Role _r;
  List<dynamic> _oldFeaturesList;

  StageSpecifications(UIManagerInteractionInterface uimii, PageProjectInteractionInterface ppii) :
        super(uimii, ppii, 2, "Specifications") {
    content.classes.add(CSSClasses.verticalFlow);

    _featurePopulations = new List();

    _div1 = new DivElement();
    _div1.classes.add(CSSClasses.horizontalFlow);

      _divLeft1 = new DivElement();
      _divLeft1.classes.add(CSSClasses.stageDivLeft);

        _frameworks = new ListForm(ListForm.TextInputType, "Frameworks and Languages", ppii, true, componentType: ComponentTypes.Frameworks);
      _divLeft1.append(_frameworks.content);
    _div1.append(_divLeft1);

      _divRight1 = new DivElement();
      _divRight1.classes.add(CSSClasses.stageDivRight);
      _divRight1.classes.add(CSSClasses.verticalFlow);

        _repository = new TextInputForm("Repository", ppii, true, componentType: ComponentTypes.Repository);
      _divRight1.append(_repository.content);

        _issueTracker = new TextInputForm("Issue Tracker", ppii, true, componentType: ComponentTypes.IssueTracker);
      _divRight1.append(_issueTracker.content);

        _divInvolvesDatabaseDesign = new DivElement();

          _butIDD = new CheckboxInputElement();
          _butIDD.onInput.listen((_) {
            if(_r.isDeveloper()) {
              ppii.addRevisionWithOneItem(ComponentTypes.UsesDB, "value", _butIDD.checked);
            }
          });
        _divInvolvesDatabaseDesign.append(_butIDD);

          _labelIDD = new LabelElement();
          _labelIDD.append(new Text("Project Involves Designing a Database"));
        _divInvolvesDatabaseDesign.append(_labelIDD);
      _divRight1.append(_divInvolvesDatabaseDesign);

        _divInvolvesUIDesign = new DivElement();

          _butIUID = new CheckboxInputElement();
          _butIUID.onInput.listen((_) {
            if(_r.isDeveloper()) {
              ppii.addRevisionWithOneItem(ComponentTypes.UsesUI, "value", _butIUID.checked);
            }
          });
        _divInvolvesUIDesign.append(_butIUID);

          _labelIUID = new LabelElement();
          _labelIUID.append(new Text("Project Involves Designing a UI"));
        _divInvolvesUIDesign.append(_labelIUID);
      _divRight1.append(_divInvolvesUIDesign);
    _div1.append(_divRight1);
    content.append(_div1);

    _fpsDiv = new DivElement();
    _fpsDiv.classes.add(CSSClasses.verticalFlow);
    _fpsDiv.classes.add(CSSClasses.stageBottom);

      _fpsHead = new LabelElement();
      _fpsHead.append(new Text("Features in Detail"));
    _fpsDiv.append(_fpsHead);

      _fpsBody = new DivElement();
    _fpsDiv.append(_fpsBody);
    content.append(_fpsDiv);

    _div2 = new DivElement();
    _div2.classes.add(CSSClasses.horizontalFlow);

      _divLeft2 = new DivElement();
      _divLeft2.classes.add(CSSClasses.stageDivLeft);
    _div2.append(_divLeft2);

      _divRight2 = new DivElement();
      _divRight2.classes.add(CSSClasses.stageDivRight);

        _otherUseCases = new ListForm(ListForm.TextAreaType, "Other Use Cases", ppii, true, componentType: ComponentTypes.UseCases, useLinkedListAndUuids: true);
      _divRight2.append(_otherUseCases.content);
    _div2.append(_divRight2);
    content.append(_div2);

    _objectives = new ListForm(ListForm.TextInputType, "Objectives - Step by step goals in order to complete our project", ppii, true, componentType: ComponentTypes.Objectives, useLinkedListAndUuids: true);
    _objectives.content.classes.add(CSSClasses.stageBottom);
    content.append(_objectives.content);

    _setPermissions(null);
  }

  void _setPermissions(Role r) {
    if(r == null) {
      r = Role("", "", "", false, false);
    }
    _r = r;

    bool disabled = !(r.isDeveloper());

    _frameworks.setPermissions(r);
    _repository.setPermissions(r);
    _issueTracker.setPermissions(r);
    _butIDD.disabled = disabled;
    _butIUID.disabled = disabled;

    _featurePopulations.forEach((FeaturePopulation fp) {
      fp.setPermissions(r);
    });

    _otherUseCases.setPermissions(r);
    _objectives.setPermissions(r);
  }

  void refreshComponents() {
    _frameworks.refreshComponent();
    _repository.refreshComponent();
    _issueTracker.refreshComponent();

    _butIDD.checked = ppii.getLiveComponent(ComponentTypes.UsesDB).getDataElement("value", true);
    _butIUID.checked = ppii.getLiveComponent(ComponentTypes.UsesUI).getDataElement("value", true);

    List<dynamic> newFeaturesList = ppii.getLiveComponent(ComponentTypes.Features).getDataElement("listDataUuid");
    if(_listsAreEqual(newFeaturesList, _oldFeaturesList)) {
      _featurePopulations.forEach((FeaturePopulation fp) {
        fp.refreshComponent();
      });
    } else {
      _featurePopulations.clear();
      while(_fpsBody.childNodes.isNotEmpty) {
        _fpsBody.childNodes.last.remove();
      }

      newFeaturesList.forEach((r) {
        r = r as List;
        if(r[0] != "00000000-0000-0000-0000-000000000000") {
          _featurePopulations.add(new FeaturePopulation(ppii, r[0]));
          _featurePopulations.last.setPermissions(_r);
          _fpsBody.append(_featurePopulations.last.content);
        }
      });
    }

    _otherUseCases.refreshComponent();
    _objectives.refreshComponent();

    _frameworks.setPermissions(_r);
    _otherUseCases.setPermissions(_r);
    _objectives.setPermissions(_r);
  }

  void refreshProject(Project p, Role r) {
    _setPermissions(r);
  }

  bool _listsAreEqual(List a, List b) {
    int i = -1;
    if(a == null) {
      return b == null;
    } else {
      return b != null && a.length == b.length && a.every((partA) {
        i++;
        if(partA is List && b[i] is List) {
          return _listsAreEqual(partA, b[i]);
        } else {
          return partA == b[i];
        }
      });
    }
  }

  void adjustScrollHeight() {
    _frameworks.adjustScrollHeight();
    _otherUseCases.adjustScrollHeight();
    _objectives.adjustScrollHeight();
    _featurePopulations.forEach((FeaturePopulation fp) {
      fp.adjustScrollHeight();
    });
  }
}