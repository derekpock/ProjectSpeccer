
part of '../UIPage.dart';

class PageRegister extends UIPage {
  Form _form;
  TextInputElement _username;
  EmailInputElement _email;
  PasswordInputElement _password1;
  PasswordInputElement _password2;

  bool _passwordsValid;
  DivElement _submit;

  PageRegister(UIManagerInteractionInterface uimii) :
        super(uimii, true, "Register") {

    _username = new TextInputElement();
    _username.onInput.listen(_updateSubmitButton);
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
          _password1.checkValidity() &&
          _password2.checkValidity() &&
          _passwordsValid;

      if(enabled) {
        new Request({
          "~": "adduser",
          "username": _username.value,
          "password": _password1.value,
          "email": _email.value
        }, (Map<String, dynamic> data) {

        });
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

    _content.append(_form.getElement());
  }

  void _passwordOnInput(_) {
    _passwordsValid = _password1.value == _password2.value;
    _updateSubmitButton(_);
  }
  
  void _updateSubmitButton(_) {
    bool enabled =
        _username.checkValidity() &&
        _email.checkValidity() &&
        _password1.checkValidity() &&
        _password2.checkValidity() &&
        _passwordsValid;

    _submit.setAttribute("disabled", (enabled ? "false" : "true"));
  }
}