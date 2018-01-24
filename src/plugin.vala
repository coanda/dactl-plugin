using Log;

public void module_init (Dactl.PluginLoader loader) {
    try {
        var plugin = Dactl.SinamicsS.Plugin.instance ();
        plugin.active = true;
        loader.add_plugin (plugin);
    } catch (Error error) {
        warning ("Failed to load %s: %s",
                 Dactl.SinamicsS.Plugin.NAME,
                 error.message);
    }
}

public class Dactl.SinamicsS.Plugin : Dactl.Plugin {

    public const string NAME = "sinamics_s";

    private static GLib.Once<Plugin> _instance;

    private Gee.Map<string, Plc> plc_list;
    private string active_plc = "";

    private SimpleAction enable_action;
    private SimpleAction set_speed_action;
    private const GLib.ActionEntry[] action_entries = {
        /*{ "enable", null, "(bs)", "false", enable_changed_state_cb },*/
        { "test",   test_activated_cb,   null, null, null }
    };

    public Context log { get; private set; }

    /* FIXME this should be a connected variable in the PLC object */
    public bool plc_connected { get; private set; default = false; }
    public GLib.SimpleActionGroup action_group { get; private set; }

    private bool _has_factory = true;
    public override bool has_factory {
        get { return _has_factory; }
    }

    public signal void speed_sp_new_value (double value);
    public signal void plc_changed (Plc plc);

    construct {
        log = new Context ();
        log.init ("SinamicS");
        log.set_verbosity (Level.DEBUG);

        plc_list = new Gee.HashMap<string, Plc> ();

        action_group = new GLib.SimpleActionGroup ();

        enable_action = new SimpleAction.stateful ("enable", null, new Variant.boolean (false));
        enable_action.change_state.connect (enable_changed_state_cb);
        action_group.add_action (enable_action);

        set_speed_action = new SimpleAction ("set-speed", new VariantType ("d"));
        set_speed_action.activate.connect (set_speed_cb);
        action_group.add_action (set_speed_action);

        action_group.add_action_entries (action_entries, this);
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
        factory = new Dactl.SinamicsS.Factory ();

        Bus.own_name (BusType.SESSION,
                      "org.coanda.Dactl.SinamicsS",
                      BusNameOwnerFlags.NONE,
                      bus_acquired_cb,
                      () => {},
                      () => { log.critical ("Could not acquire name\n"); });
    }

    public void bus_acquired_cb (DBusConnection connection) {
        try {
			var dbus = new Dactl.SinamicsS.DBusService ();
            connection.register_object ("/org/coanda/dactl/sinamics_s", dbus);
        } catch (IOError e) {
            warning ("Could not register service: %s", e.message);
        }
    }

    /* XXX This only works for plc0, motor 0 */
    private void enable_changed_state_cb (SimpleAction action, Variant? value) {
        var state = value.get_boolean ();
        var plc = get_plc ("plc0");

        plc.enable.begin (0, state);
        action.set_state (new Variant.boolean (state));

        if (state) {
            log.debug ("change state - true\n");
        } else {
            log.debug ("change state - false\n");
        }
    }

    private void test_activated_cb (SimpleAction action, Variant? parameter) {
        log.debug ("test\n");
    }

    /* XXX This only works for plc 0, motor 0 */
    private void set_speed_cb (SimpleAction action, Variant? parameter) {
        log.debug ("Set speed: %.3f\n", (double) parameter);

        var plc = get_plc ("plc0");
        var motor = plc.get_motor (0);

        try {
            plc.set_speed_sp.begin (0, (double) parameter);
            // FIXME This is redundant but neccessary for now
            motor.speed_setpoint = (double) parameter;
            speed_sp_new_value ((double) parameter);
        } catch (Error e) {
            log.critical (e.message);
        }
    }

    /*
     *public void speed_enable (bool state) {
     *    action_group.change_action_state ("enable", new Variant.boolean (state));
     *}
     */

    public void test () {
        action_group.activate_action ("test", null);
    }

    public void add_plc (Dactl.SinamicsS.Plc plc) {
        plc_list.set (plc.id, plc);
    }

    public Dactl.SinamicsS.Plc? get_plc (string id) {
        if (plc_list.has_key (id)) {
            return plc_list.get (id);
        }
        return null;
    }

    [Version (deprecated = "true")]
    public void enable_plc0_motor0 (bool state) {
        action_group.change_action_state ("enable", new Variant.boolean (state));
    }

    [Version (deprecated = "true")]
    public async void set_offset_plc0_motor0 (double value) {
        var plc = get_plc ("plc0");
        yield plc.set_offset (0, value);
    }

    [Version (deprecated = "true")]
    public async double get_offset_plc0_motor0 () {
        var plc = get_plc ("plc0");
        double result = yield plc.get_offset (0);

        return result;
    }

    [Version (deprecated = "true")]
    public void set_speed_plc0_motor0 (double value) {
        action_group.activate_action ("set-speed", value);
    }

    public void trigger () {
        var plc = get_plc ("plc0");
        plc.trigger ();
    }

    public bool camera_busy () {
        var plc = get_plc ("plc0");
        return plc.camera_busy ();
    }

    public void set_active_plc (string id) throws Error {
        if (plc_list.has_key (id)) {
            log.debug ("Setting active PLC to %s\n", id);
            active_plc = id;
            plc_changed (get_active_plc ());
        } else {
            throw new Dactl.SinamicsS.Error.NO_ACTIVE_PLC (
                "An invalid selection was given to set an active PLC");
        }
    }

    public Dactl.SinamicsS.Plc get_active_plc () throws Error {
        if (active_plc == "") {
            throw new Dactl.SinamicsS.Error.NO_ACTIVE_PLC (
                "No selection was made to set an active PLC");
        }

        return get_plc (active_plc);
    }
}
