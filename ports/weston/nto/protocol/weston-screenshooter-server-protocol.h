/* Generated by wayland-scanner 1.23.1 */

#ifndef WESTON_SCREENSHOOTER_SERVER_PROTOCOL_H
#define WESTON_SCREENSHOOTER_SERVER_PROTOCOL_H

#include <stdint.h>
#include <stddef.h>
#include "wayland-server.h"

#ifdef  __cplusplus
extern "C" {
#endif

struct wl_client;
struct wl_resource;

/**
 * @page page_weston_screenshooter The weston_screenshooter protocol
 * @section page_ifaces_weston_screenshooter Interfaces
 * - @subpage page_iface_weston_screenshooter - 
 */
struct weston_screenshooter;
struct wl_buffer;
struct wl_output;

#ifndef WESTON_SCREENSHOOTER_INTERFACE
#define WESTON_SCREENSHOOTER_INTERFACE
/**
 * @page page_iface_weston_screenshooter weston_screenshooter
 * @section page_iface_weston_screenshooter_api API
 * See @ref iface_weston_screenshooter.
 */
/**
 * @defgroup iface_weston_screenshooter The weston_screenshooter interface
 */
extern const struct wl_interface weston_screenshooter_interface;
#endif

/**
 * @ingroup iface_weston_screenshooter
 * @struct weston_screenshooter_interface
 */
struct weston_screenshooter_interface {
	/**
	 */
	void (*take_shot)(struct wl_client *client,
			  struct wl_resource *resource,
			  struct wl_resource *output,
			  struct wl_resource *buffer);
};

#define WESTON_SCREENSHOOTER_DONE 0

/**
 * @ingroup iface_weston_screenshooter
 */
#define WESTON_SCREENSHOOTER_DONE_SINCE_VERSION 1

/**
 * @ingroup iface_weston_screenshooter
 */
#define WESTON_SCREENSHOOTER_TAKE_SHOT_SINCE_VERSION 1

/**
 * @ingroup iface_weston_screenshooter
 * Sends an done event to the client owning the resource.
 * @param resource_ The client's resource
 */
static inline void
weston_screenshooter_send_done(struct wl_resource *resource_)
{
	wl_resource_post_event(resource_, WESTON_SCREENSHOOTER_DONE);
}

#ifdef  __cplusplus
}
#endif

#endif
