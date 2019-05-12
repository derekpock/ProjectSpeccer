
class Project {
  String _pid;
  bool _isPublic;
  String _name;
  Project(this._pid, this._isPublic, this._name);

  String getPid() {
    return _pid;
  }

  bool isPublic() {
    return _isPublic;
  }

  String getName() {
    return _name;
  }
}