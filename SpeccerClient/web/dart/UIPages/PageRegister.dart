
part of '../UIPage.dart';

class PageRegister extends UIPage {
  Form _form;
  TextInputElement _username;
  EmailInputElement _email;
  PasswordInputElement _password1;
  PasswordInputElement _password2;

  bool _passwordsValid = false;
  DivElement _submit;

  int _invalidPassFromServer = 0;
  int _invalidUserFromServer = 0;

  PageRegister(UIManagerInteractionInterface uimii) :
        super(uimii, true, true, false, "Register", "register") {

    _username = new TextInputElement();
    _username.onInput.listen(_usernameOnInput);
    _username.required = true;

    _email = new EmailInputElement();
    _email.onInput.listen(_updateSubmitButton);
    _email.required = true;

    _password1 = new PasswordInputElement();
    _password1.required = true;
    _password1.setAttribute("minlength", "8");
    _password1.onInput.listen(_passwordOnInput);

    _password2 = new PasswordInputElement();
    _password2.required = true;
    _password2.setAttribute("minlength", "8");
    _password2.onInput.listen(_passwordOnInput);

    _submit = new DivElement();
    _submit.onClick.listen((_) {
      bool enabled =
          _username.checkValidity() &&
          _email.checkValidity() &&
          _passwordsValid;

      if(enabled) {
        _uimii.getDBClient().makeRequest(new RequestAddUser(_username.value, _password1.value, _email.value));
      }
    });

    _submit.setInnerHtml("Register");
    _submit.classes.add(CSSClasses.clickable);
    _submit.classes.add(CSSClasses.button);

    _form = new Form();
    _form.addInputViaString("Username:", _username);
    _form.addInputViaString("Email:", _email);
    _form.addInputViaString("Password:", _password1);
    _form.addInputViaString("Password Again:", _password2);
    _form.addRow([_submit]).cells.first
      ..colSpan = 2
      ..style.textAlign = "center";

    _updateSubmitButton(null);

    _content.append(_form.getElement());
  }

  void _passwordOnInput(_) {
    if(_invalidPassFromServer > 0) {
      _invalidPassFromServer--;
    }

    _passwordsValid =
        _password1.value == _password2.value &&
        _password1.checkValidity() &&
        _password2.checkValidity() &&
        _invalidPassFromServer == 0;
    _password1.setAttribute("error", _passwordsValid ? "false" : "true");
    _password2.setAttribute("error", _passwordsValid ? "false" : "true");
    _updateSubmitButton(_);
  }

  void _usernameOnInput(_) {
    if(_invalidUserFromServer > 0) {
      _invalidUserFromServer--;
    }

    _username.setAttribute("error", _invalidUserFromServer > 0 ? "true" : "false");
    _updateSubmitButton(_);
  }

  void _updateSubmitButton(_) {
    bool enabled =
        _username.checkValidity() &&
        _email.checkValidity() &&
        _passwordsValid;

    _submit.setAttribute("disabled", (enabled ? "false" : "true"));
  }

  void invalidPassword() {
    _invalidPassFromServer = 2;
    _passwordOnInput(null);
  }

  void usernameTaken() {
    _invalidUserFromServer = 2;
    _usernameOnInput(null);
  }

  void reset() {
    _username.value = "";
    _password1.value = "";
    _password2.value = "";
    _email.value = "";
  }
}