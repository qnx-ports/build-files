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

#if !defined(_QNX_SCREEN_EVENT_MONITOR_H_)
#define _QNX_SCREEN_EVENT_MONITOR_H_

#include <screen/screen.h>

struct qnx_screen_event_monitor {
	screen_context_t context;
	int chid;
	int coid;
	pthread_t thread;
	int pipe_fds[2];
	struct sigevent event;
};

struct qnx_screen_event_monitor *
qnx_screen_event_monitor_create(screen_context_t context);
void
qnx_screen_event_monitor_destroy(struct qnx_screen_event_monitor *m);
void
qnx_screen_event_monitor_arm(struct qnx_screen_event_monitor *m);


#endif // !defined(_QNX_SCREEN_EVENT_MONITOR_H_)

