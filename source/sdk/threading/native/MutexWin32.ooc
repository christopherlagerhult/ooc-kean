import ../Mutex
import os/win32

version(windows) {
	include windows

	CreateMutex: extern func (Pointer, Bool, Pointer) -> Handle
	ReleaseMutex: extern func (Handle)
	CloseHandle: extern func (Handle)

	WaitForSingleObject: extern func (...) -> Long
	INFINITE: extern Long

	MutexWin32: class extends Mutex {
		_backend: Handle
		init: func {
			this _backend = CreateMutex (
				null, // default security attributes
				false, // initially not owned
				null) // unnamed mutex
		}
		free: override func {
			CloseHandle(this _backend)
			super()
		}
		lock: override func {
			WaitForSingleObject(
				this _backend, // handle to mutex
				INFINITE // no time-out interval
			)
		}
		unlock: override func {
			ReleaseMutex(this _backend)
		}
	}

	// Win32 mutexes are recursive by default, so this is just a copy of `MutexWin32`
	RecursiveMutexWin32: class extends RecursiveMutex {
		_backend: Handle
		init: func {
			this _backend = CreateMutex (
				null, // default security attributes
				false, // initially not owned
				null) // unnamed mutex
		}
		free: override func {
			CloseHandle(this _backend)
			super()
		}
		lock: override func {
			WaitForSingleObject(
				this _backend, // handle to mutex
				INFINITE // no time-out interval
			)
		}
		unlock: override func {
			ReleaseMutex(this _backend)
		}
	}
}
