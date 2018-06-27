project('plugin-template', [ 'c', 'vala' ],
          license: 'GPL3+',
          version: '0.1.0',
    meson_version: '>= 0.40.1',
  default_options: [
                     'c_std=gnu11',
                     'warning_level=2',
                   ],
)

version_split = meson.project_version().split('.')
MAJOR_VERSION = version_split[0]
MINOR_VERSION = version_split[1]
MICRO_VERSION = version_split[2]

plugin_name = meson.project_name()
plugin_c_name = plugin_name.underscorify()
dir_vapi = join_paths(meson.current_source_dir(), 'vapi')

status = [
  '', '',
  'Dactl Plugin Template @0@'.format(meson.project_version()),
  '', '',
]

# Warning message
if (version_split[1].to_int() % 2 == 1)
  status += [
    'You are building a debug version of the plugin. There may be more bugs in',
    'this version that you are comfortable with.',
    '', ''
  ]
endif

status += [
  'Version ............................... : @0@'.format(meson.project_version()),
  'Build Type ............................ : @0@'.format(get_option('buildtype')),
  '',
  'Prefix ................................ : @0@'.format(get_option('prefix')),
  'Libdir ................................ : @0@'.format(join_paths(get_option('prefix'), get_option('libdir'))),
  '', ''
]

add_project_arguments([
    '--target-glib', '2.44',
    '--vapidir', join_paths(meson.current_source_dir(), 'vapi'),
  ],
  language: 'vala'
)

dep_cld = dependency('cld-1.0')
dep_dactl = dependency('libdactl-1.0')
dep_gee = dependency('gee-0.8')
dep_gtk = dependency('gtk+-3.0')
dep_clutter = dependency('clutter-1.0')
dep_webkit = dependency('webkit2gtk-4.0')
dep_modbus = dependency('libmodbus')
dep_peas = dependency('libpeas-1.0')
dep_xml = dependency('libxml-2.0')
dep_posix = meson.get_compiler('vala').find_library('posix')

comedi_lib = meson.get_compiler('c').find_library('comedi')
comedi_vapi = meson.get_compiler('vala').find_library('comedilib', dirs: dir_vapi)
dep_comedi = declare_dependency(dependencies: [comedi_lib, comedi_vapi])

plugin_deps = [
  dep_cld,
  dep_dactl,
  dep_gee,
  dep_gtk,
  dep_clutter,
  dep_webkit,
  dep_modbus,
  dep_peas,
  dep_xml,
  dep_posix,
  dep_comedi,
]

subst = configuration_data()

# Installation paths
dir_sysconf = join_paths(get_option('sysconfdir'), 'dactl/plugins', plugin_name)
dir_plugin = join_paths(get_option('prefix'), get_option('libdir'), 'dactl/plugins')

subst.set('bindir', join_paths(get_option('prefix'), get_option('bindir')))
subst.set('sysconfdir', dir_sysconf)
subst.set('plugindir', dir_plugin)

# Create config.h
conf = configuration_data()

conf.set_quoted('PACKAGE_NAME', plugin_name)
conf.set_quoted('PACKAGE_VERSION', meson.project_version())
conf.set_quoted('PACKAGE_STRING', '@0@-@1@'.format(plugin_name, meson.project_version()))
conf.set_quoted('PACKAGE_URL', 'http://git.coanda.local/dactl-plugins/@0@'.format(plugin_name))

# For i18n
conf.set_quoted('GETTEXT_PACKAGE', plugin_name)

# Write config.h
configure_file(
         output: 'config.h',
  configuration: conf,
)

# Enable other sections to find config.h
extra_includes = [
  include_directories('.'),
]

gnome = import('gnome')

subdir('src')
subdir('data')
subdir('tests')

message('\n'.join(status))
