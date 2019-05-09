import 'dart/DBClient.dart';
import 'dart:html';
import 'dart:async';
import 'dart/UIManager.dart';
import 'dart/config.dart';

void main() {
  // The entire project is run wrapped in a "zone" to catch asynchronous
  // exceptions. Upon exception, the user will be displayed an error message.
  bool showingError = false;
  runZoned(() {
//    window.localStorage["disableAutosave"] = JSON.encode(false);
//    bool playOnly = (Uri.base.queryParameters.containsKey("mode") &&
//        Uri.base.queryParameters["mode"] == "play");

    print("Dart running.");
    initCoaop();
    new UIManager(new DBClient());

    // By this point, everything is loaded, and we can remove the loading
    // screen and reset the cursor to default.
//    querySelector("#loading").remove();
//    document.body.style.cursor = "";
  }, onError: (e, stackTrace) {
    // An error occurred somewhere on some thread. This error is a developer
    // issue, not a user error.

    // Don't re-show the error window if it is already being displayed.
    if (showingError) return;

    showingError = true;

    // Log the error to the console for developer's to get the information.
    print(e);
    print(stackTrace);

    // Create the user shown error dialog.
    DivElement errorDiv = new DivElement();
    DivElement backgroundDiv = new DivElement();
    DivElement errorDialog = new DivElement();
    ButtonElement continueButton = new ButtonElement();
    DivElement errorText = new DivElement();

    errorDiv.style.position = "absolute";
    errorDiv.style.border = "5px solid #c40000";
    errorDiv.style.width = "calc(100% - 10px)";
    errorDiv.style.height = "calc(100% - 10px)";
    errorDiv.style.left = "0";
    errorDiv.style.top = "0";

    backgroundDiv.style.position = "absolute";
    backgroundDiv.style.width = "100%";
    backgroundDiv.style.height = "100%";
    backgroundDiv.style.left = "0";
    backgroundDiv.style.top = "0";
    backgroundDiv.style.backgroundColor = "rgba(0, 0, 0, 0.5)";

    errorDialog.style.position = "absolute";
    errorDialog.style.border = "5px white solid";
    errorDialog.style.padding = "5px";
    errorDialog.style.backgroundColor = "#c40000";

    // This is the primary message shown to the user.
    errorText.setInnerHtml("<b>Speccer has encountered an exception.<br></b>" +
        "While Speccer is <b>still in development</b>, errors like this are not expected in production code.<br>" +
        "You may attempt to continue using Speccer if you wish, but it is not recommended to continue working.<br>" +
        "Please check the console logs and report your problem to the developers.<br>" +
        "Exception: <pre>${e}</pre>");
    errorText.style.backgroundColor = "#c40000";
    errorText.style.color = "white";

    continueButton.setInnerHtml("<b>Ignore Error and Continue Working</b>");
    continueButton.style.backgroundColor = "white";
    continueButton.style.padding = "5px 20px";
    continueButton.style.color = "red";

    // If the user chooses to continue, auto-save will still be disabled, but
    // they can continue working on what remains. Depending on the exception,
    // the entire project, or just one part, may be broken.
    continueButton.onClick.listen((MouseEvent e) {
      errorText.remove();
      continueButton.remove();
      errorDialog.remove();
      backgroundDiv.remove();
      errorDiv.remove();
      showingError = false;
    });

    errorDialog.append(errorText);
    errorDialog.append(continueButton);
    errorDiv.append(backgroundDiv);
    errorDiv.append(errorDialog);
    document.body.append(errorDiv);
    errorDialog.style.left = "calc((100% - ${errorDialog.offsetWidth}px) / 2)";
    errorDialog.style.top = "calc((100% - ${errorDialog.offsetHeight}px) / 2)";
    continueButton.style.marginLeft = "calc((100% - ${continueButton.offsetWidth}px) / 2)";
  });
}
