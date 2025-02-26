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

#include "config.h"

#include <assert.h>
#include <stddef.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>
#include <fcntl.h>
#include <unistd.h>
#include <errno.h>
#include <sys/time.h>
#include <linux/input.h>
#define INPUT_KEY_DOWN HIDD_USAGE_KEYBOARD_ARROW_DOWN
#undef KEY_DOWN

#include <libdrm/drm_fourcc.h>
#include <screen/screen.h>
#include <sys/keycodes.h>
#define SCREEN_KEY_DOWN 0x1
#undef KEY_DOWN

#include <xkbcommon/xkbcommon.h>

#include <libweston/libweston.h>
#include <libweston/backend-qnx-screen.h>
#include "qnx-screen-event-monitor.h"
#include "shared/helpers.h"
#include "shared/image-loader.h"
#include "shared/timespec-util.h"
#include "shared/file-util.h"
#include "shared/os-compatibility.h"
#include <renderer-gl/gl-renderer.h>
#include "shared/weston-egl-ext.h"
#include "pixman-renderer.h"
#include "presentation-time-server-protocol.h"
#include "linux-dmabuf.h"
#include "linux-explicit-synchronization.h"
#include <libweston/windowed-output-api.h>

#define WINDOW_MIN_WIDTH 128
#define WINDOW_MIN_HEIGHT 128

#define WINDOW_MAX_WIDTH 8192
#define WINDOW_MAX_HEIGHT 8192

#define SCREEN_PROPERTY_NONE INT_MAX

static const uint32_t qnx_screen_formats[] = {
	DRM_FORMAT_XRGB8888,
	DRM_FORMAT_ARGB8888,
};

struct qnx_screen_backend {
	struct weston_backend	 base;
	struct weston_compositor *compositor;

	screen_context_t		 context;
	screen_display_t		 display;
	struct wl_array			 keys;
	struct qnx_screen_event_monitor	*event_monitor;
	struct wl_event_source		*screen_source;
	int				 fullscreen;
	int				 no_input;
	int				 use_pixman;
	EGLNativeDisplayType		 egl_display;

	/* We could map multi-pointer X to multiple wayland seats, but
	 * for now we only support core X input. */
	struct weston_seat		 core_seat;
	struct weston_touch_device      *touch_device;
	screen_window_t			 prev_window;
	double				 prev_x;
	double				 prev_y;
	int				 prev_buttons;
	int				 prev_modifiers;
	int				 left_gui_state;
	int				 right_gui_state;
};

struct qnx_screen_head {
	struct weston_head	base;
};

struct qnx_screen_output {
	struct weston_output	base;

	screen_window_t		window;
	screen_session_t        session;
	struct weston_mode	mode;
	struct weston_mode	native;
	struct wl_event_source *finish_frame_task;

#if defined(NO_NO_NOT_YET)
	xcb_gc_t		gc;
	xcb_shm_seg_t		segment;
#endif
	pixman_image_t	       *hw_surface;
	int			shm_id;
	void		       *buf;
	uint8_t			depth;
	int32_t                 scale;
	int			x;
	int			y;
	screen_display_t        display;
};

struct gl_renderer_interface *gl_renderer;

static void
qnx_screen_head_destroy(struct weston_head *base);

static inline struct qnx_screen_head *
to_qnx_screen_head(struct weston_head *base)
{
	if (base->backend_id != qnx_screen_head_destroy)
		return NULL;
	return container_of(base, struct qnx_screen_head, base);
}

static void
qnx_screen_output_destroy(struct weston_output *base);

static inline struct qnx_screen_output *
to_qnx_screen_output(struct weston_output *base)
{
	if (base->destroy != qnx_screen_output_destroy)
		return NULL;
	return container_of(base, struct qnx_screen_output, base);
}

static inline struct qnx_screen_backend *
to_qnx_screen_backend(struct weston_compositor *base)
{
	return container_of(base->backend, struct qnx_screen_backend, base);
}

static screen_display_t
qnx_screen_compositor_get_default_display(struct qnx_screen_backend *b)
{
	int count = 0;
	screen_get_context_property_iv(b->context, SCREEN_PROPERTY_DISPLAY_COUNT, &count);
	if (count <= 0)
		return NULL;

	screen_display_t* displays = calloc(count, sizeof(screen_display_t));
	if (!displays)
		return NULL;

	screen_get_context_property_pv(b->context, SCREEN_PROPERTY_DISPLAYS, (void**)(displays));
	screen_display_t result = displays[0];
	free(displays);
	return result;
}

static uint32_t
get_xkb_base_mods(struct qnx_screen_backend *b, int in)
{
	struct weston_keyboard *keyboard =
		weston_seat_get_keyboard(&b->core_seat);
	struct weston_xkb_info *info = keyboard->xkb_info;
	uint32_t ret = 0;

	if ((in & KEYMOD_SHIFT) && info->shift_mod != XKB_MOD_INVALID)
		ret |= (1 << info->shift_mod);
	if ((in & KEYMOD_CTRL) && info->ctrl_mod != XKB_MOD_INVALID)
		ret |= (1 << info->ctrl_mod);
	if ((in & KEYMOD_ALT) && info->alt_mod != XKB_MOD_INVALID)
		ret |= (1 << info->alt_mod);
	if ((in & KEYMOD_MOD8) && info->super_mod != XKB_MOD_INVALID)
		ret |= (1 << info->super_mod);

	return ret;
}

static uint32_t
get_xkb_latched_mods(struct qnx_screen_backend *b, int in)
{
	struct weston_keyboard *keyboard =
		weston_seat_get_keyboard(&b->core_seat);
	struct weston_xkb_info *info = keyboard->xkb_info;
	uint32_t ret = 0;

	if ((in & KEYMOD_SHIFT_LOCK) && info->shift_mod != XKB_MOD_INVALID)
		ret |= (1 << info->shift_mod);
	if ((in & KEYMOD_CTRL_LOCK) && info->ctrl_mod != XKB_MOD_INVALID)
		ret |= (1 << info->ctrl_mod);
	if ((in & KEYMOD_ALT_LOCK) && info->alt_mod != XKB_MOD_INVALID)
		ret |= (1 << info->alt_mod);
	if ((in & KEYMOD_MOD8_LOCK) && info->super_mod != XKB_MOD_INVALID)
		ret |= (1 << info->super_mod);

	return ret;
}

static uint32_t
get_xkb_locked_mods(struct qnx_screen_backend *b, int in)
{
	struct weston_keyboard *keyboard =
		weston_seat_get_keyboard(&b->core_seat);
	struct weston_xkb_info *info = keyboard->xkb_info;
	uint32_t ret = 0;

	if ((in & KEYMOD_CAPS_LOCK) && info->caps_mod != XKB_MOD_INVALID)
		ret |= (1 << info->caps_mod);
	if ((in & KEYMOD_NUM_LOCK) && info->mod2_mod != XKB_MOD_INVALID)
		ret |= (1 << info->mod2_mod);
	if ((in & KEYMOD_SCROLL_LOCK) && info->mod3_mod != XKB_MOD_INVALID)
		ret |= (1 << info->mod3_mod);

	return ret;
}

static int
qnx_screen_input_create(struct qnx_screen_backend *b, int no_input)
{
	weston_seat_init(&b->core_seat, b->compositor, "default");

	if (no_input)
		return 0;

	weston_seat_init_pointer(&b->core_seat);
	weston_seat_init_touch(&b->core_seat);

	if (weston_seat_init_keyboard(&b->core_seat, NULL) < 0)
		return -1;

	b->touch_device = weston_touch_create_touch_device(b->core_seat.touch_state, "touch0", NULL, NULL);
	if (!b->touch_device)
		return -1;

	return 0;
}

static void
qnx_screen_input_destroy(struct qnx_screen_backend *b)
{
	if (b->touch_device) {
		weston_touch_device_destroy(b->touch_device);
		b->touch_device = NULL;
	}
	weston_seat_release(&b->core_seat);
}

static void
finish_frame_handler(void *data)
{
	struct qnx_screen_output *output = data;
	struct timespec ts;

	output->finish_frame_task = NULL;
	weston_compositor_read_presentation_clock(output->base.compositor, &ts);
	weston_output_finish_frame(&output->base, &ts, 0);
}

static int
qnx_screen_output_start_repaint_loop(struct weston_output *output)
{
	struct timespec ts;

	weston_compositor_read_presentation_clock(output->compositor, &ts);
	weston_output_finish_frame(output, &ts, WP_PRESENTATION_FEEDBACK_INVALID);

	return 0;
}

static int
qnx_screen_output_repaint_gl(struct weston_output *output_base,
		      pixman_region32_t *damage)
{
	struct qnx_screen_output *output = to_qnx_screen_output(output_base);
	struct weston_compositor *ec = output->base.compositor;

	struct wl_event_loop *loop = wl_display_get_event_loop(ec->wl_display);;
	output->finish_frame_task = wl_event_loop_add_idle(loop, finish_frame_handler, output);

	ec->renderer->repaint_output(output_base, damage);

	pixman_region32_subtract(&ec->primary_plane.damage,
				 &ec->primary_plane.damage, damage);

	return 0;
}

#if defined(NO_NO_NOT_YET)
static void
set_clip_for_output(struct weston_output *output_base, pixman_region32_t *region)
{
	struct qnx_screen_output *output = to_qnx_screen_output(output_base);
	struct weston_compositor *ec = output->base.compositor;
	struct qnx_screen_backend *b = to_qnx_screen_backend(ec);
	pixman_region32_t transformed_region;
	pixman_box32_t *rects;
	xcb_rectangle_t *output_rects;
	xcb_void_cookie_t cookie;
	int nrects, i;
	xcb_generic_error_t *err;

	pixman_region32_init(&transformed_region);
	pixman_region32_copy(&transformed_region, region);
	pixman_region32_translate(&transformed_region,
				  -output_base->x, -output_base->y);
	weston_transformed_region(output_base->width, output_base->height,
				  output_base->transform,
				  output_base->current_scale,
				  &transformed_region, &transformed_region);

	rects = pixman_region32_rectangles(&transformed_region, &nrects);
	output_rects = calloc(nrects, sizeof(xcb_rectangle_t));

	if (output_rects == NULL) {
		pixman_region32_fini(&transformed_region);
		return;
	}

	for (i = 0; i < nrects; i++) {
		output_rects[i].x = rects[i].x1;
		output_rects[i].y = rects[i].y1;
		output_rects[i].width = rects[i].x2 - rects[i].x1;
		output_rects[i].height = rects[i].y2 - rects[i].y1;
	}

	pixman_region32_fini(&transformed_region);

	cookie = xcb_set_clip_rectangles_checked(b->conn, XCB_CLIP_ORDERING_UNSORTED,
					output->gc,
					0, 0, nrects,
					output_rects);
	err = xcb_request_check(b->conn, cookie);
	if (err != NULL) {
		weston_log("Failed to set clip rects, err: %d\n", err->error_code);
		free(err);
	}
	free(output_rects);
}
#endif

static int
qnx_screen_output_repaint_shm(struct weston_output *output_base,
		       pixman_region32_t *damage)
{
#if defined(NO_NO_NOT_YET)
	struct qnx_screen_output *output = to_qnx_screen_output(output_base);
	struct weston_compositor *ec = output->base.compositor;
	struct qnx_screen_backend *b = to_qnx_screen_backend(ec);
	xcb_void_cookie_t cookie;
	xcb_generic_error_t *err;

	pixman_renderer_output_set_buffer(output_base, output->hw_surface);
	ec->renderer->repaint_output(output_base, damage);

	pixman_region32_subtract(&ec->primary_plane.damage,
				 &ec->primary_plane.damage, damage);
	set_clip_for_output(output_base, damage);
	cookie = xcb_shm_put_image_checked(b->conn, output->window, output->gc,
					pixman_image_get_width(output->hw_surface),
					pixman_image_get_height(output->hw_surface),
					0, 0,
					pixman_image_get_width(output->hw_surface),
					pixman_image_get_height(output->hw_surface),
					0, 0, output->depth, XCB_IMAGE_FORMAT_Z_PIXMAP,
					0, output->segment, 0);
	err = xcb_request_check(b->conn, cookie);
	if (err != NULL) {
		weston_log("Failed to put shm image, err: %d\n", err->error_code);
		free(err);
	}

	wl_event_source_timer_update(output->finish_frame_timer, 10);
#endif
	return 0;
}

static void
qnx_screen_output_deinit_shm(struct qnx_screen_backend *b, struct qnx_screen_output *output)
{
#if defined(NO_NO_NOT_YET)
	xcb_void_cookie_t cookie;
	xcb_generic_error_t *err;
	xcb_free_gc(b->conn, output->gc);

	pixman_image_unref(output->hw_surface);
	output->hw_surface = NULL;
	cookie = xcb_shm_detach_checked(b->conn, output->segment);
	err = xcb_request_check(b->conn, cookie);
	if (err) {
		weston_log("xcb_shm_detach failed, error %d\n", err->error_code);
		free(err);
	}
	shmdt(output->buf);
#endif
}

static int
qnx_screen_output_init_shm(struct qnx_screen_backend *b, struct qnx_screen_output *output,
	int width, int height)
{
#if defined(NO_NO_NOT_YET)
	xcb_visualtype_t *visual_type;
	xcb_screen_t *screen;
	xcb_format_iterator_t fmt;
	xcb_void_cookie_t cookie;
	xcb_generic_error_t *err;
	const xcb_query_extension_reply_t *ext;
	int bitsperpixel = 0;
	pixman_format_code_t pixman_format;

	/* Check if SHM is available */
	ext = xcb_get_extension_data(b->conn, &xcb_shm_id);
	if (ext == NULL || !ext->present) {
		/* SHM is missing */
		weston_log("SHM extension is not available\n");
		errno = ENOENT;
		return -1;
	}

	screen = qnx_screen_compositor_get_default_screen(b);
	visual_type = find_visual_by_id(screen, screen->root_visual);
	if (!visual_type) {
		weston_log("Failed to lookup visual for root window\n");
		errno = ENOENT;
		return -1;
	}
	weston_log("Found visual, bits per value: %d, red_mask: %.8x, green_mask: %.8x, blue_mask: %.8x\n",
		visual_type->bits_per_rgb_value,
		visual_type->red_mask,
		visual_type->green_mask,
		visual_type->blue_mask);
	output->depth = get_depth_of_visual(screen, screen->root_visual);
	weston_log("Visual depth is %d\n", output->depth);

	for (fmt = xcb_setup_pixmap_formats_iterator(xcb_get_setup(b->conn));
	     fmt.rem;
	     xcb_format_next(&fmt)) {
		if (fmt.data->depth == output->depth) {
			bitsperpixel = fmt.data->bits_per_pixel;
			break;
		}
	}
	weston_log("Found format for depth %d, bpp: %d\n",
		output->depth, bitsperpixel);

	if  (bitsperpixel == 32 &&
	     visual_type->red_mask == 0xff0000 &&
	     visual_type->green_mask == 0x00ff00 &&
	     visual_type->blue_mask == 0x0000ff) {
		weston_log("Will use x8r8g8b8 format for SHM surfaces\n");
		pixman_format = PIXMAN_x8r8g8b8;
	} else if (bitsperpixel == 16 &&
		   visual_type->red_mask == 0x00f800 &&
		   visual_type->green_mask == 0x0007e0 &&
		   visual_type->blue_mask == 0x00001f) {
		weston_log("Will use r5g6b5 format for SHM surfaces\n");
		pixman_format = PIXMAN_r5g6b5;
	} else {
		weston_log("Can't find appropriate format for SHM pixmap\n");
		errno = ENOTSUP;
		return -1;
	}


	/* Create SHM segment and attach it */
	output->shm_id = shmget(IPC_PRIVATE, width * height * (bitsperpixel / 8), IPC_CREAT | S_IRWXU);
	if (output->shm_id == -1) {
		weston_log("screenshm: failed to allocate SHM segment\n");
		return -1;
	}
	output->buf = shmat(output->shm_id, NULL, 0 /* read/write */);
	if (-1 == (long)output->buf) {
		weston_log("screenshm: failed to attach SHM segment\n");
		return -1;
	}
	output->segment = xcb_generate_id(b->conn);
	cookie = xcb_shm_attach_checked(b->conn, output->segment, output->shm_id, 1);
	err = xcb_request_check(b->conn, cookie);
	if (err) {
		weston_log("screenshm: xcb_shm_attach error %d, op code %d, resource id %d\n",
			   err->error_code, err->major_code, err->minor_code);
		free(err);
		return -1;
	}

	shmctl(output->shm_id, IPC_RMID, NULL);

	/* Now create pixman image */
	output->hw_surface = pixman_image_create_bits(pixman_format, width, height, output->buf,
		width * (bitsperpixel / 8));

	output->gc = xcb_generate_id(b->conn);
	xcb_create_gc(b->conn, output->gc, output->window, 0, NULL);
#endif

	return 0;
}

static int
qnx_screen_output_switch_mode(struct weston_output *base, struct weston_mode *mode)
{
	struct qnx_screen_backend *b;
	struct qnx_screen_output *output;
	int ret;

	if (base == NULL) {
		weston_log("output is NULL.\n");
		return -1;
	}

	if (mode == NULL) {
		weston_log("mode is NULL.\n");
		return -1;
	}

	b = to_qnx_screen_backend(base->compositor);
	output = to_qnx_screen_output(base);

	if (mode->width == output->mode.width &&
	    mode->height == output->mode.height)
		return 0;

	if (mode->width < WINDOW_MIN_WIDTH || mode->width > WINDOW_MAX_WIDTH)
		return -1;

	if (mode->height < WINDOW_MIN_HEIGHT || mode->height > WINDOW_MAX_HEIGHT)
		return -1;

	int screen_size[] = { mode->width, mode->height };
	screen_set_window_property_iv(output->window, SCREEN_PROPERTY_SIZE, screen_size);
	screen_set_window_property_iv(output->window, SCREEN_PROPERTY_BUFFER_SIZE, screen_size);
	screen_set_session_property_iv(output->session, SCREEN_PROPERTY_SIZE, screen_size);
	screen_create_window_buffers(output->window, 2);

	output->mode.width = mode->width;
	output->mode.height = mode->height;

	if (b->use_pixman) {
		const struct pixman_renderer_output_options options = {
			.use_shadow = true,
		};

		pixman_renderer_output_destroy(&output->base);
		qnx_screen_output_deinit_shm(b, output);

		if (qnx_screen_output_init_shm(b, output,
					output->base.current_mode->width,
					output->base.current_mode->height) < 0) {
			weston_log("Failed to initialize SHM for the X11 output\n");
			return -1;
		}

		if (pixman_renderer_output_create(&output->base, &options) < 0) {
			weston_log("Failed to create pixman renderer for output\n");
			qnx_screen_output_deinit_shm(b, output);
			return -1;
		}
	} else {
		const struct gl_renderer_output_options options = {
			.window_for_legacy = output->window,
			.window_for_platform = (void *)(intptr_t)(output->window),
			.drm_formats = qnx_screen_formats,
			.drm_formats_count = ARRAY_LENGTH(qnx_screen_formats),
		};

		gl_renderer->output_destroy(&output->base);

		ret = gl_renderer->output_window_create(&output->base, &options);
		if (ret < 0)
			return -1;
	}

	return 0;
}

static int
qnx_screen_output_disable(struct weston_output *base)
{
	struct qnx_screen_output *output = to_qnx_screen_output(base);
	struct qnx_screen_backend *backend = to_qnx_screen_backend(base->compositor);

	if (!output->base.enabled)
		return 0;

	if (output->finish_frame_task)
		wl_event_source_remove(output->finish_frame_task);

	if (backend->use_pixman) {
		pixman_renderer_output_destroy(&output->base);
		qnx_screen_output_deinit_shm(backend, output);
	} else {
		gl_renderer->output_destroy(&output->base);
	}

	screen_destroy_session(output->session);
	output->window = NULL;
	screen_destroy_window(output->window);
	output->window = NULL;

	return 0;
}

static void
qnx_screen_output_destroy(struct weston_output *base)
{
	struct qnx_screen_output *output = to_qnx_screen_output(base);

	qnx_screen_output_disable(&output->base);
	weston_output_release(&output->base);

	free(output);
}

static int
qnx_screen_output_enable(struct weston_output *base)
{
	struct qnx_screen_output *output = to_qnx_screen_output(base);
	struct qnx_screen_backend *b = to_qnx_screen_backend(base->compositor);
	const struct weston_mode *mode = output->base.current_mode;
	int ret;

	screen_create_window(&output->window, b->context);
	screen_set_window_property_pv(output->window, SCREEN_PROPERTY_DISPLAY, (void**)(&output->display));
	int screen_usage[] = { SCREEN_USAGE_OPENGL_ES2 };
	if (b->use_pixman)
		screen_usage[0] = SCREEN_USAGE_NATIVE | SCREEN_USAGE_READ | SCREEN_USAGE_WRITE;
	screen_set_window_property_iv(output->window, SCREEN_PROPERTY_USAGE, screen_usage);
	int screen_format[] = { SCREEN_FORMAT_RGBX8888 };
	screen_set_window_property_iv(output->window, SCREEN_PROPERTY_FORMAT, screen_format);
	int screen_position[] = { output->x, output->y };
	screen_set_window_property_iv(output->window, SCREEN_PROPERTY_POSITION, screen_position);
	int screen_size[] = { mode->width, mode->height };
	screen_set_window_property_iv(output->window, SCREEN_PROPERTY_SIZE, screen_size);
	screen_set_window_property_iv(output->window, SCREEN_PROPERTY_BUFFER_SIZE, screen_size);
	int screen_sensitivity = SCREEN_SENSITIVITY_NEVER;
	if (b->no_input)
		screen_set_window_property_iv(output->window, SCREEN_PROPERTY_SENSITIVITY, &screen_sensitivity);

	if (output->window) {
		screen_create_session_type(&output->session, b->context, SCREEN_EVENT_POINTER);
		screen_set_session_property_pv(output->session, SCREEN_PROPERTY_WINDOW, (void **)(&output->window));
		screen_set_session_property_iv(output->session, SCREEN_PROPERTY_SIZE, screen_size);
		int screen_cursor[] = { SCREEN_CURSOR_SHAPE_NONE };
		screen_set_session_property_iv(output->session, SCREEN_PROPERTY_CURSOR, screen_cursor);
		if (b->no_input)
			screen_set_session_property_iv(output->session, SCREEN_PROPERTY_SENSITIVITY, &screen_sensitivity);
	}

	screen_create_window_buffers(output->window, 2);

	if (b->use_pixman) {
		const struct pixman_renderer_output_options options = {
			.use_shadow = true,
		};

		if (qnx_screen_output_init_shm(b, output,
					mode->width,
					mode->height) < 0) {
			weston_log("Failed to initialize SHM for the QNX screen output\n");
			goto err;
		}
		if (pixman_renderer_output_create(&output->base, &options) < 0) {
			weston_log("Failed to create pixman renderer for output\n");
			qnx_screen_output_deinit_shm(b, output);
			goto err;
		}

		output->base.repaint = qnx_screen_output_repaint_shm;
	} else {
		const struct gl_renderer_output_options options = {
			.window_for_legacy = output->window,
			.window_for_platform = (void *)(intptr_t)(output->window),
			.drm_formats = qnx_screen_formats,
			.drm_formats_count = ARRAY_LENGTH(qnx_screen_formats),
		};

		ret = gl_renderer->output_window_create( &output->base, &options);
		if (ret < 0)
			goto err;

		output->base.repaint = qnx_screen_output_repaint_gl;
	}

	output->base.start_repaint_loop = qnx_screen_output_start_repaint_loop;
	output->base.assign_planes = NULL;
	output->base.set_backlight = NULL;
	output->base.set_dpms = NULL;
	output->base.switch_mode = qnx_screen_output_switch_mode;

	int window_id = 0;
	screen_get_window_property_iv(output->window, SCREEN_PROPERTY_ID, &window_id);
	weston_log("QNX screen output %dx%d, window id %d\n",
		   mode->width,
		   mode->height,
		   window_id);

	return 0;

err:
	screen_destroy_session(output->session);
	output->session = NULL;
	screen_destroy_window(output->window);
	output->window = NULL;

	return -1;
}

static int
qnx_screen_output_set_size(struct weston_output *base, int width, int height)
{
	struct qnx_screen_output *output = to_qnx_screen_output(base);
	struct qnx_screen_backend *b = to_qnx_screen_backend(base->compositor);
	struct weston_head *head;
	int output_width, output_height;

	/* We can only be called once. */
	assert(!output->base.current_mode);

	/* Make sure we have scale set. */
	assert(output->base.scale);

	if (width < WINDOW_MIN_WIDTH) {
		weston_log("Invalid width \"%d\" for output %s\n",
			   width, output->base.name);
		return -1;
	}

	if (height < WINDOW_MIN_HEIGHT) {
		weston_log("Invalid height \"%d\" for output %s\n",
			   height, output->base.name);
		return -1;
	}

	output_width = width * output->base.scale;
	output_height = height * output->base.scale;

	int size_in_millimeters[] = { output_width, output_height };
	int size_in_pixels[] = { output_width, output_height };
	screen_get_display_property_iv(output->display, SCREEN_PROPERTY_PHYSICAL_SIZE, size_in_millimeters);
	screen_get_display_property_iv(output->display, SCREEN_PROPERTY_SIZE, size_in_pixels);

	if (b->fullscreen) {
		width = size_in_pixels[0] / output->base.scale;
		height = size_in_pixels[1] / output->base.scale;
		output_width = width * output->base.scale;
		output_height = height * output->base.scale;
	}

	wl_list_for_each(head, &output->base.head_list, output_link) {
		weston_head_set_monitor_strings(head, "weston-qnx-screen", "none", NULL);
		weston_head_set_physical_size(head,
			width * size_in_millimeters[0] / size_in_pixels[0],
			height * size_in_millimeters[1] / size_in_pixels[1]);
	}

	output->mode.flags =
		WL_OUTPUT_MODE_CURRENT | WL_OUTPUT_MODE_PREFERRED;

	output->mode.width = output_width;
	output->mode.height = output_height;
	output->mode.refresh = 60000;
	output->native = output->mode;
	output->scale = output->base.scale;
	wl_list_insert(&output->base.mode_list, &output->mode.link);

	output->base.current_mode = &output->mode;

	output->base.native_mode = &output->native;
	output->base.native_scale = output->base.scale;

	return 0;
}

static int
qnx_screen_output_set_position(struct weston_output *base, int x, int y)
{
	struct qnx_screen_output *output = to_qnx_screen_output(base);
	struct qnx_screen_backend *b = to_qnx_screen_backend(base->compositor);

	if (b->fullscreen)
		return 0;

	output->x = x;
	output->y = y;

	return 0;
}

static int
qnx_screen_output_set_display(struct weston_output *base, int display_id)
{
	if (display_id == 0)
		return 0;

	struct qnx_screen_output *output = to_qnx_screen_output(base);
	struct qnx_screen_backend *b = to_qnx_screen_backend(base->compositor);

	int screen_display_count = 0;
	screen_get_context_property_iv(b->context, SCREEN_PROPERTY_DISPLAY_COUNT, &screen_display_count);
	if (screen_display_count <= 0)
		return -1;

	screen_display_t *screen_displays;
	screen_displays = calloc(screen_display_count, sizeof(screen_displays[0]));
	if (!screen_displays)
		return -1;

	screen_get_context_property_pv(b->context, SCREEN_PROPERTY_DISPLAYS, (void*)(screen_displays));
	for (int i = 0; i < screen_display_count; ++i) {
		int actual_id = 0;
		screen_get_display_property_iv(screen_displays[i], SCREEN_PROPERTY_ID, &actual_id);
		if (actual_id == display_id) {
			output->display = screen_displays[i];
			free(screen_displays);
			return 0;
		}
	}

	free(screen_displays);
	return -1;
}

static struct weston_output *
qnx_screen_output_create(struct weston_compositor *compositor, const char *name)
{
	struct qnx_screen_backend *b = to_qnx_screen_backend(compositor);
	struct qnx_screen_output *output;

	/* name can't be NULL. */
	assert(name);

	output = zalloc(sizeof *output);
	if (!output)
		return NULL;

	weston_output_init(&output->base, compositor, name);

	output->base.destroy = qnx_screen_output_destroy;
	output->base.disable = qnx_screen_output_disable;
	output->base.enable = qnx_screen_output_enable;
	output->base.attach_head = NULL;

	weston_compositor_add_pending_output(&output->base, compositor);

	output->display = b->display;

	return &output->base;
}

static int
qnx_screen_head_create(struct weston_compositor *compositor, const char *name)
{
	struct qnx_screen_head *head;

	assert(name);

	head = zalloc(sizeof *head);
	if (!head)
		return -1;

	weston_head_init(&head->base, name);

	head->base.backend_id = qnx_screen_head_destroy;

	weston_head_set_connection_status(&head->base, true);
	weston_compositor_add_head(compositor, &head->base);

	return 0;
}

static void
qnx_screen_head_destroy(struct weston_head *base)
{
	struct qnx_screen_head *head = to_qnx_screen_head(base);

	assert(head);

	weston_head_release(&head->base);
	free(head);
}

static struct qnx_screen_output *
qnx_screen_backend_find_output(struct qnx_screen_backend *b, screen_window_t window)
{
	struct qnx_screen_output *output;

	wl_list_for_each(output, &b->compositor->output_list, base.link) {
		if (output->window == window)
			return output;
	}

	return NULL;
}

static void
update_xkb_state_from_screen(struct qnx_screen_backend *b, int screen_mask)
{
	if (b->left_gui_state == SCREEN_KEY_DOWN || b->right_gui_state == SCREEN_KEY_DOWN)
		screen_mask |= KEYMOD_MOD8;

	if (screen_mask == b->prev_modifiers)
		return;

	b->prev_modifiers = screen_mask;

	struct weston_keyboard *keyboard
		= weston_seat_get_keyboard(&b->core_seat);

	// With this implementation, the QNX keymap dictates modifier behavior
	// instead of the XKB keymap.  :-(
	// Even though I'm not all that impressed with XKB, I think that the
	// best way to fix this would be to give screen the ability to use
	// XKB keymaps (as a configuration alternative).
	xkb_state_update_mask(keyboard->xkb_state.state,
			      get_xkb_base_mods(b, screen_mask),
			      get_xkb_latched_mods(b, screen_mask),
			      get_xkb_locked_mods(b, screen_mask),
			      0,
			      0,
			      0);
	notify_modifiers(&b->core_seat,
			 wl_display_next_serial(b->compositor->wl_display));
}

static enum wl_pointer_button_state to_wl_pointer_button_state(int value)
{
	return value ? WL_POINTER_BUTTON_STATE_PRESSED : WL_POINTER_BUTTON_STATE_RELEASED;
}

static void
qnx_screen_backend_deliver_pointer_button_event(struct qnx_screen_backend *b,
				                int buttons,
						int button_mask,
						int button_name)
{
	if ((buttons & button_mask) != (b->prev_buttons & button_mask)) {
		struct timespec time;
		weston_compositor_get_time(&time);
		notify_button(&b->core_seat, &time, button_name,
				to_wl_pointer_button_state(buttons & button_mask));
		notify_pointer_frame(&b->core_seat);
	}
}

static void
qnx_screen_backend_deliver_pointer_event(struct qnx_screen_backend *b,
				         screen_event_t event)
{
	struct qnx_screen_output *output, *prev_output;
	double x, y;
	struct weston_pointer_motion_event motion_event = { 0 };
	screen_window_t window;
	int position[] = { b->prev_x, b->prev_y };
	int buttons = b->prev_buttons;
	int screen_modifiers = b->prev_modifiers;
	struct timespec time;

	screen_get_event_property_pv(event, SCREEN_PROPERTY_WINDOW, (void **)(&window));
	screen_get_event_property_iv(event, SCREEN_PROPERTY_SOURCE_POSITION, position);
	screen_get_event_property_iv(event, SCREEN_PROPERTY_BUTTONS, &buttons);
	screen_get_event_property_iv(event, SCREEN_PROPERTY_MODIFIERS, &screen_modifiers);

	update_xkb_state_from_screen(b, screen_modifiers);

	output = qnx_screen_backend_find_output(b, window);
	if (!output)
		return;

	if (position[0] < 0)
		position[0] = 0;
	if (position[1] < 0)
		position[1] = 0;
	if (position[0] >= output->base.current_mode->width)
		position[0] = output->base.current_mode->width - 1;
	if (position[1] >= output->base.current_mode->height)
		position[1] = output->base.current_mode->height - 1;

	prev_output = qnx_screen_backend_find_output(b, b->prev_window);

	if (output != prev_output) {
		// Generate artifical LEAVE/ENTER.
		notify_pointer_focus(&b->core_seat, NULL, 0, 0);
		notify_pointer_focus(&b->core_seat, &output->base, x, y);
		b->prev_x = x;
		b->prev_y = y;
	}

	weston_output_transform_coordinate(&output->base,
					   position[0],
					   position[1],
					   &x, &y);

	motion_event = (struct weston_pointer_motion_event) {
		.mask = WESTON_POINTER_MOTION_REL,
		.dx = x - b->prev_x,
		.dy = y - b->prev_y
	};

	weston_compositor_get_time(&time);
	if ((x != b->prev_x) || (y != b->prev_y)) {
		notify_motion(&b->core_seat, &time, &motion_event);
		notify_pointer_frame(&b->core_seat);
	}

	if (buttons != b->prev_buttons) {
		qnx_screen_backend_deliver_pointer_button_event(b, buttons, 0x1, BTN_LEFT);
		qnx_screen_backend_deliver_pointer_button_event(b, buttons, 0x2, BTN_MIDDLE);
		qnx_screen_backend_deliver_pointer_button_event(b, buttons, 0x4, BTN_RIGHT);
	}

	b->prev_window = window;
	b->prev_x = x;
	b->prev_y = y;
	b->prev_buttons = buttons;
}

static void
qnx_screen_backend_deliver_keyboard_event(struct qnx_screen_backend *b,
					  screen_event_t event)
{
	int screen_modifiers = b->prev_modifiers;
	int screen_flags = 0;
	int screen_page = HIDD_PAGE_KEYBOARD;
	int screen_scan = HIDD_USAGE_KEYBOARD_UNDEFINED;
	struct timespec time;

	screen_get_event_property_iv(event, SCREEN_PROPERTY_MODIFIERS, &screen_modifiers);
	screen_get_event_property_iv(event, SCREEN_PROPERTY_FLAGS, &screen_flags);
	screen_get_event_property_iv(event, SCREEN_PROPERTY_KEY_PAGE, &screen_page);
	screen_get_event_property_iv(event, SCREEN_PROPERTY_SCAN, &screen_scan);

	weston_compositor_get_time(&time);

	if (screen_scan == KEY_LEFTMETA)
		b->left_gui_state = screen_flags & SCREEN_KEY_DOWN;
	else if (screen_scan == KEY_RIGHTMETA)
		b->right_gui_state = screen_flags & SCREEN_KEY_DOWN;

	update_xkb_state_from_screen(b, screen_modifiers);

	notify_key(&b->core_seat,
		   &time,
		   screen_scan,
		   screen_flags & SCREEN_KEY_DOWN ? WL_KEYBOARD_KEY_STATE_PRESSED : WL_KEYBOARD_KEY_STATE_RELEASED,
		   STATE_UPDATE_NONE);
}

static void
qnx_screen_backend_deliver_touch_event(struct qnx_screen_backend *b,
				       screen_event_t event,
				       int type)
{
	struct qnx_screen_output *output;
	double x, y;
	screen_window_t screen_window;
	int screen_id = 0;
	int screen_position[] = { 0, 0 };
	int screen_modifiers = b->prev_modifiers;
	struct timespec time;

	screen_get_event_property_pv(event, SCREEN_PROPERTY_WINDOW, (void **)(&screen_window));
	screen_get_event_property_iv(event, SCREEN_PROPERTY_TOUCH_ID, &screen_id);
	screen_get_event_property_iv(event, SCREEN_PROPERTY_SOURCE_POSITION, screen_position);
	screen_get_event_property_iv(event, SCREEN_PROPERTY_MODIFIERS, &screen_modifiers);

	update_xkb_state_from_screen(b, screen_modifiers);

	output = qnx_screen_backend_find_output(b, screen_window);
	if (!output)
		return;

	weston_output_transform_coordinate(&output->base,
					   screen_position[0],
					   screen_position[1],
					   &x, &y);

	weston_compositor_get_time(&time);
	notify_touch(b->touch_device, &time, screen_id, x, y, type);
	notify_touch_frame(b->touch_device);
}

static void
qnx_screen_backend_deliver_property_size_event(struct qnx_screen_backend *b,
					       screen_event_t event,
					       struct qnx_screen_output *output,
					       screen_window_t screen_window)
{
	struct weston_mode mode = output->mode;
	int screen_size[] = { mode.width, mode.height };
	screen_get_window_property_iv(screen_window, SCREEN_PROPERTY_SIZE, screen_size);

	if (mode.width == screen_size[0] && mode.height == screen_size[1])
		return;

	mode.width = screen_size[0];
	mode.height = screen_size[1];

	if (weston_output_mode_set_native(&output->base,
					  &mode, output->scale) < 0)
		weston_log("Mode switch failed\n");
}

static void
qnx_screen_backend_deliver_property_focus_event(struct qnx_screen_backend *b,
						screen_event_t event,
						struct qnx_screen_output *output,
						screen_window_t screen_window)
{
	int screen_focus = 0;
	screen_get_window_property_iv(screen_window, SCREEN_PROPERTY_FOCUS, &screen_focus);

	if (screen_focus) {
		// screen doesn't provide information on already pressed keys.
		struct wl_array keys;
		wl_array_init(&keys);
		notify_keyboard_focus_in(&b->core_seat, &keys,
					 STATE_UPDATE_AUTOMATIC);
		wl_array_release(&keys);
	} else {
		notify_keyboard_focus_out(&b->core_seat);
	}
}

static int
qnx_screen_backend_deliver_property_event(struct qnx_screen_backend *b,
				          screen_event_t event)
{
	struct qnx_screen_output *output;
	screen_window_t screen_window;
	int screen_property = SCREEN_PROPERTY_NONE;
	int count = 0;

	screen_get_event_property_pv(event, SCREEN_PROPERTY_WINDOW, (void **)(&screen_window));
	screen_get_event_property_iv(event, SCREEN_PROPERTY_NAME, &screen_property);

	output = qnx_screen_backend_find_output(b, screen_window);
	if (!output)
		return count;

	switch (screen_property) {
	case SCREEN_PROPERTY_SIZE:
		qnx_screen_backend_deliver_property_size_event(b, event, output, screen_window);
		++count;
		break;
	case SCREEN_PROPERTY_FOCUS:
		qnx_screen_backend_deliver_property_focus_event(b, event, output, screen_window);
		++count;
		break;
	}

	return count;
}

static int
qnx_screen_backend_handle_event(int fd, uint32_t mask, void *data)
{
	struct qnx_screen_backend *b = data;
	char ch;
	int count;
	while (read(fd, &ch, sizeof(ch)) == sizeof(ch))
		;
	qnx_screen_event_monitor_arm(b->event_monitor);
	screen_event_t e = NULL;
	screen_create_event(&e);
	if (!e)
		return 0;

	count = 0;
	while (screen_get_event(b->context, e, 0) == 0) {
		int type = SCREEN_EVENT_NONE;
		screen_get_event_property_iv(e, SCREEN_PROPERTY_TYPE, &type);
		if (type == SCREEN_EVENT_NONE)
			break;

		switch (type) {
		case SCREEN_EVENT_POINTER:
			qnx_screen_backend_deliver_pointer_event(b, e);
			++count;
			break;
		case SCREEN_EVENT_KEYBOARD:
			qnx_screen_backend_deliver_keyboard_event(b, e);
			++count;
			break;
		case SCREEN_EVENT_MTOUCH_TOUCH:
			qnx_screen_backend_deliver_touch_event(b, e, WL_TOUCH_DOWN);
			++count;
			break;
		case SCREEN_EVENT_MTOUCH_RELEASE:
			qnx_screen_backend_deliver_touch_event(b, e, WL_TOUCH_UP);
			++count;
			break;
		case SCREEN_EVENT_MTOUCH_MOVE:
			qnx_screen_backend_deliver_touch_event(b, e, WL_TOUCH_MOTION);
			++count;
			break;
		case SCREEN_EVENT_PROPERTY:
			count += qnx_screen_backend_deliver_property_event(b, e);
			break;
		}
	}

	screen_destroy_event(e);
	return count;
}

static void
qnx_screen_destroy(struct weston_compositor *ec)
{
	struct qnx_screen_backend *backend = to_qnx_screen_backend(ec);
	struct weston_head *base, *next;

	wl_event_source_remove(backend->screen_source);
	qnx_screen_event_monitor_destroy(backend->event_monitor);
	qnx_screen_input_destroy(backend);

	weston_compositor_shutdown(ec); /* destroys outputs, too */

	wl_list_for_each_safe(base, next, &ec->head_list, compositor_link) {
		if (to_qnx_screen_head(base))
			qnx_screen_head_destroy(base);
	}

	screen_destroy_context(backend->context);
	free(backend);
}

static int
init_gl_renderer(struct qnx_screen_backend *b)
{
	const struct gl_renderer_display_options options = {
		.egl_platform = 0,
		.egl_native_display = (void *)(intptr_t)(b->egl_display),
		.egl_surface_type = EGL_WINDOW_BIT,
		.drm_formats = qnx_screen_formats,
		.drm_formats_count = ARRAY_LENGTH(qnx_screen_formats),
	};

	gl_renderer = weston_load_module("gl-renderer.so",
					 "gl_renderer_interface");
	if (!gl_renderer)
		return -1;

	return gl_renderer->display_create(b->compositor, &options);
}

static const struct weston_windowed_output_api api = {
	qnx_screen_output_set_size,
	qnx_screen_head_create,
};

static const struct weston_qnx_screen_output_api qnx_api = {
	qnx_screen_output_set_position,
	qnx_screen_output_set_display,
};

static struct qnx_screen_backend *
qnx_screen_backend_create(struct weston_compositor *compositor,
		   struct weston_qnx_screen_backend_config *config)
{
	struct qnx_screen_backend *b;
	struct wl_event_loop *loop;
	int ret;

	b = zalloc(sizeof *b);
	if (b == NULL)
		return NULL;

	b->compositor = compositor;
	b->fullscreen = config->fullscreen;
	b->no_input = config->no_input;
	b->egl_display = config->egl_display;

	compositor->backend = &b->base;

	if (weston_compositor_set_presentation_clock_software(compositor) < 0)
		goto err_free;

	if (screen_create_context(&b->context, SCREEN_APPLICATION_CONTEXT) < 0)
		goto err_free;

	b->display = qnx_screen_compositor_get_default_display(b);
	wl_array_init(&b->keys);

	b->use_pixman = config->use_pixman;
	if (b->use_pixman) {
		if (pixman_renderer_init(compositor) < 0) {
			weston_log("Failed to initialize pixman renderer for QNX screen backend\n");
			goto err_context;
		}
	}
	else if (init_gl_renderer(b) < 0) {
		goto err_context;
	}
	weston_log("Using %s renderer\n", config->use_pixman ? "pixman" : "gl");

	b->base.destroy = qnx_screen_destroy;
	b->base.create_output = qnx_screen_output_create;

	if (qnx_screen_input_create(b, config->no_input) < 0) {
		weston_log("Failed to create QNX screen input\n");
		goto err_renderer;
	}

	loop = wl_display_get_event_loop(compositor->wl_display);
	b->event_monitor = qnx_screen_event_monitor_create(b->context);
	if (!b->event_monitor) {
		weston_log("Failed to create QNX screen event monitor\n");
		goto err_qnx_screen_input;
	}
	b->screen_source =
		wl_event_loop_add_fd(loop,
				     b->event_monitor->pipe_fds[0],
				     WL_EVENT_READABLE,
				     qnx_screen_backend_handle_event, b);
	wl_event_source_check(b->screen_source);

	if (compositor->renderer->import_dmabuf) {
		if (linux_dmabuf_setup(compositor) < 0)
			weston_log("Error: initializing dmabuf "
				   "support failed.\n");
	}

	if (compositor->capabilities & WESTON_CAP_EXPLICIT_SYNC) {
		if (linux_explicit_synchronization_setup(compositor) < 0)
			weston_log("Error: initializing explicit "
				   " synchronization support failed.\n");
	}

	ret = weston_plugin_api_register(compositor, WESTON_WINDOWED_OUTPUT_API_NAME,
					 &api, sizeof(api));

	if (ret < 0) {
		weston_log("Failed to register output API.\n");
		goto err_event_monitor;
	}

	ret = weston_plugin_api_register(compositor, WESTON_WINDOWED_OUTPUT_WAYLAND,
					 &qnx_api, sizeof(qnx_api));

	if (ret < 0) {
		weston_log("Failed to register QNX Screen output API.\n");
		goto err_event_monitor;
	}

	return b;

err_event_monitor:
	qnx_screen_event_monitor_destroy(b->event_monitor);
err_qnx_screen_input:
	qnx_screen_input_destroy(b);
err_renderer:
	compositor->renderer->destroy(compositor);
err_context:
	screen_destroy_context(b->context);
err_free:
	free(b);
	return NULL;
}

static void
config_init_to_defaults(struct weston_qnx_screen_backend_config *config)
{
}

WL_EXPORT int
weston_backend_init(struct weston_compositor *compositor,
		    struct weston_backend_config *config_base)
{
	struct qnx_screen_backend *b;
	struct weston_qnx_screen_backend_config config = {{ 0, }};

	if (config_base == NULL ||
	    config_base->struct_version != WESTON_QNX_SCREEN_BACKEND_CONFIG_VERSION ||
	    config_base->struct_size > sizeof(struct weston_qnx_screen_backend_config)) {
		weston_log("QNX screen backend config structure is invalid\n");
		return -1;
	}

	config_init_to_defaults(&config);
	memcpy(&config, config_base, config_base->struct_size);

	b = qnx_screen_backend_create(compositor, &config);
	if (b == NULL)
		return -1;

	return 0;
}
