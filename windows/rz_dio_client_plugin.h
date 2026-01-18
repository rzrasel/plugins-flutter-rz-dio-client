#ifndef FLUTTER_PLUGIN_RZ_DIO_CLIENT_PLUGIN_H_
#define FLUTTER_PLUGIN_RZ_DIO_CLIENT_PLUGIN_H_

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>

#include <memory>

namespace rz_dio_client {

class RzDioClientPlugin : public flutter::Plugin {
 public:
  static void RegisterWithRegistrar(flutter::PluginRegistrarWindows *registrar);

  RzDioClientPlugin();

  virtual ~RzDioClientPlugin();

  // Disallow copy and assign.
  RzDioClientPlugin(const RzDioClientPlugin&) = delete;
  RzDioClientPlugin& operator=(const RzDioClientPlugin&) = delete;

  // Called when a method is called on this plugin's channel from Dart.
  void HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue> &method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
};

}  // namespace rz_dio_client

#endif  // FLUTTER_PLUGIN_RZ_DIO_CLIENT_PLUGIN_H_
