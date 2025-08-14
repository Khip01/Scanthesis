//
//  Generated file. Do not edit.
//

import FlutterMacOS
import Foundation

import bitsdojo_window_macos
import desktop_drop
import file_picker
import hotkey_manager_macos
import pasteboard
import path_provider_foundation
import screen_capturer_macos
import screen_retriever_macos
import shared_preferences_foundation
import tray_manager
import window_manager

func RegisterGeneratedPlugins(registry: FlutterPluginRegistry) {
  BitsdojoWindowPlugin.register(with: registry.registrar(forPlugin: "BitsdojoWindowPlugin"))
  DesktopDropPlugin.register(with: registry.registrar(forPlugin: "DesktopDropPlugin"))
  FilePickerPlugin.register(with: registry.registrar(forPlugin: "FilePickerPlugin"))
  HotkeyManagerMacosPlugin.register(with: registry.registrar(forPlugin: "HotkeyManagerMacosPlugin"))
  PasteboardPlugin.register(with: registry.registrar(forPlugin: "PasteboardPlugin"))
  PathProviderPlugin.register(with: registry.registrar(forPlugin: "PathProviderPlugin"))
  ScreenCapturerMacosPlugin.register(with: registry.registrar(forPlugin: "ScreenCapturerMacosPlugin"))
  ScreenRetrieverMacosPlugin.register(with: registry.registrar(forPlugin: "ScreenRetrieverMacosPlugin"))
  SharedPreferencesPlugin.register(with: registry.registrar(forPlugin: "SharedPreferencesPlugin"))
  TrayManagerPlugin.register(with: registry.registrar(forPlugin: "TrayManagerPlugin"))
  WindowManagerPlugin.register(with: registry.registrar(forPlugin: "WindowManagerPlugin"))
}
