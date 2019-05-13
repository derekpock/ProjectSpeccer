import 'dart:html';
import '../CSSClasses.dart';
import '../Structures/Component.dart';
import '../Structures/Role.dart';
import '../UIPages/PageProjectInteractionInterface.dart';
import 'ListForm.dart';
import 'TextAreaForm.dart';
import 'TextInputForm.dart';

class FeaturePopulation {
  PageProjectInteractionInterface ppii;
  Component _c;
  String myUuid;

  DivElement content;
  DivElement _divLeft;

  TextInputForm _summary;
  TextAreaForm _description;
  TextAreaForm _implementation;

  ListForm _useCases;

  FeaturePopulation(this.ppii, this.myUuid) {
    _c = ppii.getLiveComponent(ComponentTypes.Features);

    content = new DivElement();
    content.classes.add(CSSClasses.featurePopulation);
    content.classes.add(CSSClasses.horizontalFlow);

      _divLeft = new DivElement();
      _divLeft.style.flex = "1";
      _divLeft.classes.add(CSSClasses.verticalFlow);
      _divLeft.classes.add(CSSClasses.stageDivLeft);

        _summary = new TextInputForm("Summary", ppii, false,
            getRemoteComponentValue: () {
              List<dynamic> data = _c.getDataElement("listDataUuid", new List());
              return (data.firstWhere((e) => (e as List)[0] == myUuid) as List)[2];
            },
            setRemoteComponentValue: (String value) {
              List<dynamic> data = _c.getDataElement("listDataUuid", new List());
              (data.firstWhere((e) => (e as List)[0] == myUuid) as List)[2] = value;
              ppii.addRevisionWithOneItem(ComponentTypes.Features, "listDataUuid", data);
            }
        );
      _divLeft.append(_summary.content);

        _description = new TextAreaForm("Description", ppii, true,
            getRemoteComponentValue: () {
              return _c.getDataElement("$myUuid-description", "");
            },
            setRemoteComponentValue: (String value) {
              ppii.addRevisionWithOneItem(ComponentTypes.Features, "$myUuid-description", value);
            });
      _divLeft.append(_description.content);

        _implementation = new TextAreaForm("Implementation Notes", ppii, true,
            getRemoteComponentValue: () {
              return _c.getDataElement("$myUuid-implementation", "");
            },
            setRemoteComponentValue: (String value) {
              ppii.addRevisionWithOneItem(ComponentTypes.Features, "$myUuid-implementation", value);
            });
      _divLeft.append(_implementation.content);
    content.append(_divLeft);

      _useCases = new ListForm(ListForm.TextAreaType, "Use Cases", ppii, true,
          getRemoteComponentValue: () {
            return _c.getDataElement("$myUuid-useCases", new List());
          },
          setRemoteComponentValue: (List<dynamic> value) {
            ppii.addRevisionWithOneItem(ComponentTypes.Features, "$myUuid-useCases", value);
          });
      _useCases.content.style.flex = "1";
      _useCases.content.classes.add(CSSClasses.stageDivRight);
    content.append(_useCases.content);

    refreshComponent();
  }

  void refreshComponent() {
    _summary.refreshComponent();
    _description.refreshComponent();
    _implementation.refreshComponent();
    _useCases.refreshComponent();
  }

  void setPermissions(Role r) {
    _summary.setPermissions(r);
    _description.setPermissions(r);
    _implementation.setPermissions(r);
    _useCases.setPermissions(r);
  }

  void adjustScrollHeight() {
    _useCases.adjustScrollHeight();
    _description.adjustScrollHeight();
    _implementation.adjustScrollHeight();
  }
}