package windows_dll_abi

import "core:testing"
import win32 "core:sys/windows"

when ODIN_ARCH == .arm64 {
	foreign import abi_fixture "bin/arm64/odin_windows_abi.lib"
} else when ODIN_ARCH == .amd64 {
	foreign import abi_fixture "bin/x64/odin_windows_abi.lib"
} else {
	#assert(false, "The Windows DLL ABI test only supports amd64 and arm64.")
}

Abi_Result :: struct {
	total:    i64,
	weighted: f64,
	tag:      u32,
	padding:  u32,
}

Callback_C       :: proc "c"       (i64, i64, i64, i64, i64, i64, i64, i64, i64, i64) -> i64
Callback_System  :: proc "system"  (i64, i64, i64, i64, i64, i64, i64, i64, i64, i64) -> i64
Callback_StdCall :: proc "stdcall" (i64, i64, i64, i64, i64, i64, i64, i64, i64, i64) -> i64

foreign abi_fixture {
	abi_context_layout :: proc "c" (layout: ^[18]uintptr) ---

	@(link_name="abi_sum10")
	abi_sum10_c :: proc "c" (
		i64, i64, i64, i64, i64, i64, i64, i64, i64, i64,
	) -> i64 ---

	@(link_name="abi_sum10")
	abi_sum10_system :: proc "system" (
		i64, i64, i64, i64, i64, i64, i64, i64, i64, i64,
	) -> i64 ---

	@(link_name="abi_sum10")
	abi_sum10_stdcall :: proc "stdcall" (
		i64, i64, i64, i64, i64, i64, i64, i64, i64, i64,
	) -> i64 ---

	@(link_name="abi_weighted10")
	abi_weighted10_c :: proc "c" (
		f64, f64, f64, f64, f64, f64, f64, f64, f64, f64,
	) -> f64 ---

	@(link_name="abi_weighted10")
	abi_weighted10_system :: proc "system" (
		f64, f64, f64, f64, f64, f64, f64, f64, f64, f64,
	) -> f64 ---

	@(link_name="abi_weighted10")
	abi_weighted10_stdcall :: proc "stdcall" (
		f64, f64, f64, f64, f64, f64, f64, f64, f64, f64,
	) -> f64 ---

	@(link_name="abi_make_result")
	abi_make_result_c :: proc "c" (base: i64, scale: f64, tag: u32) -> Abi_Result ---

	@(link_name="abi_make_result")
	abi_make_result_system :: proc "system" (base: i64, scale: f64, tag: u32) -> Abi_Result ---

	@(link_name="abi_make_result")
	abi_make_result_stdcall :: proc "stdcall" (base: i64, scale: f64, tag: u32) -> Abi_Result ---

	@(link_name="abi_call_callback")
	abi_call_callback_c :: proc "c" (callback: Callback_C, seed: i64) -> i64 ---

	@(link_name="abi_call_callback")
	abi_call_callback_system :: proc "system" (callback: Callback_System, seed: i64) -> i64 ---

	@(link_name="abi_call_callback")
	abi_call_callback_stdcall :: proc "stdcall" (callback: Callback_StdCall, seed: i64) -> i64 ---
}

@test
test_context_layout_matches_windows_sdk :: proc(t: ^testing.T) {
	expected: [18]uintptr
	abi_context_layout(&expected)
	actual: [18]uintptr
	actual[0] = size_of(win32.CONTEXT)
	actual[1] = align_of(win32.CONTEXT)
	actual[2] = offset_of(win32.CONTEXT, ContextFlags)
	when ODIN_ARCH == .arm64 {
		actual[3] = offset_of(win32.CONTEXT, Cpsr)
		actual[4] = offset_of(win32.CONTEXT, X)
		actual[5] = offset_of(win32.CONTEXT, Fp)
		actual[6] = offset_of(win32.CONTEXT, Lr)
		actual[7] = offset_of(win32.CONTEXT, Sp)
		actual[8] = offset_of(win32.CONTEXT, Pc)
		actual[9] = offset_of(win32.CONTEXT, V)
		actual[10] = offset_of(win32.CONTEXT, Fpcr)
		actual[11] = offset_of(win32.CONTEXT, Fpsr)
		actual[12] = offset_of(win32.CONTEXT, Bcr)
		actual[13] = offset_of(win32.CONTEXT, Bvr)
		actual[14] = offset_of(win32.CONTEXT, Wcr)
		actual[15] = offset_of(win32.CONTEXT, Wvr)
		actual[16] = size_of(win32.NEON128)
		actual[17] = align_of(win32.NEON128)
	}
	for value, i in actual {
		testing.expectf(t, value == expected[i], "CONTEXT layout entry %d: Odin=%d, Windows SDK=%d", i, value, expected[i])
	}
}

sum10_c :: proc "c" (
	a0, a1, a2, a3, a4, a5, a6, a7, a8, a9: i64,
) -> i64 {
	return a0+a1+a2+a3+a4+a5+a6+a7+a8+a9
}

sum10_system :: proc "system" (
	a0, a1, a2, a3, a4, a5, a6, a7, a8, a9: i64,
) -> i64 {
	return a0+a1+a2+a3+a4+a5+a6+a7+a8+a9
}

sum10_stdcall :: proc "stdcall" (
	a0, a1, a2, a3, a4, a5, a6, a7, a8, a9: i64,
) -> i64 {
	return a0+a1+a2+a3+a4+a5+a6+a7+a8+a9
}

@test
test_calls_into_msvc_dll :: proc(t: ^testing.T) {
	expected_sum: i64 = 55
	testing.expect(t, abi_sum10_c(1, 2, 3, 4, 5, 6, 7, 8, 9, 10) == expected_sum)
	testing.expect(t, abi_sum10_system(1, 2, 3, 4, 5, 6, 7, 8, 9, 10) == expected_sum)
	testing.expect(t, abi_sum10_stdcall(1, 2, 3, 4, 5, 6, 7, 8, 9, 10) == expected_sum)

	expected_weighted: f64 = 385
	testing.expect(t, abi_weighted10_c(1, 2, 3, 4, 5, 6, 7, 8, 9, 10) == expected_weighted)
	testing.expect(t, abi_weighted10_system(1, 2, 3, 4, 5, 6, 7, 8, 9, 10) == expected_weighted)
	testing.expect(t, abi_weighted10_stdcall(1, 2, 3, 4, 5, 6, 7, 8, 9, 10) == expected_weighted)

	expected_result := Abi_Result{total = 142, weighted = 6.5, tag = 0xb791f3dd}
	testing.expect(t, abi_make_result_c(100, 3.25, 0x12345678) == expected_result)
	testing.expect(t, abi_make_result_system(100, 3.25, 0x12345678) == expected_result)
	testing.expect(t, abi_make_result_stdcall(100, 3.25, 0x12345678) == expected_result)
}

@test
test_callbacks_from_msvc_dll :: proc(t: ^testing.T) {
	expected: i64 = 1045
	testing.expect(t, abi_call_callback_c(sum10_c, 100) == expected)
	testing.expect(t, abi_call_callback_system(sum10_system, 100) == expected)
	testing.expect(t, abi_call_callback_stdcall(sum10_stdcall, 100) == expected)
}
