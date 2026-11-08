#include "single_instance.h"

#include <shellapi.h>

#include "utils.h"

namespace {

#ifdef NDEBUG
constexpr wchar_t kMutexName[] =
    L"Local\\Velin.SingleInstance.8B9E5F9B-8C9A-4B2D-9A1E-7E5E8C4D3A21";
#else
constexpr wchar_t kMutexName[] =
    L"Local\\Velin.SingleInstance.Debug.8B9E5F9B-8C9A-4B2D-9A1E-7E5E8C4D3A21";
#endif

// The first instance creates its window shortly after taking the lock;
// wait up to this long for it to appear.
constexpr int kFindWindowAttempts = 50;
constexpr DWORD kFindWindowIntervalMs = 100;

constexpr UINT kSendTimeoutMs = 5000;

std::wstring AbsolutePath(const std::wstring& path) {
  DWORD length = ::GetFullPathNameW(path.c_str(), 0, nullptr, nullptr);
  if (length == 0) {
    return path;
  }
  std::wstring result(length, L'\0');
  length = ::GetFullPathNameW(path.c_str(), length, result.data(), nullptr);
  if (length == 0) {
    return path;
  }
  result.resize(length);
  return result;
}

}  // namespace

SingleInstanceLock::SingleInstanceLock() {
  mutex_ = ::CreateMutexW(nullptr, FALSE, kMutexName);
  // If the mutex cannot be created at all, behave as the first instance
  // rather than refusing to start.
  is_first_ = mutex_ == nullptr || ::GetLastError() != ERROR_ALREADY_EXISTS;
}

SingleInstanceLock::~SingleInstanceLock() {
  if (mutex_ != nullptr) {
    ::CloseHandle(mutex_);
  }
}

std::vector<std::wstring> GetAbsoluteCommandLineArguments() {
  std::vector<std::wstring> arguments;

  int argc = 0;
  wchar_t** argv = ::CommandLineToArgvW(::GetCommandLineW(), &argc);
  if (argv == nullptr) {
    return arguments;
  }

  // Skip the program name.
  for (int i = 1; i < argc; i++) {
    std::wstring argument(argv[i]);
    if (argument.empty()) {
      continue;
    }
    // Flags are passed through unchanged.
    arguments.push_back(argument[0] == L'-' ? argument
                                            : AbsolutePath(argument));
  }

  ::LocalFree(argv);
  return arguments;
}

bool ForwardToRunningInstance(const std::vector<std::wstring>& paths) {
  HWND window = nullptr;
  for (int attempt = 0; attempt < kFindWindowAttempts; attempt++) {
    window = ::FindWindowW(kVelinWindowClassName, nullptr);
    if (window != nullptr) {
      break;
    }
    ::Sleep(kFindWindowIntervalMs);
  }
  if (window == nullptr) {
    return false;
  }

  // Payload: each path followed by a NUL, in UTF-16.
  std::wstring payload;
  for (const std::wstring& path : paths) {
    if (!path.empty() && path[0] != L'-') {
      payload += path;
      payload.push_back(L'\0');
    }
  }

  if (!payload.empty()) {
    COPYDATASTRUCT data = {};
    data.dwData = kOpenFilesCopyDataId;
    data.cbData = static_cast<DWORD>(payload.size() * sizeof(wchar_t));
    data.lpData = payload.data();

    DWORD_PTR result = 0;
    if (::SendMessageTimeoutW(window, WM_COPYDATA, 0,
                              reinterpret_cast<LPARAM>(&data),
                              SMTO_ABORTIFHUNG, kSendTimeoutMs,
                              &result) == 0) {
      // The running instance is hung; better to start a new one than to
      // silently drop the files.
      return false;
    }
  }

  // This process was started by the user, so it may hand over the
  // foreground to the running window.
  if (::IsIconic(window)) {
    ::ShowWindow(window, SW_RESTORE);
  }
  ::SetForegroundWindow(window);
  return true;
}

bool DecodeOpenFilesMessage(const COPYDATASTRUCT* data,
                            std::vector<std::string>* paths) {
  if (data == nullptr || data->dwData != kOpenFilesCopyDataId ||
      data->lpData == nullptr || data->cbData % sizeof(wchar_t) != 0) {
    return false;
  }

  const wchar_t* chars = static_cast<const wchar_t*>(data->lpData);
  const size_t length = data->cbData / sizeof(wchar_t);

  size_t start = 0;
  for (size_t i = 0; i < length; i++) {
    if (chars[i] == L'\0') {
      if (i > start) {
        std::wstring path(chars + start, i - start);
        paths->push_back(Utf8FromUtf16(path.c_str()));
      }
      start = i + 1;
    }
  }
  return true;
}
