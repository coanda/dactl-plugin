namespace Dactl.PluginTemplate {
    [CCode (cheader_filename = "plugin-config.h", cprefix = "PLUGIN_")]
    public extern const string NAME;

    [CCode (cheader_filename = "plugin-config.h", cprefix = "PLUGIN_")]
    public extern const string VERSION;

    [CCode (cheader_filename = "plugin-config.h", cprefix = "PLUGIN_")]
    public extern const string STRING;

    [CCode (cheader_filename = "plugin-config.h", cprefix = "PLUGIN_")]
    public extern const string URL;

    [CCode (cheader_filename = "plugin-config.h", cprefix = "PLUGIN_")]
    public extern const string GETTEXT_PACKAGE;
}
