[DBus(name = "org.coanda.Dactl.PluginTemplate")]
public class Dactl.PluginTemplate.DBusService : GLib.Object {

    private Dactl.PluginTemplate.Plugin plugin;


    construct {
        plugin = Dactl.PluginTemplate.Plugin.instance ();
    }

    public string say_hello () {
        return plugin.say_hello ();
    }

    public void throw_error () throws Error {
        try {
            plugin.throw_error ();
        } catch (Dactl.PluginTemplate.Error e) {
            throw e;
        }
    }
}
