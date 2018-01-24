[DBus(name = "org.coanda.Dactl.SinamicsS")]
public class Dactl.SinamicsS.DBusService : GLib.Object {

    private Dactl.SinamicsS.Plugin plugin;

    public signal void speed_sp_new_value (double value);

    construct {
        plugin = Dactl.SinamicsS.Plugin.instance ();
        plugin.speed_sp_new_value.connect ((value) => {
            speed_sp_new_value (value);
        });
    }

    [Version (deprecated = "true")]
    public void enable_plc0_motor0 (bool state) {
        plugin.enable_plc0_motor0 (state);
    }

    [Version (deprecated = "true")]
    public async void set_offset_plc0_motor0 (double value) {
       yield plugin.set_offset_plc0_motor0 (value);
    }

    [Version (deprecated = "true")]
    public async double get_offset_plc0_motor0 () {
       double result = yield plugin.get_offset_plc0_motor0 ();

       return result;
    }

    [Version (deprecated = "true")]
    public void set_speed_plc0_motor0 (double value) {
        plugin.set_speed_plc0_motor0 (value);
    }

    [Version (deprecated = "true")]
    public void trigger () {
        plugin.trigger ();
    }

    [Version (deprecated = "true")]
    public void test () {
        plugin.test ();
    }

    [Version (deprecated = "true")]
    public bool camera_busy () {
        return plugin.camera_busy ();
    }

    [Version (deprecated = "true")]
    public async void mb_connect () {
        try {
            var plc = plugin.get_plc ("plc0");
            plc.mb_connect.begin ();
        } catch (SinamicsS.Error e) {
            critical (e.message);
        }
    }

    [Version (deprecated = "true")]
    public void mb_disconnect () {
        var plc = plugin.get_plc ("plc0");
        plc.mb_disconnect ();
    }

    /**
     * XXX New DBus methods begin here
     */

    public int plc_ping () throws Error {
        try {
            var plc = plugin.get_active_plc ();
            return plc.ping ();
        } catch (Dactl.SinamicsS.Error e) {
            throw e;
        }
    }

    public void plc_connect () throws Error {
        try {
            var plc = plugin.get_active_plc ();
            plc.connect ();
        } catch (Dactl.SinamicsS.Error e) {
            throw e;
        }
    }

    public void plc_disconnect () throws Error {
        try {
            var plc = plugin.get_active_plc ();
            plc.disconnect ();
        } catch (Dactl.SinamicsS.Error e) {
            throw e;
        }
    }

    public bool plc_is_connected () throws Error {
        try {
            var plc = plugin.get_active_plc ();
            return plc.connected;
        } catch (Dactl.SinamicsS.Error e) {
            throw e;
        }
    }

    public string get_active_plc () throws Error {
        try {
            var plc = plugin.get_active_plc ();
            return plc.id;
        } catch (Dactl.SinamicsS.Error e) {
            throw e;
        }
    }

    public void set_active_plc (string id) throws Error {
        try {
            plugin.set_active_plc (id);
        } catch (Dactl.SinamicsS.Error e) {
            throw e;
        }
    }
}
