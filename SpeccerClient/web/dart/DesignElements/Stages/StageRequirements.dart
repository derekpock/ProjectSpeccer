
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
  TextAreaElement _inputDescription;
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
      ppii.addRevisionWithOneItem(ComponentTypes.ProjectName, "name", _inputName.value);
      uimii.updatedProject(ppii.getProject().getPid(), ppii.getProject().isPublic(), _inputName.value);
    });

    _inputDescription = new TextAreaElement();
    _inputDescription.onKeyDown.listen((KeyboardEvent e) {
      if(e.keyCode == KeyCode.ENTER) {
        _inputDescription.blur();
      }
    });

    _inputDescription.onBlur.listen((_) {
      ppii.addRevisionWithOneItem(ComponentTypes.ProjectDescription, "description", _inputDescription.value);
    });

    _form = new Form();
    _form.addInputViaString("Project Name", _inputName);
    _form.addInputViaString("Description", _inputDescription);

    content.append(_form.getElement());
    _setPermissions(null);
  }

  void _setPermissions(Role r) {
    _isOwner = r != null && r.isOwner();
    _inputName.disabled = !_isOwner;
    _inputDescription.disabled = !_isOwner;
  }

  void refreshComponents() {
    _inputName.value = ppii.getLiveComponent(ComponentTypes.ProjectName).getDataElement("name", "My Project");
    _inputDescription.value = ppii.getLiveComponent(ComponentTypes.ProjectDescription).getDataElement("description", "A brand new default project.");
  }

  void refreshProject(Project p, Role r) {
    _setPermissions(r);
  }

}