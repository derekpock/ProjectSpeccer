import '../SharedStatics.dart';
import 'dart:convert';

/// A component represents some piece of information about a project. These
/// components are generally organized by the type identifier to determine what
/// the component actually contains. The official versions of components are
/// always on the server. What we have locally may not be up-to-date.
///
/// Lifecycle of a Component:
/// 1. Old revisions loaded from server.
/// 2. User modifies (or adds if no pre-existing component) component via ui.
/// 3. New revision created from older revision component or brand-new created.
/// 4. If user aborts modifications (component is not dirty):
///   a. Component never added to the list
///   b. UI reloads most recent revision
///   c. No update is made to the server - ppii.addComponent is not called.
/// 5. If user creates and saves modifications (component is dirty):
///   a. Component is uploaded to server
///   b. Server responds with new list of components
///   c. All components are "re-freshed"
///   d. UI re-loads most recent revision (should be the newly added one)
///      This must be done in a way so that the user doesn't recognize any
///      change in the UI - no flickers, glitches, cursor position resets, etc.
///
/// There are a few things that can happen during this process:
/// - Expected revision is behind (someone else made a modification before us)
///   - Our change is lost (maybe notify the user of this)
///   - The update we receive from the server in 5b is not what we expect
///   - UI will update to the new component, causing some distress for the user
///
/// Additionally, our received copy in step 5c may not / will not be identical
/// the copy that we sent to the server - the server re-defines the "created"
/// time as that when it is received (client can't fake out the server's time
/// keeping within components).
///
/// Components cannot be removed - only revised! So if we want to create a
/// "features" component, it will have to manage all features - not be 1 feature
/// to 1 component. If the project has no features - it will be represented by
/// an empty features component.
///
/// Therefore, due to the nature of components (be dirty for as short as
/// possible but only create components that we expect to exist forever) we want
/// to group up items into components, and make new revisions every time we add
/// or remove something from them.
class Component {
  static List<List<Component>> parseComponentsFromRawQuery(List<dynamic> rawComponents) {
    List<List<Component>> components = new List();

    rawComponents.forEach((dynamic rawComponent) {
      rawComponent = rawComponent as List<dynamic>;
      int type = rawComponent[5];

      while(components.length <= type) {
        components.add(new List());
      }

      components[type].add(new Component.fromDatabase(
          rawComponent[0], // cid
          rawComponent[1], // revision
          rawComponent[2], // pid
          rawComponent[3], // uid
          DateTime.parse(rawComponent[4]), // date
          rawComponent[5], // type
          jsonDecode(rawComponent[6])  // data
      ));
    });

    return components;
  }

  String _cid;
  int _revision;
  String _pid;
  String _uid;
  DateTime _dateCreated;
  int _type;
  Map<String, dynamic> _data;

  bool _dirty;
  bool _editable;

  /// Create a brand new component.
  /// Only generally used when a project is being created for the first time.
  /// This is not editable.
  Component.newBase(this._pid, this._uid, this._type) :
        _cid = "00000000-0000-0000-0000-000000000000",
        _revision = 0,
        _dateCreated = DateTime.now(),
        _data = new Map(),
        _dirty = false,
        _editable = false;

  /// Load a component from the database.
  /// These *cannot* be edited! Make a revision first if you want to edit
  /// something.
  /// Since they cannot be edited, these are never dirty.
  Component.fromDatabase(this._cid, this._revision, this._pid, this._uid, this._dateCreated, this._type, this._data) :
        _dirty = false,
        _editable = false;

  /// Create a revision from an older component.
  /// This is editable and not considered dirty until something is added.
  Component.newRevision(Component oldComponent, this._uid) :
        _cid = oldComponent._cid,
        _revision = oldComponent._revision + 1,
        _pid = oldComponent._pid,
        _dateCreated = DateTime.now(),
        _type = oldComponent._type,
        _data = new Map()..addAll(oldComponent._data),
        _dirty = false,
        _editable = true;

  /// Edit the component. If key already exists - its value is overwritten.
  /// Calling this will dirty the component - needs updated to server asap.
  /// Calling this on a non-editable component (such as from the db or one that
  /// is already uploaded) will throw an error - don't do it!.
  void addDataElement(String key, dynamic value) {
    if(_editable) {
      if(_data[key] != value) {
        _data[key] = value;
        _dirty = true;
      }
    } else {
      throw "Attempted to add data elements to an uneditable component!";
    }
  }

  /// Get an element from this component.
  /// If the the value retrieved is null, will return [valueIfNull] instead (if
  /// its not provided, it will return null either way).
  dynamic getDataElement(String key, [dynamic valueIfNull]) {
    dynamic value = _data[key];
    if(value == null) {
      return valueIfNull;
    } else {
      return value;
    }
  }

  /// Writes out the component's data to [outData] if it is dirty and editable.
  /// Returns whether anything was written or not.
  /// Calling this on a dirty component will "lock" it - making is no longer
  /// editable.
  bool writeIfDirty(Map<String, dynamic> outData) {
    if(_dirty && _editable) {
      outData[DataElements.pid] = _pid;
      outData[DataElements.cid] = _cid;
      outData[DataElements.componentType] = _type;
      outData[DataElements.componentData] = jsonEncode(_data);
      _dirty = false;
      _editable = false;
      return true;
    } else {
      return false;
    }
  }

  bool isEditable() {
    return _editable;
  }

  int getRevision() {
    return _revision;
  }

  String getPid() {
    return _pid;
  }

  String getUid() {
    return _uid;
  }

  DateTime getDateCreated() {
    return _dateCreated;
  }

  int getType() {
    return _type;
  }
}

class ComponentTypes {
  static const ProjectName = 1;
  static const ProjectDescription = 2;
  static const SubHeading = 3;
  static const WhatAreWeBuilding = 4;
  static const WhatAreWeNotBuilding = 5;
  static const Features = 6;
  static const ExamplesOfSimilar = 7;
  static const WhoWeNeed = 8;
  static const CompensationAndBenefits = 9;
  static const WhatHasBeenDone = 10;
  static const References = 11;
  static const ExamplesOfUse = 12;
  static const Schedule = 13;

  static const UseCases = 14;
  static const Objectives = 15;
  static const Frameworks = 16;
  static const ProjectLinks = 17;
  static const DesignOptions = 18;

  static const DataStructures = 19;
  static const DatabaseStructures = 20;
  static const UIFormsViews = 21;
  static const UIDesigner = 22;
//
//  static const CompletedObjectives = 23;
//  static const CompletedFeatures = 24;

//  static const AdditionalTests = 25;

  static const ProjectSubheading = 26;
  static const Repository = 27;
  static const IssueTracker = 28;
  static const UsesDB = 29;
  static const UsesUI = 30;

  static const WhereDistributed = 31;
  static const WhereForums = 32;
  static const WhereUpdates = 33;
}