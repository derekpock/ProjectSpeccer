
import 'dart:html';
import '../CSSClasses.dart';
import '../UIManagerInteractionInterface.dart';
import '../UIPages/PageProjectInteractionInterface.dart';

abstract class AbstractStage {

  DivElement _div;
  DivElement _banner;
  DivElement content;
  UIManagerInteractionInterface uimii;
  PageProjectInteractionInterface ppii;

  AbstractStage(this.uimii, this.ppii, String bannerTitle) {
    _div = new DivElement();
    _div.classes.add(CSSClasses.projectStage);

    _banner = new DivElement();
    _banner.setInnerHtml(bannerTitle);
    _banner.classes.add(CSSClasses.clickable);
    _banner.onClick.listen(_onBannerClick);

    content = new DivElement();

    _div.append(_banner);
    _div.append(content);
  }

  DivElement getElement() {
    return _div;
  }

  void _onBannerClick(_) {
    print("clicked");
    ppii.setActiveStage(this);
  }

  void setContentVisible(bool visible) {
    content.classes.toggle(CSSClasses.hidden, !visible);
  }
}