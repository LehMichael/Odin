package windows_no_crt

import win32 "core:sys/windows"

foreign import fltused_fixture "build/fltused_fixture.obj"

foreign fltused_fixture {
	odin_no_crt_fltused_fixture :: proc "c" (value: f64) -> f64 ---
}

// No-CRT builds disable TLS; keep this fixture single-threaded.
fail :: proc "contextless" () -> ! {
	win32.ExitProcess(1)
}

touch_large_stack :: #force_no_inline proc "contextless" (seed: byte) -> u32 {
	buffer: [64 * 1024]byte
	checksum: u32
	for offset := 0; offset < len(buffer); offset += 4096 {
		buffer[offset] = seed + byte(offset / 4096)
		checksum += u32(buffer[offset])
	}
	return checksum
}

main :: proc() {
	// A large frame makes LLVM emit the platform stack-probe call.
	if touch_large_stack(1) != 136 {
		fail()
	}

	// An MSVC object containing floating-point code references _fltused.
	if odin_no_crt_fltused_fixture(2.0) != 2.0 {
		fail()
	}

}
