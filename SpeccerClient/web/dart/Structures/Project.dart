
class Project {
  String _pid;
  bool _isPublic;
  Project(this._pid, this._isPublic);

  String getPid() {
    return _pid;
  }

  bool isPublic() {
    return _isPublic;
  }
}