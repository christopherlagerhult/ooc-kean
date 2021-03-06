import structs/HashMap
import ../[ThreadLocal, Mutex]
import ThreadWin32
include unistd

version(windows) {
	include windows

	GetCurrentThreadId: extern func -> ULong

	ThreadLocalWin32: class <T> extends ThreadLocal<T> {
		values := HashMap<ULong, T> new()
		valuesMutex := Mutex new()

		init: func ~windows
		set: override func (value: T) {
			valuesMutex lock()
			values put(GetCurrentThreadId(), value)
			valuesMutex unlock()
		}
		get: override func -> T {
			valuesMutex lock()
			value := values get(GetCurrentThreadId())
			valuesMutex unlock()
			value
		}
		hasValue: override func -> Bool {
			valuesMutex lock()
			has := values contains(GetCurrentThreadId())
			valuesMutex unlock()
			has
		}
	}
}
