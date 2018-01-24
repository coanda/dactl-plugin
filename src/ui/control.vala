using Log;

[GtkTemplate (ui = "/org/coanda/dactl/plugins/sinamics-s/ui/plc-control.ui")]
public class Dactl.SinamicsS.PlcControl : Dactl.SimpleWidget, Dactl.PluginControl {

    /* XML/XSD variables are useless for now */
    private string _xml = """
    """;

    private string _xsd = """
    """;

    [GtkChild]
    private Gtk.ToggleButton btn_connect;

    [GtkChild]
    private Gtk.Image img_connect;

    [GtkChild]
    private Gtk.TextBuffer textbuffer;

    [GtkChild]
    private Gtk.CheckButton btn_busy;

    [GtkChild]
    private Gtk.CheckButton btn_error;

    [GtkChild]
    private Gtk.ScrolledWindow scrolled_window;

    /**
     * {@inheritDoc}
     */
    protected override string xml {
        get { return _xml; }
    }

    /**
     * {@inheritDoc}
     */
    protected override string xsd {
        get { return _xsd; }
    }

    public virtual string parent_ref { get; set; }

    /**
     * {@inheritDoc}
     */
    protected bool satisfied { get; set; default = false; }

    private Dactl.SinamicsS.Plugin plugin;
    private string plc_ref;
    private Plc plc;
    private Context log;

    construct {
        id = "sinamics-s-ctl0";
        plugin = Dactl.SinamicsS.Plugin.instance ();
        log = plugin.log;

        plugin.plc_changed.connect ((plc) => {
            this.plc = plc;
            log.debug ("PLC change to %s seen by control\n", plc.id);
            /* TODO connect/disconnect to the connected flag in the PLC object */
        });

        var adj = scrolled_window.get_vadjustment ();
        adj.changed.connect (()=> {
            adj.set_value (adj.get_upper ());
        });
    }

    public PlcControl.from_xml_node (Xml.Node *node) {
        build_from_xml_node (node);
        find_plc.begin ();
    }

    /**
     * {@inheritDoc}
     */
    public override void build_from_xml_node (Xml.Node *node) {
        id = node->get_prop ("id");
        parent_ref = node->get_prop ("parent");
        message ("Building `%s' with parent `%s'", id, parent_ref);

        for (Xml.Node *iter = node->children; iter != null; iter = iter->next) {
            if (iter->name == "property") {
                switch (iter->get_prop ("name")) {
                    case "plc-ref":
                        plc_ref = iter->get_content ();
                        break;
                    default:
                        break;
                }

                log.message (" > Adding %s to %s\n", iter->get_content (), id);
            }
        }
    }

    private async void find_plc () {
        while (plc == null) {
            plc = plugin.get_plc (plc_ref);
            yield nap (1000);
        }

        plc.status.connect ((message) => {
            Gtk.TextIter iter;
            textbuffer.get_end_iter (out iter);
            textbuffer.insert (ref iter, message+"\n", -1);
        });

        plc.notify["busy"].connect (() => {
            btn_busy.set_active (plc.busy);
        });

        plc.notify["error"].connect (() => {
            btn_error.set_active (plc.error);
        });
    }

    /**
     * {@inheritDoc}
     *
     * FIXME: currently has no configurable property nodes or attributes
     */
    protected override void update_node () {
        /*
         *for (Xml.Node *iter = node->children; iter != null; iter = iter->next) {
         *    if (iter->name == "property") {
         *        switch (iter->get_prop ("name")) {
         *            case "---":
         *                iter->set_content (---);
         *                break;
         *            default:
         *                break;
         *        }
         *    }
         *}
         */
    }

    [GtkCallback]
    private void btn_connect_toggled_cb () {
        if (btn_connect.active) {
            try {
                plc.mb_connect.begin ();
                img_connect.set_from_stock ("gtk-disconnect", Gtk.IconSize.BUTTON);
                btn_connect.label = "Disconnect";
            } catch (Error e) {
                if (e is Error.CONNECTION_FAILED) {
                    log.critical (e.message);
                    btn_connect.set_active (false);
                }
            }
        } else {
            plc.mb_disconnect ();
            img_connect.set_from_stock ("gtk-connect", Gtk.IconSize.BUTTON);
            btn_connect.label = "Connect";
        }
    }
}
