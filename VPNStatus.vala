using AppIndicator;

public class Main {
  class VPNStatus : Gtk.Application {
    private const string INDICATOR_ENCRYPTED_ICON_PATH = "/usr/share/icons/vpn-status/vpn-encrypted.svg";
    private const string INDICATOR_UNENCRYPTED_ICON_PATH = "/usr/share/icons/vpn-status/vpn-unencrypted.svg";
    private const string NOTIFICATION_ICON_PATH = "network-vpn";

    private GLib.Notification notification;
    private AppIndicator.Indicator indicator;
    private bool? previouslyConnected;
    private bool exiting = false;

    public VPNStatus () {
      Object (application_id: "org.vos.vpn-status");
      set_inactivity_timeout (10000);
    }

    public override void activate () {
      initializeNotification ();
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
          if (exiting) {
            stdout.puts ("exiting\n");
            return Source.REMOVE;
          }
          return Source.CONTINUE;
        },
        Priority.LOW
      );
    }

    private void initializeNotification () {
      notification = new Notification ("VPN Status");
      var icon = new ThemedIcon (NOTIFICATION_ICON_PATH);
      notification.set_icon (icon);
    }

    private void initializeIndicator () {
      indicator = new AppIndicator.Indicator ("VPN Status", INDICATOR_ENCRYPTED_ICON_PATH, AppIndicator.IndicatorCategory.SYSTEM_SERVICES);
      indicator.set_status (AppIndicator.IndicatorStatus.ACTIVE);

      indicator.set_status (IndicatorStatus.ACTIVE);

      var menu = new Gtk.Menu ();

      var item = new Gtk.MenuItem.with_label ("Exit");
      item.activate.connect (() => {
          exiting = true;
          indicator.set_status (IndicatorStatus.PASSIVE);
          Gtk.main_quit ();
      });
      item.show ();
      menu.append (item);

      indicator.set_menu (menu);
    }

    private void checkVPNStatus () {
      bool currentlyConnected = getVPNStatus ();

      printVPNStatus(currentlyConnected);
      notifyVPNStatus (currentlyConnected);
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

    private void notifyVPNStatus (bool connected) {
      if (previouslyConnected == null || previouslyConnected == connected) {
        return;
      }

      if (connected) {
        notification.set_body ("connected");
      } else {
        notification.set_body ("disconnected");
      }
      send_notification ("vpn-status", notification);
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
  }

  public static int main (string[] args) {
    Gtk.init (ref args);
    Application application = new VPNStatus ();
    int status = application.run (args);
    return status;
  }
}
