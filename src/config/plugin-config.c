#ifndef CONFIG_H_INCLUDED
#include "config.h"

/**
 * All this is to keep Vala happy & configured..
 */
const char *PLUGIN_NAME = PACKAGE_NAME;
const char *PLUGIN_VERSION = PACKAGE_VERSION;
const char *PLUGIN_STRING = PACKAGE_STRING;
const char *PLUGIN_URL = PACKAGE_URL;
const char *PLUGIN_GETTEXT_PACKAGE = GETTEXT_PACKAGE;

#else
#error config.h missing!
#endif
