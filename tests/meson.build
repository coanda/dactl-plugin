if get_option('enable-tests')

  test_deps = plugin_deps + [ plugin, link_libconfig ]

  test_vala_args = [
    '--vapidir', dir_libconfig,
    '--pkg', 'plugin-config'
  ]

  plugin_tests = [
    'dbus-service',
  ]

  foreach name : plugin_tests
    test(name,
      executable(name + '-test', name + '-test.vala',
        dependencies: test_deps,
           vala_args: test_vala_args,
      ),
      env: ['G_TEST_SRCDIR=' + meson.current_source_dir()]
    )
  endforeach

endif
