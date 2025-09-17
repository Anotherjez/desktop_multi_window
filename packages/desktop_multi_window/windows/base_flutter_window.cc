//
// Created by yangbin on 2022/1/27.
//

#include "base_flutter_window.h"

namespace
{
  void CenterRectToMonitor(LPRECT prc)
  {
    HMONITOR hMonitor;
    MONITORINFO mi;
    RECT rc;
    int w = prc->right - prc->left;
    int h = prc->bottom - prc->top;

    //
    // get the nearest monitor to the passed rect.
    //
    hMonitor = MonitorFromRect(prc, MONITOR_DEFAULTTONEAREST);

    //
    // get the work area or entire monitor rect.
    //
    mi.cbSize = sizeof(mi);
    GetMonitorInfo(hMonitor, &mi);

    rc = mi.rcMonitor;

    prc->left = rc.left + (rc.right - rc.left - w) / 2;
    prc->top = rc.top + (rc.bottom - rc.top - h) / 2;
    prc->right = prc->left + w;
    prc->bottom = prc->top + h;
  }

  std::wstring Utf16FromUtf8(const std::string &string)
  {
    int size_needed = MultiByteToWideChar(CP_UTF8, 0, string.c_str(), -1, nullptr, 0);
    if (size_needed == 0)
    {
      return {};
    }
    std::wstring wstrTo(size_needed, 0);
    int converted_length = MultiByteToWideChar(CP_UTF8, 0, string.c_str(), -1, &wstrTo[0], size_needed);
    if (converted_length == 0)
    {
      return {};
    }
    return wstrTo;
  }

}

void BaseFlutterWindow::Center()
{
  auto handle = GetWindowHandle();
  if (!handle)
  {
    return;
  }
  RECT rc;
  GetWindowRect(handle, &rc);
  CenterRectToMonitor(&rc);
  SetWindowPos(handle, nullptr, rc.left, rc.top, 0, 0, SWP_NOSIZE | SWP_NOZORDER | SWP_NOACTIVATE);
}

void BaseFlutterWindow::SetBounds(double_t x, double_t y, double_t width, double_t height)
{
  auto handle = GetWindowHandle();
  if (!handle)
  {
    return;
  }
  MoveWindow(handle, int32_t(x), int32_t(y),
             static_cast<int>(width),
             static_cast<int>(height),
             TRUE);
}

void BaseFlutterWindow::SetTitle(const std::string &title)
{
  auto handle = GetWindowHandle();
  if (!handle)
  {
    return;
  }
  SetWindowText(handle, Utf16FromUtf8(title).c_str());
}

void BaseFlutterWindow::Close()
{
  auto handle = GetWindowHandle();
  if (!handle)
  {
    return;
  }
  PostMessage(handle, WM_SYSCOMMAND, SC_CLOSE, 0);
}

void BaseFlutterWindow::Show()
{
  auto handle = GetWindowHandle();
  if (!handle)
  {
    return;
  }
  ShowWindow(handle, SW_SHOW);
}

void BaseFlutterWindow::Hide()
{
  auto handle = GetWindowHandle();
  if (!handle)
  {
    return;
  }
  ShowWindow(handle, SW_HIDE);
}

void BaseFlutterWindow::SetTransparency(const flutter::EncodableMap &transparency_config)
{
  auto handle = GetWindowHandle();
  if (!handle)
  {
    return;
  }

  try
  {
    // Extract transparency parameters with safe fallbacks
    int mode = 0;            // Default: none
    int colorKey = 0x01FE01; // Default: RGB(1, 254, 1)
    int alpha = 255;         // Default: opaque
    bool toolWindow = false;
    bool transparent = false;

    // Safely extract mode
    auto mode_it = transparency_config.find(flutter::EncodableValue("mode"));
    if (mode_it != transparency_config.end())
    {
      if (auto mode_val = std::get_if<int>(&mode_it->second))
      {
        mode = *mode_val;
      }
    }

    // Safely extract colorKey
    auto colorKey_it = transparency_config.find(flutter::EncodableValue("colorKey"));
    if (colorKey_it != transparency_config.end())
    {
      if (auto colorKey_val = std::get_if<int>(&colorKey_it->second))
      {
        colorKey = *colorKey_val;
      }
    }

    // Safely extract alpha
    auto alpha_it = transparency_config.find(flutter::EncodableValue("alpha"));
    if (alpha_it != transparency_config.end())
    {
      if (auto alpha_val = std::get_if<int>(&alpha_it->second))
      {
        alpha = *alpha_val;
      }
    }

    // Safely extract toolWindow
    auto toolWindow_it = transparency_config.find(flutter::EncodableValue("toolWindow"));
    if (toolWindow_it != transparency_config.end())
    {
      if (auto toolWindow_val = std::get_if<bool>(&toolWindow_it->second))
      {
        toolWindow = *toolWindow_val;
      }
    }

    // Safely extract transparent
    auto transparent_it = transparency_config.find(flutter::EncodableValue("transparent"));
    if (transparent_it != transparency_config.end())
    {
      if (auto transparent_val = std::get_if<bool>(&transparent_it->second))
      {
        transparent = *transparent_val;
      }
    }

    // Get current extended window styles
    LONG_PTR exStyle = GetWindowLongPtr(handle, GWL_EXSTYLE);

    // Add/remove extended styles based on configuration
    if (mode > 0)
    { // If transparency is enabled
      exStyle |= WS_EX_LAYERED;
    }
    else
    {
      exStyle &= ~WS_EX_LAYERED;
    }

    if (toolWindow)
    {
      exStyle |= WS_EX_TOOLWINDOW;
    }
    else
    {
      exStyle &= ~WS_EX_TOOLWINDOW;
    }

    if (transparent)
    {
      exStyle |= WS_EX_TRANSPARENT;
    }
    else
    {
      exStyle &= ~WS_EX_TRANSPARENT;
    }

    // Apply the extended styles
    SetWindowLongPtr(handle, GWL_EXSTYLE, exStyle);

    // Apply transparency settings if layered window is enabled
    if (mode > 0)
    {
      if (mode == 1)
      { // Color-key transparency
        SetLayeredWindowAttributes(handle, static_cast<COLORREF>(colorKey), 0, LWA_COLORKEY);
      }
      else if (mode == 2)
      { // Per-pixel alpha transparency
        SetLayeredWindowAttributes(handle, 0, static_cast<BYTE>(alpha), LWA_ALPHA);
      }
    }

    // Force window to redraw
    InvalidateRect(handle, nullptr, TRUE);
    UpdateWindow(handle);
  }
  catch (const std::exception &e)
  {
    // If transparency fails, just continue without it
    // This prevents crashes when transparency is not supported
  }
}
exStyle &= ~WS_EX_TRANSPARENT;
}

// Apply the extended styles
SetWindowLongPtr(handle, GWL_EXSTYLE, exStyle);

// Apply transparency settings if layered window is enabled
if (mode > 0)
{
  if (mode == 1)
  { // Color-key transparency
    SetLayeredWindowAttributes(handle, static_cast<COLORREF>(colorKey), 0, LWA_COLORKEY);
  }
  else if (mode == 2)
  { // Per-pixel alpha transparency
    SetLayeredWindowAttributes(handle, 0, static_cast<BYTE>(alpha), LWA_ALPHA);
  }
}

// Force window to redraw
InvalidateRect(handle, nullptr, TRUE);
UpdateWindow(handle);
}
