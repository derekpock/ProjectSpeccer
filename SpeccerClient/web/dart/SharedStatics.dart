const ERROR_CODE = "error_code";

class RequestCodes {
  // Generic
  static const ping = "ping";
  static const pong = "pong";
  static const auth = "auth";

  // User operations
  static const addUser = "addUser";
  static const createProject = "createProject";
  static const browseProjects = "browseProjects";             // Returns visible projects and roles for uid.

  // Component operations
  static const componentGetAll = "componentGetAll";           // Returns all components for project if visible
  static const componentGetRecent = "componentGetRecent";
  static const componentAdd = "componentAdd";                 // Returns all components for project if visible

  // Comment operations
  static const commentGetAll = "commentGetAllForId";
//  static const commentGet = "commentGetForId";
  static const commentAdd = "commentAddToId";

  static const roleSet = "roleSet";
  static const roleGetAll = "roleGetAll";

  static const setProjectPublicity = "setProjectPublicity";
}

class DataElements {
  static const cmd = "~";
  static const username = "username";
  static const password = "password";
  static const email = "email";
  static const isPublic = "isPublic";
  static const pid = "pid";
  static const uid = "uid";
  static const cid = "cid";
  static const targetId = "targetId";
  static const targetUsername = "targetUsername";

  static const projectsAndRoles = "projects";
  static const components = "components";
  static const componentType = "componentType";
  static const componentData = "componentData";
  static const comments = "comments";
  static const commentValue = "commentValue";
  static const roles = "roles";

  static const roleCanView = "roleCanView";
  static const roleCanContribute = "roleCanContribute";
  static const roleCanManage = "roleCanManage";

  static const postgres_error = "postgres_error";
  static const postgres_code = "postgres_code";
  static const postgres_constraintName = "postgres_constraintName";
  static const postgres_detail = "postgres_detail";
  static const postgres_tableName = "postgres_tableName";

  static const error_object = "error_object";
  static const error_stacktrace = "error_stacktrace";
}

class ErrorCodes {
  // Generic
  static const SoFarSoGood = "SoFarSoGood";
  static const UnknownError = "UnknownError";
  static const UnknownPostgresError = "UnknownPostgresError";

  // Rogue clients
  static const InvalidRequest = "InvalidRequest";
  static const InvalidRequestFormat = "InvalidRequestFormat";
  static const InvalidRequestArguments = "InvalidRequestArguments";
  static const UnknownRequestCode = "UnknownRequestCode";
  static const OperationNotAuthorized = "OperationNotAuthorized";

  // Server errors
  static const DBAuthFailure = "DBAuthFailure";
  static const MultipleUsersFound = "MultipleUsersFound";
  static const UuidGenerationFailure = "UuidGenerationFailure";
  static const InvalidDatabaseStructure = "InvalidDatabaseStructure";
  static const ProjectCreationFailure = "ProjectCreationFailure";
  static const InvalidInternalUid = "InvalidInternalUid";
  static const NotImplemented = "NotImplemented";
  static const IdentifierNotFound = "IdentifierNotFound";

  // Client errors
  static const UsernameTaken = "UsernameTaken";
  static const InvalidNewPassword = "InvalidNewPassword";
  static const WrongAuth = "WrongAuth";
  static const InvalidUidForNewProject = "InvalidUidForNewProject";
  static const NoUserFound = "NoUserFound";

}

class IdentifierTypes {
  static const User = 1;
  static const Project = 2;
  static const Comment = 3;
  static const Component = 4;
}