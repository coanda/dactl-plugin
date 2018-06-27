[DBus (name = "org.coanda.Dactl.PluginTemplate")]
public interface Service : Object {
    /* methods */
    public abstract string say_hello ();
    public abstract void throw_error () throws Error;
}

public int main (string[] args) {
    Test.init (ref args);

    Service dbus = null;
    int ret = -1;

    Test.add_data_func ("/dbus/say-hello", () => {
        try {
            assert (dbus.say_hello () == "Hello World!");
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
                                   "org.coanda.Dactl.PluginTemplate",
                                   "/org/coanda/dactl/plugin_template");

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
