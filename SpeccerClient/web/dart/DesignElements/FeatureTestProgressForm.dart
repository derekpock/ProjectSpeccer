
import 'dart:html';

import '../Structures/Component.dart';
import '../Structures/Role.dart';
import '../UIPages/PageProjectInteractionInterface.dart';
import '../CSSClasses.dart';
import 'package:uuid/uuid.dart';

class FeatureTestProgressForm {
  PageProjectInteractionInterface ppii;
  DivElement content;

  DivElement header;
  LabelElement headerLabel;
  DivElement divItems;
  List<ProgressFormItem> progressFormItems;

  int componentType;
  Role r;
  bool contributorCanModify;

  FeatureTestProgressForm(String title, this.ppii, this.contributorCanModify, this.componentType) {
    progressFormItems = new List();
    progressFormItems.add(new ProgressFormItem(this, "dummy", "dummy", "false", uuidFrom: "00000000-0000-0000-0000-000000000000", uuidTo: "00000000-0000-0000-0000-000000000000"));

    headerLabel = new LabelElement();
    headerLabel.append(new Text(title));

    divItems = new DivElement();
    header = new DivElement();

    header.append(headerLabel);

    content = new DivElement();
    content.classes.add(CSSClasses.progressForm);
    content.append(header);
    content.append(divItems);
  }

  void refreshComponent() {
    while(divItems.childNodes.isNotEmpty) {
      divItems.lastChild.remove();
    }
    progressFormItems.clear();

    Component c = ppii.getLiveComponent(componentType);
    List<dynamic> data = c.getDataElement("listDataUuid", new List()..add(["00000000-0000-0000-0000-000000000000", "00000000-0000-0000-0000-000000000000", "dummy"]));
    Map<dynamic, dynamic> completionData = c.getDataElement("progressData", new Map());

    data.forEach((s) {
      s = s as List;
      List<dynamic> useCasesForTest = c.getDataElement("${s[0]}-useCases", new List());
      useCasesForTest.forEach((u) {
        progressFormItems.add(new ProgressFormItem(this, "${s[2]} - ${u}", "${s[0]}-${u}", completionData["${s[0]}-${u}"], uuidFrom: s[0], uuidTo: s[1]));
        if(s[0] != "00000000-0000-0000-0000-000000000000") {
          divItems.append(progressFormItems.last.content);
        }
      });
    });
  }

  void setPermissions(Role r) {
    this.r = r;
    bool disabled = !(contributorCanModify ? r.isDeveloper() : r.isOwner());
    progressFormItems.forEach((ProgressFormItem pfi) {
      pfi.setDisabled(disabled);
    });
  }

  void childBlurred() {
    if((contributorCanModify ? r.isDeveloper() : r.isOwner())) {
      Map<String, String> data = new Map();

      progressFormItems.forEach((ProgressFormItem item) {
        data[item.value] = item.butToggle.getAttribute("selected");
      });

      ppii.addRevisionWithOneItem(componentType, "progressData", data);
    }
  }
}

class ProgressFormItem {
  String uuidFrom;
  String uuidTo;
  DivElement content;
  DivElement butToggle;
  FeatureTestProgressForm parent;
  DivElement divName;
  String value;

  ProgressFormItem(this.parent, String text, this.value, String selected, {this.uuidFrom, this.uuidTo}) {
    if(selected == null || selected.isEmpty) {
      selected = "false";
    }

    content = new DivElement();
    content.classes.add(CSSClasses.progressFormItem);
    content.classes.add(CSSClasses.horizontalFlow);

    divName = new DivElement();
    divName.append(new Text(text));

    butToggle = new DivElement();
    butToggle.classes.add(CSSClasses.clickable);
    butToggle.classes.add(CSSClasses.button);
    butToggle.setInnerHtml(selected == "true" ? "Passing" : "Failing");
    butToggle.setAttribute("selected", selected);
    butToggle.onClick.listen((_) {
      if(butToggle.getAttribute("disabled") != "true") {
        bool nowEnabled = butToggle.getAttribute("selected") == "false";
        butToggle.setAttribute("selected", nowEnabled ? "true" : "false");
        butToggle.setInnerHtml(nowEnabled ? "Passing" : "Failing");
      }
      parent.childBlurred();
    });

    content.append(butToggle);
    content.append(divName);
  }

  void setDisabled(bool disabled) {
    butToggle.setAttribute("disabled", (disabled ? "true" : "false"));
  }
}