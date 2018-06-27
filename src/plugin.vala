public void module_init (Dactl.PluginLoader loader) {
    var plugin = Dactl.PluginTemplate.Plugin.instance ();
    plugin.active = true;
    loader.add_plugin (plugin);
}

public class Dactl.PluginTemplate.Plugin : Dactl.Plugin {

    private static GLib.Once<Plugin> _instance;
    private bool _has_factory = true;

    public const string NAME = "plugin_template";
    public override bool has_factory {
        get { return _has_factory; }
    }

    /**
     * @return a singleton
     */
    public static unowned Plugin instance () {
        return _instance.once (() => { return new Plugin (); });
    }

    /**
     * Instantiate the plugin.
     */
    public Plugin () {
        // Call the base constructor,
        base (NAME, null, null, Dactl.PluginCapabilities.CLD_OBJECT);
        factory = new Dactl.PluginTemplate.Factory ();

        Bus.own_name (BusType.SESSION,
                      "org.coanda.Dactl.PluginTemplate",
                      BusNameOwnerFlags.NONE,
                      bus_acquired_cb,
                      () => {},
                      () => { critical ("Could not acquire name\n"); });
    }

    public void bus_acquired_cb (DBusConnection connection) {
        try {
			var dbus = new Dactl.PluginTemplate.DBusService ();
            connection.register_object ("/org/coanda/dactl/plugin_template", dbus);
        } catch (IOError e) {
            warning ("Could not register service: %s", e.message);
        }
    }

    public string say_hello () {
        return "Hello World!";
    }

    public void throw_error () throws Error {
        throw new Dactl.PluginTemplate.Error.SOME_ERROR ("Error: Something bad just happened!");
    }
}
