
import 'dart:html';
import '../CSSClasses.dart';

class Form {
  TableElement _element;
//  DivElement _leftElement;
//  DivElement _rightElement;

  Form() {
    _element = new TableElement();
    _element.classes.add(CSSClasses.form);
//
//    _leftElement = new DivElement();
//    _rightElement = new DivElement();
//
//    _element.append(_leftElement);
//    _element.append(_rightElement);
  }

  TableRowElement addInputViaString(String text, Element input) {
    return addRow([new LabelElement()..setInnerHtml(text), input]);
  }

  TableRowElement addRow(List<Element> elements) {
    TableRowElement row = _element.addRow();
    elements.forEach((Element e) {
      row.addCell().append(e);
    });
    return row;
  }

  Element getElement() {
    return _element;
  }
}