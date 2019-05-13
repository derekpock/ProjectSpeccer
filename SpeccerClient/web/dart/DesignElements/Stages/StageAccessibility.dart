
import 'dart:html';
import '../../Structures/Component.dart';
import '../../Structures/Project.dart';
import '../../Structures/Role.dart';
import '../AbstractStage.dart';
import '../../UIManagerInteractionInterface.dart';
import '../../UIPages/PageProjectInteractionInterface.dart';
import '../../CSSClasses.dart';
import '../../Requests/RequestChangeProjectPublicity.dart';
import '../../Requests/RequestSetRole.dart';
import '../Form.dart';

class StageAccessibility extends AbstractStage {

  DivElement _butChangePublicity;

  TextInputElement _inputGrantUser;
  DivElement _butGrant;

  Form _form;
  TableElement _tabRoles;

  List<Element> _ownerOnlyElements;

  StageAccessibility(UIManagerInteractionInterface uimii, PageProjectInteractionInterface ppii) :
      super(uimii, ppii, 0, "Accessibility") {

    _form = new Form();

    _butChangePublicity = new DivElement();
    _butChangePublicity.classes.add(CSSClasses.button);
    _butChangePublicity.classes.add(CSSClasses.clickable);
    _butChangePublicity.onClick.listen((_) {
      //TODO make this hold not just click
      uimii.getDBClient().makeRequest(new RequestChangeProjectPublicity(
          uimii.getAuthUsername(),
          uimii.getAuthPassword(),
          ppii.getProject(),
          !ppii.getProject().isPublic()
      ));
    });

    _inputGrantUser = new TextInputElement();
    _butGrant = new DivElement();
    _butGrant.setInnerHtml("Grant");
    _butGrant.classes.add(CSSClasses.clickable);
    _butGrant.classes.add(CSSClasses.button);
    _butGrant.onClick.listen((_) {
      if(_butGrant.getAttribute("disabled") != "true") {
        _inputGrantUser.setAttribute("error", "false");
        _sendNewRoleRequest(_inputGrantUser.value, true, false, false);
      }
    });

    _form.addInputViaString("Change Project Publicity", _butChangePublicity);
    _form.addInputViaString("Grant Project Access", _inputGrantUser)
        ..addCell().append(_butGrant);

    _tabRoles = new TableElement();
    _tabRoles.classes.add(CSSClasses.listTable);

    content.append(_form.getElement());
    content.append(_tabRoles);
  }

  void refreshComponents() {

  }

  void refreshProject(Project p, Role r) {
    _butChangePublicity.setInnerHtml(p.isPublic() ? "Make Private" : "Make Public");
    _butGrant.setAttribute("disabled", r.isOwner() ? "false" : "true");
    _inputGrantUser.value = "";
    _inputGrantUser.disabled = !r.isOwner();
  }

  void refreshRoles(List<Role> roles) {
    //TODO call or update roles if we lose ownership of this project
    while(_tabRoles.childNodes.isNotEmpty) {
      _tabRoles.childNodes.first.remove();
    }

    TableSectionElement headerSection = _tabRoles.createTHead();
    TableRowElement headerRow = headerSection.addRow();
    headerRow.addCell()
      ..setInnerHtml("Username");

    headerRow.addCell()
      ..setInnerHtml("Can Manage");

    headerRow.addCell()
      ..setInnerHtml("Can Contribute");

    headerRow.addCell()
      ..setInnerHtml("Revoke Access");

    TableSectionElement bodySection = _tabRoles.createTBody();
    roles.forEach((Role r) {
      TableRowElement row = bodySection.addRow();
      row.addCell()
        .append(new Text(r.getName()));
      row.addCell()
        ..setInnerHtml(r.isOwner().toString())
        ..classes.toggle(CSSClasses.clickable, ppii.getRole().isOwner())
        ..onClick.listen((_) {
          if(ppii.getRole().isOwner()) {
            _sendNewRoleRequest(r.getName(), true, r.isDeveloper() || !r.isOwner(), !r.isOwner());
          }
        });

      row.addCell()
        ..setInnerHtml(r.isDeveloper().toString())
        ..classes.toggle(CSSClasses.clickable, ppii.getRole().isOwner())
        ..onClick.listen((_) {
          if(ppii.getRole().isOwner()) {
            _sendNewRoleRequest(r.getName(), true, !r.isDeveloper(), false);
          }
        });

      row.addCell()
        ..setInnerHtml("Revoke")
        ..classes.toggle(CSSClasses.clickable, ppii.getRole().isOwner())
        ..onClick.listen((_) {
          if(ppii.getRole().isOwner()) {
            _sendNewRoleRequest(r.getName(), false, false, false);
          }
        });
    });
  }

  void _sendNewRoleRequest(String name, bool canView, bool canContribute, bool canManage) {
    uimii.getDBClient().makeRequest(new RequestSetRole(
        uimii.getAuthUsername(),
        uimii.getAuthPassword(),
        ppii.getProject().getPid(),
        name,
        canView,
        canContribute,
        canManage
    ));
  }

  void receivedSetRoleFailed() {
    _inputGrantUser.setAttribute("error", "true");
  }

  void adjustScrollHeight() {}
}