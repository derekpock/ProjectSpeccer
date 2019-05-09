
import 'dart:html';
import '../../Structures/Component.dart';
import '../../Structures/Project.dart';
import '../../Structures/Role.dart';
import '../AbstractStage.dart';
import '../../UIManagerInteractionInterface.dart';
import '../../UIPages/PageProjectInteractionInterface.dart';
import '../Form.dart';

class StageRequirements extends AbstractStage {

  Form _form;
  TextInputElement _inputName;
  bool _isOwner;

  StageRequirements(UIManagerInteractionInterface uimii, PageProjectInteractionInterface ppii) :
        super(uimii, ppii, 1, "Requirements") {
    _isOwner = false;

    _inputName = new TextInputElement();
    _inputName.onKeyDown.listen((KeyboardEvent e) {
      if(e.keyCode == KeyCode.ENTER) {
        _inputName.blur();
      }
    });
    
    _inputName.onBlur.listen((_) {
      ppii.addComponent(ppii.getNewRevision(ComponentTypes.ProjectName)
        ..addDataElement("name", _inputName.value));
    });

    _form = new Form();
    _form.addInputViaString("Project Name", _inputName);

    content.append(_form.getElement());
    _setPermissions(null);
  }

  void _setPermissions(Role r) {
    _isOwner = r != null && r.isOwner();
    _inputName.disabled = !_isOwner;
  }

  void refreshComponents() {
    _inputName.value = ppii.getLiveComponent(ComponentTypes.ProjectName).getDataElement("name", "My Project");
  }

  void refreshProject(Project p, Role r) {
    _setPermissions(r);
  }

}