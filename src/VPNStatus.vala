using AppIndicator;

public class Main {
  class VPNStatus : Gtk.Application {
    private const string INDICATOR_ENCRYPTED_ICON_PATH = "/usr/share/icons/vpn-status/vpn-encrypted.svg";
    private const string INDICATOR_UNENCRYPTED_ICON_PATH = "/usr/share/icons/vpn-status/vpn-unencrypted.svg";
    private AppIndicator.Indicator indicator;
    private bool? previouslyConnected;

    public VPNStatus () {
      Object (application_id: "org.vos.vpn-status");
      set_inactivity_timeout (10000);
    }

    public override void activate () {
      initializeIndicator ();
      constantlyCheckVPNStatus ();
      Gtk.main ();
    }

    private void constantlyCheckVPNStatus () {
      checkVPNStatus ();

      Timeout.add_seconds (
        5,
        () => {
          checkVPNStatus ();
          return Source.CONTINUE;
        },
        Priority.LOW
      );
    }

    private void initializeIndicator () {
      indicator = new AppIndicator.Indicator ("VPN Status", INDICATOR_ENCRYPTED_ICON_PATH, AppIndicator.IndicatorCategory.SYSTEM_SERVICES);
      indicator.set_status (AppIndicator.IndicatorStatus.ACTIVE);

      indicator.set_status (IndicatorStatus.ACTIVE);

      var menu = new Gtk.Menu ();

      var item = new Gtk.MenuItem.with_label ("Network Settings...");
      item.activate.connect (() => {
          showSettings ();
      });
      item.show ();
      menu.append (item);

      indicator.set_menu (menu);
    }

    private void checkVPNStatus () {
      bool currentlyConnected = getVPNStatus ();

      printVPNStatus(currentlyConnected);
      updateIndicator (currentlyConnected);
      previouslyConnected = currentlyConnected;
    }

    private bool getVPNStatus () {
      int status;
      string out;
      string err;

      try {
        Process.spawn_command_line_sync ("/sbin/ifconfig tun0", out out, out err , out status);
      } catch (SpawnError e) {
        stdout.printf ("Error: %s\n", e.message);
        return false;
      }

      return status == 0;
    }

    private void printVPNStatus (bool connected) {
      stdout.puts ("VPN status: ");
      if (connected) {
        stdout.puts ("connected");
      } else {
        stdout.puts ("disconnected");
      }
      stdout.puts ("\n");
    }

    private void updateIndicator (bool connected) {
      if (previouslyConnected == connected) {
        return;
      }

      if (connected) {
        indicator.set_icon(INDICATOR_ENCRYPTED_ICON_PATH);
      } else {
        indicator.set_icon(INDICATOR_UNENCRYPTED_ICON_PATH);
      }
    }

    bool is_dm () {
      return Environment.get_user_name () == SettingsManager.get_default ().desktopmanager_user;
    }

    private void showSettings () {
      if (!is_dm ()) {
        var list = new List<string> ();
        list.append ("network");

        try {
          var appinfo = AppInfo.create_from_commandline ("switchboard", null, AppInfoCreateFlags.SUPPORTS_URIS);
          appinfo.launch_uris (list, null);
        } catch (Error e) {
          warning ("%s\n", e.message);
        }
      }
    }
  }

  public static int main (string[] args) {
    Gtk.init (ref args);
    Application application = new VPNStatus ();
    int status = application.run (args);
    return status;
  }
}
