# SPDX-License-Identifier: MIT
# The library and tools have nothing of their own to verify; the package
# component checks the installed result. This lets "make install verify"
# recurse through every component.
.PHONY: verify
verify:
	@:
