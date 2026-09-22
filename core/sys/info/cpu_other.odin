#+build openbsd, freebsd, netbsd
package sysinfo

@(private)
_cpu_core_count :: proc "contextless" () -> (physical: int, logical: int, ok: bool) {
	return 0, 0, false
}

when ODIN_ARCH == .arm32 || ODIN_ARCH == .arm64 {
	@(init, private)
	_init_cpu_name :: proc "contextless" () {
		_cpu_name_arm_generic()
	}

	@(private)
	_cpu_features :: proc "contextless" () -> (features: CPU_Features) {
		return {}
	}
}
