import 'dart:html';
import '../CSSClasses.dart';
import '../UIPages/PageProjectInteractionInterface.dart';
import '../Structures/Role.dart';

class TreeStructure {
  PageProjectInteractionInterface ppii;
  int componentType;
  DivElement content;

  DivElement divStructureHeader;
  LabelElement labelStructureTitle;
  List<DivElement> butStructureAddBranch;

  DivElement divStructureContent;
  Map<String, DivElement> divBranchType;

  Map<String, List<TreeBranch>> branchesByType;
  bool disabled;
  final Map<String, List<String>> layerStructure;

  TreeStructure(this.ppii, this.componentType, String headerTitle, this.layerStructure) {
    disabled = true;

    content = new DivElement();
    content.classes.add(CSSClasses.treeStructure);

    divStructureHeader = new DivElement();
    divStructureHeader.classes.add(CSSClasses.horizontalFlow);

    labelStructureTitle = new LabelElement();
    labelStructureTitle.append(new Text(headerTitle));
    divStructureHeader.append(labelStructureTitle);

    divStructureContent = new DivElement();
    butStructureAddBranch = new List();
    divBranchType = new Map();
    branchesByType = new Map();

    layerStructure.forEach((String branchType, List<String> leafTypes) {
      divBranchType[branchType] = new DivElement();
      branchesByType[branchType] = new List();

      DivElement butAddNewBranchType = new DivElement();
      butAddNewBranchType.append(new Text("Add ${branchType}"));
      butAddNewBranchType.classes.add(CSSClasses.button);
      butAddNewBranchType.classes.add(CSSClasses.clickable);
      butAddNewBranchType.onClick.listen((_) {
        if(!disabled) {
          _addBranch(branchType, leafTypes);
        }
      });
      butStructureAddBranch.add(butAddNewBranchType);
      divStructureHeader.append(butAddNewBranchType);
      divStructureContent.append(divBranchType[branchType]);
    });

    content.append(divStructureHeader);
    content.append(divStructureContent);
  }

  void refreshComponent() {
    // Clear out branch divs.
    divBranchType.forEach((String type, DivElement divForType) {
      while(divForType.childNodes.isNotEmpty) {
        divForType.childNodes.last.remove();
      }
    });

    // Clear out branches from list
    branchesByType.keys.forEach((String branchType) {
      branchesByType[branchType].clear();
    });

    Map<dynamic, dynamic> structureData = ppii.getLiveComponent(componentType).getDataElement("data", new Map());
    structureData.forEach((branchType, branches) {
      (branches as List<dynamic>).forEach((branchData) {
        _addBranch(
            branchType as String,
            layerStructure[branchType as String],
            branchData as Map<dynamic, dynamic>);
      });
    });
  }

  void _addBranch(String type, List<String> leafTypes, [Map<dynamic, dynamic> initialData]) {
    TreeBranch tb = new TreeBranch(this, type, leafTypes, initialData);
    branchesByType[type].add(tb);
    divBranchType[type].append(tb.divBranchRoot);
    tb.setPermissions(disabled);
  }

  void setPermissions(Role r) {
    disabled = !r.isDeveloper();
    String disabledText = (disabled ? "true" : "false");

    butStructureAddBranch.forEach((DivElement button) {
      button.setAttribute("disabled", disabledText);
    });

    branchesByType.forEach((String branchType, List<TreeBranch> branches) {
      branches.forEach((TreeBranch tb) {
        tb.setPermissions(disabled);
      });
    });
  }

  //Map       <String,   List           <Map       <String, List        <String>>>>
  //structure branchType listOfBranches branchData leafType listOfLeafs leafData
  //
  //Map<String, List<"", "myBranchname>>
  void branchModified() {
    if(!disabled) {
      Map<String, List<dynamic>> structureData = new Map();
      branchesByType.forEach((String branchType, List<TreeBranch> branches) {
        structureData[branchType] = new List();
        branches.forEach((TreeBranch tb) {
          Map<String, dynamic> branchData = new Map();
          branchData[""] = tb.inputBranchName.value;
          tb.leafsByType.forEach((String leafType, List<TreeLeaf> leafs) {
            branchData[leafType] = new List();
            leafs.forEach((TreeLeaf tl) {
              branchData[leafType].add(tl.inputLeafName.value);
            });
          });
          structureData[branchType].add(branchData);
        });
      });
      ppii.addRevisionWithOneItem(componentType, "data", structureData);
    }
  }

  void branchRemoved(TreeBranch treeBranch) {
    if(!disabled) {
      int index = branchesByType[treeBranch.type].indexOf(treeBranch);
      branchesByType[treeBranch.type].removeAt(index);
      divBranchType[treeBranch.type].childNodes[index].remove();
      branchModified();
    }
  }
}

class TreeBranch {

  TreeStructure structure;

  DivElement divBranchRoot;

  DivElement divBranchHeader;

  DivElement divBranchType;
  TextInputElement inputBranchName;
  DivElement butRemoveBranch;
  List<DivElement> butBranchAddLeaf;

  DivElement divBranchContent;
  Map<String, DivElement> divLeafType;

  Map<String, List<TreeLeaf>> leafsByType;

  bool disabled;
  String type;

  TreeBranch(this.structure, this.type, List<String> childrenTypes, [Map<dynamic, dynamic> initialData]) {
    disabled = true;
    String initialName = "";
    if(initialData != null) {
      initialName = initialData[""];
    }

    butBranchAddLeaf = new List();
    divLeafType = new Map();
    leafsByType = new Map();

    divBranchRoot = new DivElement();
    divBranchRoot.classes.add(CSSClasses.treeBranch);

    divBranchHeader = new DivElement();
    divBranchHeader.classes.add(CSSClasses.horizontalFlow);

    divBranchType = new DivElement();
    divBranchType.append(new Text(type));

    inputBranchName = new TextInputElement();
    inputBranchName.value = initialName;
    inputBranchName.onKeyDown.listen((KeyboardEvent e) {
      if(e.keyCode == KeyCode.ENTER) {
        inputBranchName.blur();
      }
    });

    inputBranchName.onBlur.listen((_) {
      if(!disabled) {
        structure.branchModified();
      }
    });

    butRemoveBranch = new DivElement();
    butRemoveBranch.classes.add(CSSClasses.button);
    butRemoveBranch.classes.add(CSSClasses.clickable);
    butRemoveBranch.append(new Text("Remove"));
    butRemoveBranch.onClick.listen((_) {
      if(!disabled) {
        structure.branchRemoved(this);
      }
    });

    divBranchHeader.append(divBranchType);
    divBranchHeader.append(inputBranchName);
    divBranchHeader.append(butRemoveBranch);

    divBranchContent = new DivElement();

    childrenTypes.forEach((String type) {
      leafsByType[type] = new List();
      divLeafType[type] = new DivElement();

      DivElement addLeafType = new DivElement();
      addLeafType.append(new Text("Add ${type}"));
      addLeafType.classes.add(CSSClasses.button);
      addLeafType.classes.add(CSSClasses.clickable);
      addLeafType.onClick.listen((_) {
        if(!disabled) {
          _addLeaf(type);
        }
      });
      divBranchHeader.append(addLeafType);
      butBranchAddLeaf.add(addLeafType);
      divBranchContent.append(divLeafType[type]);
    });

    divBranchRoot.append(divBranchHeader);
    divBranchRoot.append(divBranchContent);

    if(initialData != null) {
      (initialData as Map<String, dynamic>).forEach((String type, dynamic leafNames) {
        if(type.isNotEmpty) {
          (leafNames as List<dynamic>).forEach((dynamic name) {
            _addLeaf(type, name as String);
          });
        }
      });
    }

    setPermissions(disabled);
  }

  void _addLeaf(String type, [String initialValue = ""]) {
    TreeLeaf tl = new TreeLeaf(this, type, initialValue);
    leafsByType[type].add(tl);
    divLeafType[type].append(tl.divLeafRoot);
    tl.inputLeafName.disabled = disabled;
    tl.butRemove.setAttribute("disabled", (disabled ? "true" : "false"));
  }

  void setPermissions(bool disabled) {
    this.disabled = disabled;
    String disabledText = disabled ? "true" : "false";

    inputBranchName.disabled = disabled;
    butRemoveBranch.setAttribute("disabled", disabledText);
    butBranchAddLeaf.forEach((DivElement e) {
      e.setAttribute("disabled", disabledText);
    });
    leafsByType.forEach((String type, List<TreeLeaf> list) {
      list.forEach((TreeLeaf tl) {
        tl.inputLeafName.disabled = disabled;
        tl.butRemove.setAttribute("disabled", disabledText);
      });
    });
  }

  void leafModified() {
    if(!disabled) {
      structure.branchModified();
    }
  }

  void leafRemoved(TreeLeaf treeLeaf) {
    if(!disabled) {
      int index = leafsByType[treeLeaf.type].indexOf(treeLeaf);

      leafsByType[treeLeaf.type].removeAt(index);
      divLeafType[treeLeaf.type].childNodes[index].remove();
      structure.branchModified();
    }
  }
}

class TreeLeaf {
  DivElement divLeafRoot;
  DivElement divLeafType;
  TextInputElement inputLeafName;
  DivElement butRemove;

  TreeBranch branch;
  String type;

  TreeLeaf(this.branch, this.type, [String initialValue = ""]) {
    divLeafRoot = new DivElement();
    divLeafRoot.classes.add(CSSClasses.horizontalFlow);
    divLeafRoot.classes.add(CSSClasses.treeLeaf);

    divLeafType = new DivElement();
    divLeafType.append(new Text(type));

    inputLeafName = new TextInputElement();
    inputLeafName.value = initialValue;
    inputLeafName.onKeyDown.listen((KeyboardEvent e) {
      if(e.keyCode == KeyCode.ENTER) {
        inputLeafName.blur();
      }
    });

    inputLeafName.onBlur.listen((_) {
      branch.leafModified();
    });

    butRemove = new DivElement();
    butRemove.classes.add(CSSClasses.button);
    butRemove.classes.add(CSSClasses.clickable);
    butRemove.append(new Text("Remove"));
    butRemove.onClick.listen((_) {
      branch.leafRemoved(this);
    });

    divLeafRoot.append(divLeafType);
    divLeafRoot.append(inputLeafName);
    divLeafRoot.append(butRemove);
  }
}