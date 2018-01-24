/**
 * Plugin UI factory to build objects from configuration data.
 */
public class Dactl.SinamicsS.Factory : GLib.Object, Dactl.Factory {

    construct {
    }

    /**
     * {@inheritDoc}
     */
    public Gee.TreeMap<string, Dactl.Object> make_object_map (Xml.Node *node) {
        var objects = new Gee.TreeMap<string, Dactl.Object> ();
        for (Xml.Node *iter = node; iter != null; iter = iter->next) {
            try {
                var object = make_object_from_node (iter);
                if (object != null) {
                    objects.set (object.id, object);
                    message ("Loading object of type `%s' with id `%s'",
                            iter->get_prop ("type"), object.id);
                }
            } catch (GLib.Error e) {
                critical (e.message);
            }
        }
        build_complete ();

        return objects;
    }

    /**
     * {@inheritDoc}
     */
    public Dactl.Object make_object (Type type)
                                     throws GLib.Error {
        Dactl.Object object = null;

        switch (type.name ()) {
            case "DactlSinamicsSControl":
                break;
            default:
                throw new Dactl.FactoryError.TYPE_NOT_FOUND (
                    "The type requested is not a known Dactl type");
        }

        return object;
    }

    /**
     * {@inheritDoc}
     */
    public Dactl.Object make_object_from_node (Xml.Node *node)
                                               throws GLib.Error {
        Dactl.Object object = null;

        if (node->type == Xml.ElementType.ELEMENT_NODE &&
            node->type != Xml.ElementType.COMMENT_NODE) {
            if (node->name == "object") {
                var type = node->get_prop ("type");
                message ("Attempting to construct a plugin control of type `%s'", type);
                switch (type) {
                    case "plugin-control":
                        var subtype = node->get_prop ("subtype");
                        switch (subtype) {
                            case "speed":
                                return make_sinamics_s_speed_control (node);
                            case "enable":
                                return make_sinamics_s_enable_control (node);
                            case "plc":
                                return make_sinamics_s_plc_control (node);
                            default:
                                throw new Dactl.FactoryError.TYPE_NOT_FOUND (
                                    "The type requested is not a known Dactl type");
                        }
                    case "plc":
                        var plc = make_sinamics_s_plc (node);
                        var plugin = Dactl.SinamicsS.Plugin.instance ();
                        plugin.add_plc (plc as Dactl.SinamicsS.Plc);
                        return plc;
                    default:
                        throw new Dactl.FactoryError.TYPE_NOT_FOUND (
                            "The type requested is not a known Dactl type");
                }
            }
        }

        return object;
    }

    private Dactl.Object make_sinamics_s_enable_control (Xml.Node *node) {
        return new Dactl.SinamicsS.EnableControl.from_xml_node (node);
    }

    private Dactl.Object make_sinamics_s_speed_control (Xml.Node *node) {
        return new Dactl.SinamicsS.SpeedControl.from_xml_node (node);
    }

    private Dactl.Object make_sinamics_s_plc_control (Xml.Node *node) {
        return new Dactl.SinamicsS.PlcControl.from_xml_node (node);
    }

    private Dactl.Object make_sinamics_s_plc (Xml.Node *node) {
        return new Dactl.SinamicsS.Plc.from_xml_node (node);
    }
}
