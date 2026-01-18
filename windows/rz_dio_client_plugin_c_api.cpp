#include "include/rz_dio_client/rz_dio_client_plugin_c_api.h"

#include <flutter/plugin_registrar_windows.h>

#include "rz_dio_client_plugin.h"

void RzDioClientPluginCApiRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  rz_dio_client::RzDioClientPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
