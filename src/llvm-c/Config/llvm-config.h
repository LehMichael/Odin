#ifndef ODIN_LLVM_CONFIG_H
#define ODIN_LLVM_CONFIG_H

/* Select the configuration of the LLVM library linked into the compiler. */
#if defined(_WIN32)
	#if defined(_M_ARM64) || defined(__aarch64__)
		#include "windows/arm64/llvm-config.h"
	#elif defined(_M_X64) || defined(__x86_64__)
		#include "windows/amd64/llvm-config.h"
	#else
		#error "Unsupported Windows architecture for bundled LLVM"
	#endif
#else
	#include <llvm/Config/llvm-config.h>
#endif

#endif
