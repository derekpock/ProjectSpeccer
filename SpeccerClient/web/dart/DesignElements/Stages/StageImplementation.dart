
import 'dart:html';
import '../AbstractStage.dart';
import '../../UIManagerInteractionInterface.dart';
import '../../UIPages/PageProjectInteractionInterface.dart';

class StageImplementation extends AbstractStage {

  StageImplementation(UIManagerInteractionInterface uimii, PageProjectInteractionInterface ppii) :
        super(uimii, ppii, "Implementation") {

  }
}