
part of '../UIPage.dart';

class PageProject extends UIPage implements PageProjectInteractionInterface {
  Project _p;
  Role _r;

  List<AbstractStage> _stages;

  PageProject(UIManagerInteractionInterface uimii) :
        super(uimii, true, true, "Project", "project") {

    _stages = new List();
    _stages.addAll([
      new StageAccessibility(uimii, this),
      new StageRequirements(uimii, this),
      new StageSpecifications(uimii, this),
      new StageDesign(uimii, this),
      new StageImplementation(uimii, this),
      new StageTesting(uimii, this),
      new StageDistribution(uimii, this)
    ]);

    _stages.forEach((AbstractStage stage) {
      _content.append(stage.getElement());
    });

    setActiveStage(_stages.first);
  }

  void openProject(Project p, Role r) {
    _p = p;
    _r = r;


  }

  void setActiveStage(AbstractStage activeStage) {
    _stages.forEach((AbstractStage stage) {
      stage.setContentVisible(stage == activeStage);
    });
  }
}