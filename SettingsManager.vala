public class SettingsManager : Granite.Services.Settings {
    private static SettingsManager? instance = null;

    public string desktopmanager_user {protected set; get;}

    public SettingsManager () {
        base ("org.pantheon.desktop.wingpanel.indicators.network");
    }

    public static SettingsManager get_default () {
        if (instance == null)
            instance = new SettingsManager ();

        return instance;
    }
}
