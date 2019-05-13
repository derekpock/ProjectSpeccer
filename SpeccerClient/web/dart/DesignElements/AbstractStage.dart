
import 'dart:html';
import '../CSSClasses.dart';
import '../UIManagerInteractionInterface.dart';
import '../UIPages/PageProjectInteractionInterface.dart';
import '../Structures/Project.dart';
import '../Structures/Role.dart';
import '../Structures/Component.dart';

abstract class AbstractStage {

  DivElement _div;
  DivElement _banner;
  DivElement content;
  UIManagerInteractionInterface uimii;
  PageProjectInteractionInterface ppii;
  int _id;

  AbstractStage(this.uimii, this.ppii, this._id, String bannerTitle) {
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

  int getId() {
    return _id;
  }

  DivElement getElement() {
    return _div;
  }

  void _onBannerClick(_) {
    ppii.setActiveStage(this);
  }

  void setContentVisible(bool visible) {
    content.classes.toggle(CSSClasses.hidden, !visible);
  }

  /// Call refreshComponents as a child of this, since you might have some
  /// components to work with already.
  void refreshProject(Project p, Role r);

  /// Refresh all data as if it is brand-new.
  void refreshComponents();

  void adjustScrollHeight();
}