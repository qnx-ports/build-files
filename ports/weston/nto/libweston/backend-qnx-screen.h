/*
 * Copyright (C) 2023 Blackberry Limited
 *
 * Permission is hereby granted, free of charge, to any person obtaining
 * a copy of this software and associated documentation files (the
 * "Software"), to deal in the Software without restriction, including
 * without limitation the rights to use, copy, modify, merge, publish,
 * distribute, sublicense, and/or sell copies of the Software, and to
 * permit persons to whom the Software is furnished to do so, subject to
 * the following conditions:
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

#ifndef WESTON_COMPOSITOR_QNX_SCREEN_H
#define WESTON_COMPOSITOR_QNX_SCREEN_H

#ifdef  __cplusplus
extern "C" {
#endif

#include <stdint.h>

#include <libweston/libweston.h>
#include <libweston/plugin-registry.h>

#define WESTON_QNX_SCREEN_BACKEND_CONFIG_VERSION 1

#define WESTON_QNX_SCREEN_OUTPUT_API_NAME "weston_qnx_screen_output_api_v1"

struct weston_qnx_screen_output_api {
        /** Position an output on the QNX screen display.
         *
         * \param output An output to be configured.
         * \param x  Desired horizontal position of the output.
         * \param y  Desired vertical position of the output.
         *
         * Returns 0 on success, -1 on failure.
         *
         * Position a windowed output at the desired x and y
         * coordinates on the QNX screen display. The backend decides
         * what should be done and applies the desired configuration.
         */
        int (*output_set_position)(struct weston_output *output,
                               int x, int y);

        /** Assign the QNX screen display to an output.
         *
         * \param output An output to be configured.
         * \param display  Desired display for the output.
         *
         * Returns 0 on success, -1 on failure.
         *
         * This assigns the desired QNX screen display to a windowed
         * output. The backend decides what should be done and applies
         * the desired configuration.
         */
        int (*output_set_display)(struct weston_output *output,
                               int display);
};

static inline const struct weston_qnx_screen_output_api *
weston_qnx_screen_output_get_api(struct weston_compositor *compositor)
{
	const void *api;
	api = weston_plugin_api_get(compositor, WESTON_QNX_SCREEN_OUTPUT_API_NAME,
				    sizeof(struct weston_qnx_screen_output_api));

	return (const struct weston_qnx_screen_output_api *)api;
}

struct weston_qnx_screen_backend_config {
	struct weston_backend_config base;

	bool fullscreen;
	bool no_input;

	/** Whether to use the pixman renderer instead of the OpenGL ES renderer. */
	bool use_pixman;

	int egl_display;
};

#ifdef  __cplusplus
}
#endif

#endif /* WESTON_COMPOSITOR_QNX_SCREEN_H_ */

