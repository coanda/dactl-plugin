# Dactl Plugin Template

**_NOT READY - NEEDS RENAMING IN TEMPLATES_**

This repository is meant to be used as a starting point for Dactl plugins.

## Copy

```sh
npm install -g degit
degit coanda/dactl-plugin
```

## Install

```sh
meson _build
sudo ninja -C _build install
```

## Rename

In the copied repository you can use the following command to replace strings in files without corrupting
the git directory.

```sh
 git grep -l 'plugin_template' | xargs sed -i 's/plugin_template/new_name/g'
```
