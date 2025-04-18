/* Generated by wayland-scanner 1.20.0 */

/*
 * Copyright © 2017 Samsung Electronics Co., Ltd
 *
 * Permission is hereby granted, free of charge, to any person
 * obtaining a copy of this software and associated documentation files
 * (the "Software"), to deal in the Software without restriction,
 * including without limitation the rights to use, copy, modify, merge,
 * publish, distribute, sublicense, and/or sell copies of the Software,
 * and to permit persons to whom the Software is furnished to do so,
 * subject to the following conditions:
 *
 * The above copyright notice and this permission notice (including the
 * next paragraph) shall be included in all copies or substantial
 * portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT.  IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
 * BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
 * ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
 * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

#include <stdlib.h>
#include <stdint.h>
#include "wayland-util.h"

extern const struct wl_interface fd_passer_interface;

static const struct wl_interface *build_time_wayland_tests_types[] = {
	NULL,
	&fd_passer_interface,
};

static const struct wl_message fd_passer_requests[] = {
	{ "destroy", "", build_time_wayland_tests_types + 0 },
	{ "conjoin", "2o", build_time_wayland_tests_types + 1 },
};

static const struct wl_message fd_passer_events[] = {
	{ "pre_fd", "", build_time_wayland_tests_types + 0 },
	{ "fd", "h", build_time_wayland_tests_types + 0 },
};

WL_EXPORT const struct wl_interface fd_passer_interface = {
	"fd_passer", 2,
	2, fd_passer_requests,
	2, fd_passer_events,
};

