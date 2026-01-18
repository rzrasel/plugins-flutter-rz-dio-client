//
//  Generated file. Do not edit.
//

// clang-format off

#include "generated_plugin_registrant.h"

#include <rz_dio_client/rz_dio_client_plugin.h>

void fl_register_plugins(FlPluginRegistry* registry) {
  g_autoptr(FlPluginRegistrar) rz_dio_client_registrar =
      fl_plugin_registry_get_registrar_for_plugin(registry, "RzDioClientPlugin");
  rz_dio_client_plugin_register_with_registrar(rz_dio_client_registrar);
}
