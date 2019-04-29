
class Role {
  String _pid;
  bool _isOwner;
  bool _isDeveloper;

  Role(this._pid, this._isOwner, this._isDeveloper);

  String getPid() {
    return _pid;
  }

  bool isOwner() {
    return _isOwner;
  }

  bool isDeveloper() {
    return _isDeveloper;
  }
}