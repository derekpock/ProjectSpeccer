import 'dart:html';

import '../Structures/Role.dart';
import '../UIPages/PageProjectInteractionInterface.dart';

typedef String GetRemoteComponentValue();
typedef void SetRemoteComponentValue(String newValue);

class TextInputForm {

  PageProjectInteractionInterface ppii;
  DivElement content;
  TextInputElement textInput;
  LabelElement header;
  int componentType;
  String defaultValue;
  Role r;
  bool contributorCanModify;

  GetRemoteComponentValue getRemoteComponentValue;
  SetRemoteComponentValue setRemoteComponentValue;

  TextInputForm(String title, this.ppii, this.contributorCanModify, {this.defaultValue = "", this.componentType = -1, this.getRemoteComponentValue, this.setRemoteComponentValue}) {
    if((componentType == -1) == (getRemoteComponentValue == null || setRemoteComponentValue == null)) {
      throw "Must specify either a componentType for automatic component management or BOTH get and set remote component value callbacks.";
    }

    if(getRemoteComponentValue == null || setRemoteComponentValue == null) {
      if((getRemoteComponentValue == null) != (setRemoteComponentValue == null)) {
        throw "When manually managing components, you must specify both get and set remote component value callbacks.";
      }
      getRemoteComponentValue = () => ppii.getLiveComponent(componentType).getDataElement("data", defaultValue);
      setRemoteComponentValue = (String value) => ppii.addRevisionWithOneItem(componentType, "data", value);
    }

    header = new LabelElement();
    header.append(new Text(title));

    textInput = new TextInputElement();
    textInput.onKeyDown.listen((KeyboardEvent e) {
      if(e.keyCode == KeyCode.ENTER) {
        textInput.blur();
      }
    });

    textInput.onBlur.listen((_) {
      if((contributorCanModify ? r.isDeveloper() : r.isOwner())) {
        setRemoteComponentValue(textInput.value);
      }
    });

    content = new DivElement();
    content.append(header);
    content.append(textInput);
  }

  void refreshComponent() {
    textInput.value = getRemoteComponentValue();
  }

  void setPermissions(Role r) {
    this.r = r;
    textInput.disabled = !(contributorCanModify ? r.isDeveloper() : r.isOwner());
  }
}