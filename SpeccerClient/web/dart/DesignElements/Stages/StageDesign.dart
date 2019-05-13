
import 'dart:html';
import '../../Structures/Component.dart';
import '../../Structures/Project.dart';
import '../../Structures/Role.dart';
import '../AbstractStage.dart';
import '../../UIManagerInteractionInterface.dart';
import '../../UIPages/PageProjectInteractionInterface.dart';

class StageDesign extends AbstractStage {

  StageDesign(UIManagerInteractionInterface uimii, PageProjectInteractionInterface ppii) :
        super(uimii, ppii, 3, "Design") {

  }

  void refreshComponents() {
    // TODO: implement refreshComponents
  }

  void refreshProject(Project p, Role r) {
    // TODO: implement refreshProject
  }


  void adjustScrollHeight() {}

}