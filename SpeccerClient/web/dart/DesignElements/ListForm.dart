
import 'dart:html';

import '../Structures/Role.dart';
import '../UIPages/PageProjectInteractionInterface.dart';
import '../CSSClasses.dart';
import 'package:uuid/uuid.dart';

typedef List<dynamic> GetRemoteComponentValue();
typedef void SetRemoteComponentValue(List<dynamic> newValue);

class ListForm {
  static const TextAreaType = 0;
  static const TextInputType = 1;
  static final _uuidGen = Uuid();
  
  PageProjectInteractionInterface ppii;
  DivElement content;

  DivElement header;
  LabelElement headerLabel;
  DivElement butAdd;
  DivElement divItems;
  List<AbstractListFormItem> listFormItems;

  int typeT;
  int componentType;
  Role r;
  bool contributorCanModify;
  final bool useLinkedListAndUuids;

  GetRemoteComponentValue getRemoteComponentValue;
  SetRemoteComponentValue setRemoteComponentValue;

  ListForm(this.typeT, String title, this.ppii, this.contributorCanModify, {this.componentType = -1, this.getRemoteComponentValue, this.setRemoteComponentValue, this.useLinkedListAndUuids = false}) {
    if((componentType == -1) == (getRemoteComponentValue == null || setRemoteComponentValue == null)) {
      throw "Must specify either a componentType for automatic component management or BOTH get and set remote component value callbacks.";
    }
    
    if(getRemoteComponentValue == null || setRemoteComponentValue == null) {
      if((getRemoteComponentValue == null) != (setRemoteComponentValue == null)) {
        throw "When manually managing components, you must specify both get and set remote component value callbacks.";
      }
      if(!useLinkedListAndUuids) {
        getRemoteComponentValue = () => ppii.getLiveComponent(componentType).getDataElement("listData", new List());
        setRemoteComponentValue = (List<dynamic> value) => ppii.addRevisionWithOneItem(componentType, "listData", value);        
      }
    } else if (useLinkedListAndUuids) {
      throw "Manual management of components not allowed with useLinkedListAndUuids mode.";
    }
    if(typeT < 0 || typeT >= 2) {
      throw "Implementation of AbstractListFormItem not known!";
    }

    listFormItems = new List();
    if(useLinkedListAndUuids) {
      listFormItems.add(AbstractListFormItem.Load(typeT, this, initialValue: "dummy", uuidFrom: "00000000-0000-0000-0000-000000000000", uuidTo: "00000000-0000-0000-0000-000000000000"));
    }

    headerLabel = new LabelElement();
    headerLabel.append(new Text(title));

    butAdd = new DivElement();
    butAdd.classes.add(CSSClasses.button);
    butAdd.classes.add(CSSClasses.clickable);
    butAdd.append(new Text("Add Item"));
    butAdd.onClick.listen((_) {
      if((contributorCanModify ? r.isDeveloper() : r.isOwner())) {
        if(useLinkedListAndUuids) {
          String newUuid = _uuidGen.v4();
          listFormItems.firstWhere((AbstractListFormItem item) => item.uuidTo == "00000000-0000-0000-0000-000000000000").uuidTo = newUuid;
          listFormItems.add(AbstractListFormItem.Load(typeT, this, uuidFrom: newUuid, uuidTo: "00000000-0000-0000-0000-000000000000"));
          divItems.append(listFormItems.last.content);
        } else {
          listFormItems.add(AbstractListFormItem.Load(typeT, this));
          divItems.append(listFormItems.last.content);
        }
      }
    });

    divItems = new DivElement();
    header = new DivElement();

    header.append(headerLabel);
    header.append(butAdd);

    content = new DivElement();
    content.classes.add(CSSClasses.listForm);
    content.append(header);
    content.append(divItems);
  }

  void refreshComponent() {
    while(divItems.childNodes.isNotEmpty) {
      divItems.lastChild.remove();
    }
    listFormItems.clear();

    if(useLinkedListAndUuids) {
      List<dynamic> data = ppii.getLiveComponent(componentType).getDataElement("listDataUuid", new List()..add(["00000000-0000-0000-0000-000000000000", "00000000-0000-0000-0000-000000000000", "dummy"]));
      data.forEach((s) {
        s = s as List;
        listFormItems.add(AbstractListFormItem.Load(typeT, this, initialValue: s[2], uuidFrom: s[0], uuidTo: s[1]));
        if(s[0] != "00000000-0000-0000-0000-000000000000") {
          divItems.append(listFormItems.last.content);
        }
      });
    } else {
      List<dynamic> data = getRemoteComponentValue();
      data.forEach((s) {
        listFormItems.add(AbstractListFormItem.Load(typeT, this, initialValue: s));
        divItems.append(listFormItems.last.content);
      });
    }
  }

  void setPermissions(Role r) {
    this.r = r;
    bool disabled = !(contributorCanModify ? r.isDeveloper() : r.isOwner());
    butAdd.setAttribute("disabled", (disabled ? "true" : "false"));
    listFormItems.forEach((AbstractListFormItem i) {
      i.setDisabled(disabled);
    });
  }

  void childBlurred() {
    if((contributorCanModify ? r.isDeveloper() : r.isOwner())) {
      if(useLinkedListAndUuids) {
        List<List<String>> data = new List();

        listFormItems.forEach((AbstractListFormItem item) {
          List<String> itemData = new List();
          itemData.add(item.uuidFrom);
          itemData.add(item.uuidTo);
          itemData.add(item.getValue());
          data.add(itemData);
        });

        ppii.addRevisionWithOneItem(componentType, "listDataUuid", data);
      } else {
        List<String> data = new List();
        listFormItems.forEach((AbstractListFormItem item) {
          data.add(item.getValue());
        });
        setRemoteComponentValue(data);
      }
    }
  }

  // Dummy starting value
  // 0000 -> aaaa noname
  // aaaa -> bbbb Aa aa
  // bbbb -> 0000 Bb bb

  void removeChild(AbstractListFormItem item) {
    if((contributorCanModify ? r.isDeveloper() : r.isOwner())) {
      int index = listFormItems.indexOf(item);
      if(useLinkedListAndUuids) {
        // Assuming sane structures
        for(int i = 0; i < listFormItems.length; i++) {
          if(listFormItems[i].uuidTo == item.uuidFrom) {
            listFormItems[i].uuidTo = item.uuidTo;
            break;
          }
        }
        //TODO remove project uuid's here from other areas
      }
      listFormItems.removeAt(index);
      divItems.children[index].remove();
      childBlurred();
    }
  }

  void adjustScrollHeight() {
    listFormItems.forEach((AbstractListFormItem item) {
      item.adjustScrollHeight();
    });
  }
}

abstract class AbstractListFormItem {
  String uuidFrom;
  String uuidTo;
  DivElement content;
  DivElement removeButton;
  ListForm parent;

  AbstractListFormItem(this.parent, {this.uuidFrom, this.uuidTo}) {
    content = new DivElement();
    content.classes.add(CSSClasses.listFormItem);

    removeButton = new DivElement();
    removeButton.classes.add(CSSClasses.clickable);
    removeButton.classes.add(CSSClasses.button);
    removeButton.append(new Text("Remove"));
    removeButton.onClick.listen((_) {
      parent.removeChild(this);
    });
  }

  static AbstractListFormItem Load(int type, ListForm parent, {String uuidFrom, String uuidTo, String initialValue = ""}) {
    if(type == ListForm.TextInputType) {
      return new TextInputListFormItem(parent, initialValue)
        ..uuidFrom = uuidFrom
        ..uuidTo = uuidTo;
    } else if(type == ListForm.TextAreaType){
      return new TextAreaListFormItem(parent, initialValue)
        ..uuidFrom = uuidFrom
        ..uuidTo = uuidTo;
    } else {
      throw "Unknown AbstractListFormItem New type";
    }
  }
  void adjustScrollHeight() {}

  void setDisabled(bool disabled);

  String getValue();
}

class TextInputListFormItem extends AbstractListFormItem {
  TextInputElement input;

  TextInputListFormItem(parent, [String initialValue = ""]) : super(parent){
    input = new TextInputElement();
    input.value = initialValue;

    input.onKeyDown.listen((KeyboardEvent e) {
      if(e.keyCode == KeyCode.ENTER) {
        input.blur();
      }
    });

    input.onBlur.listen((_) {
      parent.childBlurred();
    });

    content.append(input);
    content.append(removeButton);
  }

  void setDisabled(bool disabled) {
    input.disabled = disabled;
    removeButton.setAttribute("disabled", (disabled ? "true" : "false"));
  }

  String getValue() {
    return input.value;
  }
}

class TextAreaListFormItem extends AbstractListFormItem {
  TextAreaElement input;

  TextAreaListFormItem(parent, [String initialValue = ""]) : super(parent){
    input = new TextAreaElement();
    input.value = initialValue;

    input.onBlur.listen((_) {
      parent.childBlurred();
    });

    input.onInput.listen((_) => adjustScrollHeight());

    content.append(input);
    content.append(removeButton);

    input.onResize.listen((_) => print('test'));
    adjustScrollHeight();
  }

  void adjustScrollHeight() {
    input.style.cssText = 'height:auto; padding:0';
    // for box-sizing other than "content-box" use:
    // el.style.cssText = '-moz-box-sizing:content-box';
    Future(() {
      input.style.cssText = 'height:${input.scrollHeight}px';
      if(input.scrollHeight <= 10) {
        Future(() => adjustScrollHeight);
      }
    });
  }

  void setDisabled(bool disabled) {
    input.disabled = disabled;
    removeButton.setAttribute("disabled", (disabled ? "true" : "false"));
  }

  String getValue() {
    return input.value;
  }
}
