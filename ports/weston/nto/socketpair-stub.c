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

#include <errno.h>
#include <stdio.h>
#include <sys/types.h>
#include <sys/socket.h>

// Some things don't use socketpair but they link to the shared or
// shared-cairo libraries which contain a wrapper around socketpair
// in os-compatibility.c.  Stub it out to avoid the unnecessary
// library linkage creation.

// Another solution explored for this problem was the use of
// -ffunction-sections and -fdata-sections to compile and
// --gc-sections to link.  This results in the removal of
// unused functions.  At the time, it also resulted in the
// linker complaining "DSO missing from command line".  It
// appears that the processing for "DSO missing" takes place
// before the processing for --gc-sections.  The "DSO
// missing" message indicates that the object being linked
// references a function that can only be found indirectly;
// e.g., the object being linked needs shared object A, A
// needs shared object B, B defines function, the object
// being linked isn't linked to B.  If you make the object
// being linked require B, the link succeeds and the
// functions are eliminated but the requirement is not
// even though it is no longer necessary after the functions
// are eliminated.  Given this problem and the fact that
// function/data sections are not without cost (see GCC
// documentation), it's probably better to just stub out
// the function where it isn't actually needed.

int __attribute__ ((visibility("hidden")))
socketpair( int domain,
            int type,
            int protocol,
            int fd[2] )
{
	fprintf(stderr, "socketpair stub called\n");
	errno = ENOSYS;
	return -1;
}

