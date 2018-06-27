[GtkTemplate (ui = "/org/coanda/dactl/plugins/plugin-template/ui/control.ui")]
public class Dactl.PluginTemplate.Control : Dactl.SimpleWidget, Dactl.PluginControl {

    /* XML/XSD variables are useless for now */
    private string _xml = """
    """;

    private string _xsd = """
    """;

    private string some_property;

    [GtkChild]
    private Gtk.Label lbl_test;

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

    private Dactl.PluginTemplate.Plugin plugin;

    construct {
        id = "plugin-template-ctl0";
        plugin = Dactl.PluginTemplate.Plugin.instance ();

        var adj = scrolled_window.get_vadjustment ();
        adj.changed.connect (()=> {
            adj.set_value (adj.get_upper ());
        });
    }

    public Control.from_xml_node (Xml.Node *node) {
        build_from_xml_node (node);
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
                    case "some-property":
                        some_property = iter->get_content ();
                        break;
                    default:
                        break;
                }

                message (" > Adding %s to %s\n", iter->get_content (), id);
            }
        }
    }

    /**
     * {@inheritDoc}
     *
     * FIXME: currently has no configurable property nodes or attributes
     */
    protected override void update_node () {
    }

    [GtkCallback]
    private void btn_test_clicked_cb () {
        lbl_test.label += "click\t";
    }
}
