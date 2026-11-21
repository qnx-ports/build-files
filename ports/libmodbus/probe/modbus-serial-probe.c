/*
 * modbus-serial-probe: report what libmodbus RTU features work on this
 * serial port. Written for QNX 8.0 (devc-ser* drivers), runs on any POSIX OS.
 *
 * Usage:
 *   modbus-serial-probe <device> [baud] [parity N|E|O] [slave addr count]
 *
 * Examples:
 *   modbus-serial-probe /dev/ser1
 *   modbus-serial-probe /dev/ser1 19200 E 1 0 4   # also read 4 holding regs
 *
 * Exit code: 0 if the port opened (and the optional read succeeded).
 *
 * SPDX-License-Identifier: BSD-3-Clause
 */
#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/ioctl.h>

#include <modbus.h>

static void report(const char *what, int rc)
{
    if (rc == 0)
        printf("  %-34s OK\n", what);
    else
        printf("  %-34s FAIL (%s)\n", what, modbus_strerror(errno));
}

/*
 * modbus_rtu_set_rts() returns 0 whenever TIOCM_RTS is defined, even if the
 * driver rejects the ioctl, so drive the RTS line directly and read it back.
 * Restores the original modem-control state.
 */
static int check_rts(int fd)
{
#ifdef TIOCM_RTS
    int saved, flags;

    if (ioctl(fd, TIOCMGET, &saved) == -1)
        return -1;

    flags = saved | TIOCM_RTS;
    if (ioctl(fd, TIOCMSET, &flags) == -1 || ioctl(fd, TIOCMGET, &flags) == -1)
        return -1;
    if (!(flags & TIOCM_RTS)) {
        errno = EIO;
        return -1;
    }

    flags &= ~TIOCM_RTS;
    if (ioctl(fd, TIOCMSET, &flags) == -1 || ioctl(fd, TIOCMGET, &flags) == -1)
        return -1;
    if (flags & TIOCM_RTS) {
        errno = EIO;
        return -1;
    }

    ioctl(fd, TIOCMSET, &saved);
    return 0;
#else
    (void) fd;
    errno = ENOTSUP;
    return -1;
#endif
}

int main(int argc, char *argv[])
{
    const char *device;
    int baud = 19200;
    char parity = 'N';
    modbus_t *ctx;
    int rc, ret = 0;

    if (argc < 2) {
        fprintf(stderr,
                "Usage: %s <device> [baud] [parity N|E|O] [slave addr count]\n",
                argv[0]);
        return 2;
    }
    device = argv[1];
    if (argc > 2)
        baud = atoi(argv[2]);
    if (argc > 3)
        parity = argv[3][0];

    printf("libmodbus %u.%u.%u at runtime (headers %s)\n",
           libmodbus_version_major, libmodbus_version_minor,
           libmodbus_version_micro, LIBMODBUS_VERSION_STRING);
    printf("Device %s, %d baud, parity %c, 8 data bits, 1 stop bit\n",
           device, baud, parity);

    ctx = modbus_new_rtu(device, baud, parity, 8, 1);
    if (ctx == NULL) {
        printf("  %-34s FAIL (%s)\n", "modbus_new_rtu", modbus_strerror(errno));
        return 1;
    }

    rc = modbus_connect(ctx);
    report("open + termios setup", rc);
    if (rc == -1) {
        modbus_free(ctx);
        return 1;
    }

    /* RS-485 mode needs Linux TIOCSRS485; expected to be unsupported on QNX. */
    rc = modbus_rtu_set_serial_mode(ctx, MODBUS_RTU_RS485);
    report("serial mode RS-485 (TIOCSRS485)", rc);
    printf("  %-34s %s\n", "current serial mode",
           modbus_rtu_get_serial_mode(ctx) == MODBUS_RTU_RS485 ? "RS-485" : "RS-232");

    /* Manual RTS direction control (modbus_rtu_set_rts) needs the driver to
     * honour TIOCMGET/TIOCMSET for TIOCM_RTS. */
    report("RTS direction control (TIOCM_RTS)", check_rts(modbus_get_socket(ctx)));

    if (argc > 6) {
        int slave = atoi(argv[4]);
        int addr = atoi(argv[5]);
        int count = atoi(argv[6]);
        uint16_t regs[125];

        if (count < 1 || count > 125)
            count = 1;
        modbus_set_slave(ctx, slave);
        modbus_set_response_timeout(ctx, 0, 500000);
        rc = modbus_read_registers(ctx, addr, count, regs);
        if (rc == -1) {
            printf("  %-34s FAIL (%s)\n", "read holding registers",
                   modbus_strerror(errno));
            ret = 1;
        } else {
            int i;
            printf("  %-34s OK, %d registers:", "read holding registers", rc);
            for (i = 0; i < rc; i++)
                printf(" %u", regs[i]);
            printf("\n");
        }
    }

    modbus_close(ctx);
    modbus_free(ctx);
    return ret;
}
