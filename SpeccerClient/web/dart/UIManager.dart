import "dart:html";

class UIManager {

  static const pHome = "pHome";
  static const pLogin = "pLogin";
  static const pBrowse = "pBrowse";
  static const pProject = "pProject";

  DivElement divUIManager;

  UIManager() :
        divUIManager = document.getElementById("uiManager") {
    document.getElementById("bHome").onClick.listen((_) => setActivePage(pHome));
    document.getElementById("bLogin").onClick.listen((_) => setActivePage(pLogin));
    setActivePage(pHome);
  }

  void setActivePage(String id) {
    divUIManager.childNodes.forEach((Node div) {
      if( div is DivElement &&
          div.classes.contains("uiPage") &&
          (div.id == id) == (div.classes.contains("Hidden"))) {
        div.classes.toggle("Hidden");
      }
    });
  }
}