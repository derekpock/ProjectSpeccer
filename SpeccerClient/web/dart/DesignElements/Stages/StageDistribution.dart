
import 'dart:html';
import '../../Structures/Component.dart';
import '../../Structures/Project.dart';
import '../../Structures/Role.dart';
import '../AbstractStage.dart';
import '../../UIManagerInteractionInterface.dart';
import '../../UIPages/PageProjectInteractionInterface.dart';

class StageDistribution extends AbstractStage {

  StageDistribution(UIManagerInteractionInterface uimii, PageProjectInteractionInterface ppii) :
        super(uimii, ppii, 6, "Distribution") {

  }

  void refreshComponents() {
    // TODO: implement refreshComponents
  }

  void refreshProject(Project p, Role r) {
    // TODO: implement refreshProject
  }

  void adjustScrollHeight() {}
}