
import '../DesignElements/AbstractStage.dart';
import '../Structures/Component.dart';
import '../Structures/Project.dart';
import '../Structures/Role.dart';

abstract class PageProjectInteractionInterface {
  void setActiveStage(AbstractStage stage);
  Project getProject();
  Role getRole();
  void addComponent(Component newComponent);
  Component getNewRevision(int type);
  Component getLiveComponent(int type);
}