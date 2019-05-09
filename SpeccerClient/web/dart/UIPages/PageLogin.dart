
part of '../UIPage.dart';

class PageLogin extends UIPage {
  Form _form;
  TextInputElement _username;
  PasswordInputElement _password;

  bool _passwordsValid;
  bool _usernameValid;
  DivElement _submit;

  int _invalidLoginFromServer = 0;

  PageLogin(UIManagerInteractionInterface uimii) :
        super(uimii, true, true, false, "Login", "login") {

    _username = new TextInputElement();
    _username.onInput.listen(_inputOnInput);
    _username.required = true;

    _password = new PasswordInputElement();
    _password.onInput.listen(_inputOnInput);
    _password.required = true;

    _submit = new DivElement();
    _submit.onClick.listen((_) {
      bool enabled = _usernameValid && _passwordsValid;

      if(enabled) {
        _uimii.getDBClient().makeRequest(new RequestLogin(_username.value, _password.value));
      }
    });

    _submit.setInnerHtml("Login");
    _submit.classes.add(CSSClasses.clickable);
    _submit.classes.add(CSSClasses.button);

    _form = new Form();
    _form.addInputViaString("Username:", _username);
    _form.addInputViaString("Password:", _password);
    _form.addRow([_submit]).cells.first
      ..colSpan = 2
      ..style.textAlign = "center";

    reset();
    _updateSubmitButton(null);
    _content.append(_form.getElement());
  }

  void _inputOnInput(_) {
    if(_invalidLoginFromServer > 0) {
      _invalidLoginFromServer--;
    }

    _usernameValid = _username.checkValidity() && _invalidLoginFromServer == 0;
    _passwordsValid = _password.checkValidity() && _invalidLoginFromServer == 0;
    _password.setAttribute("error", _passwordsValid ? "false" : "true");
    _username.setAttribute("error", _usernameValid ? "false" : "true");
    _updateSubmitButton(_);
  }

  void _updateSubmitButton(_) {
    bool enabled = _usernameValid && _passwordsValid;
    _submit.setAttribute("disabled", (enabled ? "false" : "true"));
  }

  void invalidLogin() {
    _invalidLoginFromServer = 2;
    _inputOnInput(null);
  }

  void reset() {
    _username.value = "";
    _password.value = "";
    _usernameValid = false;
    _passwordsValid = false;
    _invalidLoginFromServer = 0;
    _password.setAttribute("error", "false");
    _username.setAttribute("error", "false");
    _updateSubmitButton(null);
  }
}