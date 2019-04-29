library UIPage;

import 'dart:html';
import 'CSSClasses.dart';
import 'UIManagerInteractionInterface.dart';
import 'DesignElements/Form.dart';
import 'Requests/RequestAddUser.dart';
import 'Requests/RequestLogin.dart';
import 'Requests/RequestNewProject.dart';
import 'Structures/Project.dart';
import 'Structures/Role.dart';
import 'DesignElements/AbstractStage.dart';
import 'UIPages/PageProjectInteractionInterface.dart';

import 'DesignElements/Stages/StageAccessibility.dart';
import 'DesignElements/Stages/StageDesign.dart';
import 'DesignElements/Stages/StageDistribution.dart';
import 'DesignElements/Stages/StageImplementation.dart';
import 'DesignElements/Stages/StageRequirements.dart';
import 'DesignElements/Stages/StageSpecifications.dart';
import 'DesignElements/Stages/StageTesting.dart';

part 'UIPages/PageBrowse.dart';
part 'UIPages/PageHome.dart';
part 'UIPages/PageLogin.dart';
part 'UIPages/PageMyProjects.dart';
part 'UIPages/PageProject.dart';
part 'UIPages/PageRegister.dart';

class UIPage {
  UIManagerInteractionInterface _uimii;

  DivElement _element;

  HeadingElement _header;
  DivElement _content;

  bool hidden;

  UIPage(UIManagerInteractionInterface uimii, bool hidden, String title) {
    this.hidden = hidden;
    _uimii = uimii;

    _element = new DivElement();
    _element.classes.add(CSSClasses.uiBodyContentPage);
    if(hidden) {
      _element.classes.add(CSSClasses.hidden);
    }

    _header = new HeadingElement.h2();
    _header.setInnerHtml(title);
    _header.classes.add(CSSClasses.uiBodyContentPageHeader);

    _content = new DivElement();
    _content.classes.add(CSSClasses.uiBodyContentPageContent);

    _element.append(_header);
    _element.append(_content);
  }

  DivElement getElement() {
    return _element;
  }
}