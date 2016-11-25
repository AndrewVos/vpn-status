public class Main {
  class VPNStatus : Application {
    private GLib.Notification notification;
    private bool? previouslyConnected;

    public VPNStatus() {
      Object (application_id: "org.vos.vpn-status");
      set_inactivity_timeout (10000);
    }

    public override void activate () {
      this.hold ();
      notification = new Notification ("VPN Status");
      var icon = new ThemedIcon ("network-vpn");
      notification.set_icon (icon);

      checkVPNStatus();

      Timeout.add_seconds (
        5,
        () => {
          checkVPNStatus ();
          return Source.CONTINUE;
        },
        Priority.LOW
      );
    }

    private void checkVPNStatus () {
      bool currentlyConnected = getVPNStatus ();

      printVPNStatus(currentlyConnected);
      if (previouslyConnected != null && previouslyConnected != currentlyConnected) {
        notifyVPNStatus(currentlyConnected);
      }
      previouslyConnected = currentlyConnected;
    }

    private bool getVPNStatus () {
      int status;
      string out;
      string err;

      try {
        Process.spawn_command_line_sync("/sbin/ifconfig tun0", out out, out err , out status);
      } catch (SpawnError e) {
        stdout.printf ("Error: %s\n", e.message);
        return false;
      }

      return status == 0;
    }

    private void printVPNStatus(bool connected) {
      stdout.puts ("VPN status: ");
      if (connected) {
        stdout.puts ("connected");
      } else {
        stdout.puts ("disconnected");
      }
      stdout.puts ("\n");
    }

    private void notifyVPNStatus (bool connected) {
      if (connected) {
        notification.set_body ("connected");
      } else {
        notification.set_body ("disconnected");
      }
      send_notification ("vpn-status", notification);
    }
  }

  public static int main (string[] args) {
    Application application = new VPNStatus ();
    int status = application.run (args);
    return status;
  }
}
