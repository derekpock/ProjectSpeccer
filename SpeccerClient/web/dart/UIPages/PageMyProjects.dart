
part of '../UIPage.dart';

class PageMyProjects extends UIPage {

  DivElement _utilities;
  TableElement _projects;

  DivElement _butNewPublicProject;
  DivElement _butNewPrivateProject;

  PageMyProjects(UIManagerInteractionInterface uimii) :
        super(uimii, true, false, true, "My Projects", "my_projects") {

    _butNewPublicProject = new DivElement();
    _butNewPublicProject.classes.add(CSSClasses.button);
    _butNewPublicProject.classes.add(CSSClasses.clickable);
    _butNewPublicProject.onClick.listen((_) {
      _uimii.getDBClient().makeRequest(new RequestNewProject(_uimii.getAuthUsername(), _uimii.getAuthPassword(), true));
    });
    _butNewPublicProject.setInnerHtml("New Public Project");

    _butNewPrivateProject = new DivElement();
    _butNewPrivateProject.classes.add(CSSClasses.button);
    _butNewPrivateProject.classes.add(CSSClasses.clickable);
    _butNewPrivateProject.onClick.listen((_) {
      _uimii.getDBClient().makeRequest(new RequestNewProject(_uimii.getAuthUsername(), _uimii.getAuthPassword(), false));
    });
    _butNewPrivateProject.setInnerHtml("New Private Project");


    _utilities = new DivElement();
    _utilities.classes.add(CSSClasses.horizontalFlow);
    _utilities.append(_butNewPublicProject);
    _utilities.append(_butNewPrivateProject);

    _projects = new TableElement();
    _projects.classes.add(CSSClasses.listTable);
    _projects.style.flex = "1";
    _projects.style.height = "100%";

    _content.classes.add(CSSClasses.verticalFlow);
    _content.append(_utilities);
    _content.append(_projects);
  }

  void refresh(List<Project> projects) {
    while(_projects.childNodes.isNotEmpty) {
      _projects.childNodes.first.remove();
    }

    TableSectionElement headerSection = _projects.createTHead();
    TableRowElement headerRow = headerSection.addRow();
    headerRow.addCell()
      ..setInnerHtml("Project Name");
    headerRow.addCell()
      ..setInnerHtml("Public");
//    headerRow.addCell()
//      ..setInnerHtml("Owner");
//    headerRow.addCell()
//      ..setInnerHtml("Developer");

    TableSectionElement bodySection = _projects.createTBody();
    projects.forEach((Project p) {
      TableRowElement row = bodySection.addRow();
      row.addCell()
        ..append(new Text(p.getName()))
        ..classes.add(CSSClasses.clickable)
        ..onClick.listen((_) => _uimii.openProject(p.getPid()));
      row.addCell()
        ..setInnerHtml(p.isPublic().toString());
    });
  }
}