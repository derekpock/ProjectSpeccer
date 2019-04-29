
part of '../UIPage.dart';

class PageBrowse extends UIPage {
  DivElement _utilities;
  TableElement _projects;

  DivElement _butRefresh;

  PageBrowse(UIManagerInteractionInterface uimii) :
        super(uimii, true, "Browse") {
    _butRefresh = new DivElement();
    _butRefresh.classes.add(CSSClasses.button);
    _butRefresh.classes.add(CSSClasses.clickable);
    _butRefresh.onClick.listen((_) {
      _uimii.refreshProjectsAndRoles();
    });
    _butRefresh.setInnerHtml("Refresh");

    _utilities = new DivElement();
    _utilities.classes.add(CSSClasses.horizontalFlow);
    _utilities.append(_butRefresh);

    _projects = new TableElement();
    _projects.classes.add(CSSClasses.listTable);
    _projects.style.flex = "1";
    _projects.style.height = "100%";

    _content.classes.add(CSSClasses.verticalFlow);
    _content.append(_utilities);
    _content.append(_projects);
  }

  void refresh(List<Project> projects, Map<String, Role> roles) {
    while(_projects.childNodes.isNotEmpty) {
      _projects.childNodes.first.remove();
    }

    TableSectionElement headerSection = _projects.createTHead();
    TableRowElement headerRow = headerSection.addRow();
    headerRow.addCell()
      ..setInnerHtml("Project ID");
    headerRow.addCell()
      ..setInnerHtml("Public");
    headerRow.addCell()
      ..setInnerHtml("Owner");
    headerRow.addCell()
      ..setInnerHtml("Developer");

    TableSectionElement bodySection = _projects.createTBody();
    projects.forEach((Project p) {
      TableRowElement row = bodySection.addRow();
      row.addCell()
        ..setInnerHtml(p.getPid())
        ..classes.add(CSSClasses.clickable)
        ..onClick.listen((_) => _uimii.openProject(p));
      row.addCell()
        ..setInnerHtml(p.isPublic().toString());

      Role role = roles[p.getPid()];
      if(role != null) {
        row.addCell()
          ..setInnerHtml(role.isOwner().toString());
        row.addCell()
          ..setInnerHtml(role.isDeveloper().toString());
      } else {
        row.addCell()
          ..setInnerHtml(false.toString());
        row.addCell()
          ..setInnerHtml(false.toString());
      }
    });
  }
}