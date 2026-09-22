package sysinfo

import win32 "core:sys/windows"

@(private)
_cpu_features :: proc "contextless" () -> (features: CPU_Features) {
	return _features
}

@(init, private)
_init_cpu_features :: proc "contextless" () {
	// Baseline requirements for Windows ARM64.
	_features += {.floatingpoint, .asimd}

	if win32.IsProcessorFeaturePresent(.PF_ARM_V82_FP16_INSTRUCTIONS_AVAILABLE) {
		// Windows exposes FEAT_FP16 as one feature, whereas Linux reports
		// scalar and Advanced SIMD half-precision support separately.
		_features += {.asimdhp, .fp16}
	}

	if win32.IsProcessorFeaturePresent(.PF_ARM_V86_BF16_INSTRUCTIONS_AVAILABLE) {
		_features += {.bf16}
	}

	// No Windows processor-feature flag for .fcma
	// No Windows processor-feature flag for .fhm
	// No Windows processor-feature flag for .frint

	if win32.IsProcessorFeaturePresent(.PF_ARM_V82_I8MM_INSTRUCTIONS_AVAILABLE) {
		_features += {.i8mm}
	}

	if win32.IsProcessorFeaturePresent(.PF_ARM_V83_JSCVT_INSTRUCTIONS_AVAILABLE) {
		_features += {.jscvt}
	}

	// No Windows processor-feature flag for .rdm
	// No Windows processor-feature flag for .flagm
	// No Windows processor-feature flag for .flagm2

	if win32.IsProcessorFeaturePresent(.PF_ARM_V8_CRC32_INSTRUCTIONS_AVAILABLE) {
		_features += {.crc32}
	}

	if win32.IsProcessorFeaturePresent(.PF_ARM_V81_ATOMIC_INSTRUCTIONS_AVAILABLE) {
		_features += {.lse}
	}

	if win32.IsProcessorFeaturePresent(.PF_ARM_LSE2_AVAILABLE) {
		_features += {.lse2}
	}

	if win32.IsProcessorFeaturePresent(.PF_ARM_V83_LRCPC_INSTRUCTIONS_AVAILABLE) {
		_features += {.lrcpc}
	}

	// No Windows processor-feature flag for .lrcpc2

	if win32.IsProcessorFeaturePresent(.PF_ARM_V8_CRYPTO_INSTRUCTIONS_AVAILABLE) {
		// Windows exposes the traditional Armv8 crypto bundle rather than
		// individual AES, PMULL, SHA-1 and SHA-256 feature bits.
		_features += {.aes, .pmull, .sha1, .sha256}
	}

	if win32.IsProcessorFeaturePresent(.PF_ARM_SHA3_INSTRUCTIONS_AVAILABLE) {
		_features += {.sha3}
	}

	if win32.IsProcessorFeaturePresent(.PF_ARM_SHA512_INSTRUCTIONS_AVAILABLE) {
		_features += {.sha512}
	}

	// No Windows processor-feature flag for .sb
	// No Windows processor-feature flag for .ssbs
}

@(init, private)
_init_cpu_name :: proc "contextless" () {
	sub_key :: `HARDWARE\DESCRIPTION\System\CentralProcessor\0`
	value_name :: `ProcessorNameString`

	if name, ok := read_reg_string(win32.HKEY_LOCAL_MACHINE, sub_key, value_name, _name_buf[:]);
	   ok {
		_name = name
		return
	}

	_cpu_name_arm_generic()
}
