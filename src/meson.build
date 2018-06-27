subdir('config')

plugin_resources = gnome.compile_resources(plugin_name + '-resources',
  plugin_name + '.gresource.xml',
  c_name: plugin_c_name,
)

plugin_vala_args = [
  '--vapidir', dir_libconfig,
  '--pkg', 'plugin-config',
]

plugin_c_args = [
  '-DG_LOG_DOMAIN="@0@"'.format(plugin_name),
  '-DGETTEXT_PACKAGE=@0@'.format(plugin_name),
]

plugin_sources = [
  'common.vala',
  'dbus-service.vala',
  'factory.vala',
  'plugin.vala',
  'ui/control.vala',
]

plugin_deps += link_libconfig

configure_file(
          input: plugin_name + '.plugin',
         output: plugin_name + '.plugin',
  configuration: configuration_data(),
        install: true,
    install_dir: dir_plugin,
)

plugin_lib = library('dactl-' + plugin_name, plugin_resources + plugin_sources,
  dependencies: plugin_deps,
   vala_header: plugin_name + '.h',
     vala_args: plugin_vala_args,
        c_args: plugin_c_args,
       install: true,
   install_dir: dir_plugin,
)

plugin = declare_dependency(
  include_directories: include_directories('.'),
            link_with: plugin_lib,
)
