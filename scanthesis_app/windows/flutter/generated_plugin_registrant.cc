//
//  Generated file. Do not edit.
//

// clang-format off

#include "generated_plugin_registrant.h"

#include <bitsdojo_window_windows/bitsdojo_window_plugin.h>
#include <desktop_drop/desktop_drop_plugin.h>
#include <irondash_engine_context/irondash_engine_context_plugin_c_api.h>
#include <screen_capturer_windows/screen_capturer_windows_plugin_c_api.h>

void RegisterPlugins(flutter::PluginRegistry* registry) {
  BitsdojoWindowPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("BitsdojoWindowPlugin"));
  DesktopDropPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("DesktopDropPlugin"));
  IrondashEngineContextPluginCApiRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("IrondashEngineContextPluginCApi"));
  ScreenCapturerWindowsPluginCApiRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("ScreenCapturerWindowsPluginCApi"));
}
