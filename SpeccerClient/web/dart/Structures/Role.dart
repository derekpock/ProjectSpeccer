
class Role {
  static List<Role> parseRolesFromRawQuery(List<dynamic> rawRoles) {
    List<Role> roles = new List();

    rawRoles.forEach((dynamic rawRole) {
      rawRole = rawRole as List<dynamic>;
      roles.add(new Role(
          rawRole[4], // name
          rawRole[0], // uid
          rawRole[1], // pid
          rawRole[2], // owner
          rawRole[3]  // developer
      ));
    });

    return roles;
  }

  String _name;
  String _uid;
  String _pid;
  bool _isOwner;
  bool _isDeveloper;

  Role(this._name, this._uid, this._pid, this._isOwner, this._isDeveloper);

  String getName() {
    return _name;
  }

  String getUid() {
    return _uid;
  }

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