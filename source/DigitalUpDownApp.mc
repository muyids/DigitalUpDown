import Toybox.Application;
import Toybox.Lang;
using Toybox.WatchUi as Ui;
using Toybox.Application.Properties as Prop;

class DigitalUpDownApp extends Application.AppBase {

    var mView;

    function initialize() {
        AppBase.initialize();
    }

    // onStart() is called on application start up
    function onStart(state as Dictionary?) as Void {
    }

    // onStop() is called when your application is exiting
    function onStop(state as Dictionary?) as Void {
    }

    // Return the initial view of your application here
    function getInitialView() as Array<Ui.Views or Ui.InputDelegates>? {
        mView = new DigitalUpDownView();
        onSettingsChanged(); // After creating view.
        return [ mView ] as Array<Ui.Views or Ui.InputDelegates>;
    }


	// New app settings have been received so trigger a UI update
	function onSettingsChanged() {

		mView.onSettingsChanged(); // Calls checkPendingWebRequests().

		Ui.requestUpdate();
	}


}

function getApp() as DigitalUpDownApp {
    return Application.getApp() as DigitalUpDownApp;
}