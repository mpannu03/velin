#ifndef RUNNER_SINGLE_INSTANCE_H_
#define RUNNER_SINGLE_INSTANCE_H_

#include <windows.h>

#include <string>
#include <vector>

// Keeps one Velin window per user session. A second launch (e.g. "Open with
// Velin" while Velin is running) hands its files to the running window with
// WM_COPYDATA and exits.
//
// Debug builds use different names so `flutter run` never hands its files to
// an installed copy.

#ifdef NDEBUG
constexpr wchar_t kVelinWindowClassName[] = L"VELIN_MAIN_WINDOW";
#else
constexpr wchar_t kVelinWindowClassName[] = L"VELIN_MAIN_WINDOW_DEBUG";
#endif

// Identifies Velin's WM_COPYDATA payload ("VELN").
constexpr ULONG_PTR kOpenFilesCopyDataId = 0x56454C4E;

// Holds a per-session mutex for as long as it lives.
class SingleInstanceLock {
 public:
  SingleInstanceLock();
  ~SingleInstanceLock();

  SingleInstanceLock(const SingleInstanceLock&) = delete;
  SingleInstanceLock& operator=(const SingleInstanceLock&) = delete;

  // False when another Velin already holds the lock.
  bool IsFirstInstance() const { return is_first_; }

 private:
  HANDLE mutex_ = nullptr;
  bool is_first_ = true;
};

// The command-line arguments (without the program name) with relative paths
// made absolute, since the running instance has a different working
// directory.
std::vector<std::wstring> GetAbsoluteCommandLineArguments();

// Sends |paths| to the running Velin window and brings it to the front.
// Returns false if no running window was found, in which case this launch
// should carry on as a normal instance.
bool ForwardToRunningInstance(const std::vector<std::wstring>& paths);

// Decodes the paths of a WM_COPYDATA message sent by
// ForwardToRunningInstance, as UTF-8. Returns false for other messages.
bool DecodeOpenFilesMessage(const COPYDATASTRUCT* data,
                            std::vector<std::string>* paths);

#endif  // RUNNER_SINGLE_INSTANCE_H_
