import 'dart:html';

import '../Structures/Role.dart';
import '../UIPages/PageProjectInteractionInterface.dart';

typedef String GetRemoteComponentValue();
typedef void SetRemoteComponentValue(String newValue);

class TextAreaForm {

  PageProjectInteractionInterface ppii;
  DivElement content;
  TextAreaElement textArea;
  LabelElement header;
  int componentType;
  String defaultValue;
  Role r;
  bool contributorCanModify;

  GetRemoteComponentValue getRemoteComponentValue;
  SetRemoteComponentValue setRemoteComponentValue;

  TextAreaForm(String title, this.ppii, this.contributorCanModify, {this.defaultValue = "", this.componentType = -1, this.getRemoteComponentValue, this.setRemoteComponentValue}) {
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

    textArea = new TextAreaElement();
    textArea.onInput.listen((_) => adjustScrollHeight());

    textArea.onBlur.listen((_) {
      if((contributorCanModify ? r.isDeveloper() : r.isOwner())) {
        setRemoteComponentValue(textArea.value);
      }
    });

    content = new DivElement();
    content.append(header);
    content.append(textArea);
  }

  void adjustScrollHeight() {
    textArea.style.height = "auto";
    textArea.style.padding = "0";
    // for box-sizing other than "content-box" use:
    // el.style.cssText = '-moz-box-sizing:content-box';
    textArea.style.height = "${textArea.scrollHeight}px";
    textArea.style.padding = "";
    if(textArea.scrollHeight <= 10) {
      Future(() => adjustScrollHeight);
    }
  }

  void refreshComponent() {
    textArea.value = getRemoteComponentValue();
    Future(() => adjustScrollHeight);
  }

  void setPermissions(Role r) {
    this.r = r;
    textArea.disabled = !(contributorCanModify ? r.isDeveloper() : r.isOwner());
  }
}