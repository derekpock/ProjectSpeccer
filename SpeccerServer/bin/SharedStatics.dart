const ERROR_CODE = "error_code";

class RequestCodes {
  static const ping = "ping";
  static const addUser = "addUser";
  static const createProject = "createProject";
}

class DataElements {
  static const cmd = "~";
  static const username = "username";
  static const password = "password";
  static const email = "email";
  static const isPublic = "isPublic";
  static const pid = "pid";

  static const postgres_error = "postgres_error";
  static const postgres_code = "postgres_code";
  static const postgres_constraintName = "postgres_constraintName";
  static const postgres_detail = "postgres_detail";
  static const postgres_tableName = "postgres_tableName";

  static const error_object = "error_object";
}

class ErrorCodes {
  // Generic
  static const UnknownError = "UnknownError";
  static const UnknownPostgresError = "UnknownPostgresError";

  // Rogue clients
  static const InvalidRequest = "InvalidRequest";
  static const InvalidRequestFormat = "InvalidRequestFormat";
  static const UnknownRequestCode = "UnknownRequestCode";

  // Client errors
  static const UsernameTaken = "UsernameTaken";
  static const InvalidNewPassword = "InvalidNewPassword";
  static const WrongUsername = "WrongUsername";
  static const WrongPassword = "WrongPassword";
  static const InvalidUid = "InvalidUid";

  // Server errors
  static const DBAuthFailure = "DBAuthFailure";
  static const MultipleUsersFound = "MultipleUsersFound";
  static const UuidGenerationFailure = "UuidGenerationFailure";
  static const InvalidDatabaseStructure = "InvalidDatabaseStructure";
  static const ProjectCreationFailure = "ProjectCreationFailure";
}