[DBus (name = "org.coanda.Dactl.SinamicsS")]
public interface Service : Object {
    /* PLC methods */
    public abstract int plc_ping () throws Error;
    public abstract void plc_connect () throws Error;
    public abstract void plc_disconnect () throws Error;
    public abstract bool plc_is_connected () throws Error;

    /* getters & setters */
    public abstract void set_active_plc (string id) throws Error;
    public abstract string get_active_plc () throws Error;
}

public int main (string[] args) {
    Test.init (ref args);

    Service dbus = null;
    int ret = -1;

    Test.add_data_func ("/dbus/active-plc", () => {
        try {
            dbus.set_active_plc ("plc0");
            assert (dbus.get_active_plc () == "plc0");
        } catch (Error e) {
            assert_not_reached ();
        }
    });

    Test.add_data_func ("/dbus/plc/ping", () => {
        try {
            int latency = dbus.plc_ping ();
            assert (latency > 0);
        } catch (Error e) {
            assert_not_reached ();
        }
    });

    Test.add_data_func ("/dbus/plc/connect", () => {
        try {
            dbus.plc_connect ();
            assert (dbus.plc_is_connected () == true);
        } catch (Error e) {
            assert_not_reached ();
        }
    });

    Test.add_data_func ("/dbus/plc/disconnect", () => {
        try {
            dbus.plc_disconnect ();
            assert (dbus.plc_is_connected () == false);
        } catch (Error e) {
            assert_not_reached ();
        }
    });

    try {
        string[] spawn_args = { "dactl", "-f", "data/config/dactl.xml" };
		string[] spawn_env = Environ.get ();
        Pid child_pid;

		Process.spawn_async (".",
                             spawn_args,
                             spawn_env,
                             SpawnFlags.SEARCH_PATH | SpawnFlags.DO_NOT_REAP_CHILD,
                             null,
                             out child_pid);

        dbus = Bus.get_proxy_sync (BusType.SESSION,
                                   "org.coanda.Dactl.SinamicsS",
                                   "/org/coanda/dactl/sinamics_s");

        ChildWatch.add (child_pid, (pid, status) => {
			Process.close_pid (pid);
		});

		ret = Test.run ();
    } catch (SpawnError e) {
        assert_not_reached ();
    } catch (IOError e) {
        assert_not_reached ();
    }

    return ret;
}
