/* SPDX-License-Identifier: LGPL-2.1-or-later */

/** This is the original gpio.h file processed by dstep */
module gpiod;

/*
 * This file is part of libgpiod.
 *
 * Copyright (C) 2017-2018 Bartosz Golaszewski <bartekgola@gmail.com>
 */

import core.sys.posix.sys.select;

extern (C):

/**
 * @mainpage libgpiod public API
 *
 * This is the complete documentation of the public API made available to
 * users of libgpiod.
 *
 * <p>The public header is logically split into two high-level parts: the
 * simple API and the low-level API. The former allows users to easily
 * interact with the GPIOs in the system without dealing with the low-level
 * data structures and resource control. The latter gives the user much more
 * fine-grained control over the GPIO interface.
 *
 * <p>The low-level API is further logically split into several parts such
 * as: GPIO chip & line operators, iterators, GPIO events handling etc.
 *
 * <p>General note on error handling: all routines exported by libgpiod  set
 * errno to one of the error values defined in errno.h upon failure. The way
 * of notifying the caller that an error occurred varies between functions,
 * but in general a function that returns an int, returns -1 on error, while
 * a function returning a pointer bails out on error condition by returning
 * a NULL pointer.
 */

struct gpiod_chip;
struct gpiod_line;
struct gpiod_chip_iter;
struct gpiod_line_iter;

/**
 * @defgroup __common__ Common helper macros
 * @{
 *
 * Commonly used utility macros.
 */

/**
 * @brief Makes symbol visible.
 */

/**
 * @brief Marks a function argument or variable as potentially unused.
 */

/**
 * @brief Shift 1 by given offset.
 * @param nr Bit position.
 * @return 1 shifted by nr.
 */
extern (D) auto GPIOD_BIT(T)(auto ref T nr)
{
    return 1UL << nr;
}

/**
 * @brief Marks a public function as deprecated.
 */

/**
 * @}
 *
 * @defgroup __high_level__ High-level API
 * @{
 *
 * Simple high-level routines for straightforward GPIO manipulation without
 * the need to use the gpiod_* structures or to keep track of resources.
 */

/**
 * @brief Miscellaneous GPIO flags.
 */
enum
{
    GPIOD_CTXLESS_FLAG_OPEN_DRAIN = GPIOD_BIT(0),
    /**< The line is an open-drain port. */
    GPIOD_CTXLESS_FLAG_OPEN_SOURCE = GPIOD_BIT(1),
    /**< The line is an open-source port. */
    GPIOD_CTXLESS_FLAG_BIAS_DISABLE = GPIOD_BIT(2),
    /**< The line has neither either pull-up nor pull-down resistor */
    GPIOD_CTXLESS_FLAG_BIAS_PULL_DOWN = GPIOD_BIT(3),
    /**< The line has pull-down resistor enabled */
    GPIOD_CTXLESS_FLAG_BIAS_PULL_UP = GPIOD_BIT(4)
    /**< The line has pull-up resistor enabled */
}

/**
 * @brief Read current value from a single GPIO line.
 * @param device Name, path, number or label of the gpiochip.
 * @param offset Offset of the GPIO line.
 * @param active_low The active state of this line - true if low.
 * @param consumer Name of the consumer.
 * @return 0 or 1 (GPIO value) if the operation succeeds, -1 on error.
 */
int gpiod_ctxless_get_value (
    const(char)* device,
    uint offset,
    bool active_low,
    const(char)* consumer);

/**
 * @brief Read current value from a single GPIO line.
 * @param device Name, path, number or label of the gpiochip.
 * @param offset Offset of the GPIO line.
 * @param active_low The active state of this line - true if low.
 * @param consumer Name of the consumer.
 * @param flags The flags for the line.
 * @return 0 or 1 (GPIO value) if the operation succeeds, -1 on error.
 */
int gpiod_ctxless_get_value_ext (
    const(char)* device,
    uint offset,
    bool active_low,
    const(char)* consumer,
    int flags);

/**
 * @brief Read current values from a set of GPIO lines.
 * @param device Name, path, number or label of the gpiochip.
 * @param offsets Array of offsets of lines whose values should be read.
 * @param values Buffer in which the values will be stored.
 * @param num_lines Number of lines, must be > 0.
 * @param active_low The active state of the lines - true if low.
 * @param consumer Name of the consumer.
 * @return 0 if the operation succeeds, -1 on error.
 */
int gpiod_ctxless_get_value_multiple (
    const(char)* device,
    const(uint)* offsets,
    int* values,
    uint num_lines,
    bool active_low,
    const(char)* consumer);

/**
 * @brief Read current values from a set of GPIO lines.
 * @param device Name, path, number or label of the gpiochip.
 * @param offsets Array of offsets of lines whose values should be read.
 * @param values Buffer in which the values will be stored.
 * @param num_lines Number of lines, must be > 0.
 * @param active_low The active state of this line - true if low.
 * @param consumer Name of the consumer.
 * @param flags The flags for the lines.
 * @return 0 if the operation succeeds, -1 on error.
 */
int gpiod_ctxless_get_value_multiple_ext (
    const(char)* device,
    const(uint)* offsets,
    int* values,
    uint num_lines,
    bool active_low,
    const(char)* consumer,
    int flags);

/**
 * @brief Simple set value callback signature.
 */
alias gpiod_ctxless_set_value_cb = void function (void*);

/**
 * @brief Set value of a single GPIO line.
 * @param device Name, path, number or label of the gpiochip.
 * @param offset The offset of the GPIO line.
 * @param value New value (0 or 1).
 * @param active_low The active state of this line - true if low.
 * @param consumer Name of the consumer.
 * @param cb Optional callback function that will be called right after setting
 *           the value. Users can use this, for example, to pause the execution
 *           after toggling a GPIO.
 * @param data Optional user data that will be passed to the callback function.
 * @return 0 if the operation succeeds, -1 on error.
 */
int gpiod_ctxless_set_value (
    const(char)* device,
    uint offset,
    int value,
    bool active_low,
    const(char)* consumer,
    gpiod_ctxless_set_value_cb cb,
    void* data);

/**
 * @brief Set value of a single GPIO line.
 * @param device Name, path, number or label of the gpiochip.
 * @param offset The offset of the GPIO line.
 * @param value New value (0 or 1).
 * @param active_low The active state of this line - true if low.
 * @param consumer Name of the consumer.
 * @param cb Optional callback function that will be called right after setting
 *           the value. Users can use this, for example, to pause the execution
 *           after toggling a GPIO.
 * @param data Optional user data that will be passed to the callback function.
 * @param flags The flags for the line.
 * @return 0 if the operation succeeds, -1 on error.
 */
int gpiod_ctxless_set_value_ext (
    const(char)* device,
    uint offset,
    int value,
    bool active_low,
    const(char)* consumer,
    gpiod_ctxless_set_value_cb cb,
    void* data,
    int flags);

/**
 * @brief Set values of multiple GPIO lines.
 * @param device Name, path, number or label of the gpiochip.
 * @param offsets Array of offsets of lines the values of which should be set.
 * @param values Array of integers containing new values.
 * @param num_lines Number of lines, must be > 0.
 * @param active_low The active state of the lines - true if low.
 * @param consumer Name of the consumer.
 * @param cb Optional callback function that will be called right after setting
 *           all values. Works the same as in ::gpiod_ctxless_set_value.
 * @param data Optional user data that will be passed to the callback function.
 * @return 0 if the operation succeeds, -1 on error.
 */
int gpiod_ctxless_set_value_multiple (
    const(char)* device,
    const(uint)* offsets,
    const(int)* values,
    uint num_lines,
    bool active_low,
    const(char)* consumer,
    gpiod_ctxless_set_value_cb cb,
    void* data);

/**
 * @brief Set values of multiple GPIO lines.
 * @param device Name, path, number or label of the gpiochip.
 * @param offsets Array of offsets of lines the values of which should be set.
 * @param values Array of integers containing new values.
 * @param num_lines Number of lines, must be > 0.
 * @param active_low The active state of this line - true if low.
 * @param consumer Name of the consumer.
 * @param cb Optional callback function that will be called right after setting
 *           all values. Works the same as in ::gpiod_ctxless_set_value.
 * @param data Optional user data that will be passed to the callback function.
 * @param flags The flags for the lines.
 * @return 0 if the operation succeeds, -1 on error.
 */
int gpiod_ctxless_set_value_multiple_ext (
    const(char)* device,
    const(uint)* offsets,
    const(int)* values,
    uint num_lines,
    bool active_low,
    const(char)* consumer,
    gpiod_ctxless_set_value_cb cb,
    void* data,
    int flags);

/**
 * @brief Event types that the ctxless event monitor can wait for.
 */
enum
{
    /**< Wait for rising edge events only. */
    GPIOD_CTXLESS_EVENT_RISING_EDGE = 1,
    /**< Wait for falling edge events only. */
    GPIOD_CTXLESS_EVENT_FALLING_EDGE = 2,
    /**< Wait for both types of events. */
    GPIOD_CTXLESS_EVENT_BOTH_EDGES = 3
}

/**
 * @brief Event types that can be passed to the ctxless event callback.
 */
enum
{
    GPIOD_CTXLESS_EVENT_CB_TIMEOUT = 1,
    /**< Waiting for events timed out. */
    GPIOD_CTXLESS_EVENT_CB_RISING_EDGE = 2,
    /**< Rising edge event occured. */
    GPIOD_CTXLESS_EVENT_CB_FALLING_EDGE = 3
    /**< Falling edge event occured. */
}

/**
 * @brief Return status values that the ctxless event callback can return.
 */
enum
{
    GPIOD_CTXLESS_EVENT_CB_RET_ERR = -1,
    /**< Stop processing events and indicate an error. */
    GPIOD_CTXLESS_EVENT_CB_RET_OK = 0,
    /**< Continue processing events. */
    GPIOD_CTXLESS_EVENT_CB_RET_STOP = 1
    /**< Stop processing events. */
}

/**
 * @brief Simple event callback signature.
 *
 * The callback function takes the following arguments: event type (int),
 * GPIO line offset (unsigned int), event timestamp (const struct timespec *)
 * and a pointer to user data (void *).
 *
 * This callback is called by the ctxless event loop functions for each GPIO
 * event. If the callback returns ::GPIOD_CTXLESS_EVENT_CB_RET_ERR, it should
 * also set errno.
 */
alias gpiod_ctxless_event_handle_cb = int function (
    int,
    uint,
    const(timespec)*,
    void*);

/**
 * @brief Return status values that the ctxless event poll callback can return.
 *
 * Positive value returned from the polling callback indicates the number of
 * events that occurred on the set of monitored lines.
 */
enum
{
    GPIOD_CTXLESS_EVENT_POLL_RET_STOP = -2,
    /**< The event loop should stop processing events. */
    GPIOD_CTXLESS_EVENT_POLL_RET_ERR = -1,
    /**< Polling error occurred (the polling function should set errno). */
    GPIOD_CTXLESS_EVENT_POLL_RET_TIMEOUT = 0
    /**< Poll timed out. */
}

/**
 * @brief Helper structure for the ctxless event loop poll callback.
 */
struct gpiod_ctxless_event_poll_fd
{
    int fd;
    /**< File descriptor number. */
    bool event;
    /**< Indicates whether an event occurred on this file descriptor. */
}

/**
 * @brief Simple event poll callback signature.
 *
 * The poll callback function takes the following arguments: number of lines
 * (unsigned int), an array of file descriptors on which input events should
 * be monitored (struct gpiod_ctxless_event_poll_fd *), poll timeout
 * (const struct timespec *) and a pointer to user data (void *).
 *
 * The callback should poll for input events on the set of descriptors and
 * return an appropriate value that can be interpreted by the event loop
 * routine.
 */
alias gpiod_ctxless_event_poll_cb = int function (
    uint,
    gpiod_ctxless_event_poll_fd*,
    const(timespec)*,
    void*);

/**
 * @brief Wait for events on a single GPIO line.
 * @param device Name, path, number or label of the gpiochip.
 * @param offset GPIO line offset to monitor.
 * @param active_low The active state of this line - true if low.
 * @param consumer Name of the consumer.
 * @param timeout Maximum wait time for each iteration.
 * @param poll_cb Callback function to call when waiting for events.
 * @param event_cb Callback function to call for each line event.
 * @param data User data passed to the callback.
 * @return 0 if no errors were encountered, -1 if an error occurred.
 * @note The way the ctxless event loop works is described in detail in
 *       ::gpiod_ctxless_event_loop_multiple - this is just a wrapper aound
 *       this routine which calls it for a single GPIO line.
 */
int gpiod_ctxless_event_loop (
    const(char)* device,
    uint offset,
    bool active_low,
    const(char)* consumer,
    const(timespec)* timeout,
    gpiod_ctxless_event_poll_cb poll_cb,
    gpiod_ctxless_event_handle_cb event_cb,
    void* data);

/**
 * @brief Wait for events on multiple GPIO lines.
 * @param device Name, path, number or label of the gpiochip.
 * @param offsets Array of GPIO line offsets to monitor.
 * @param num_lines Number of lines to monitor.
 * @param active_low The active state of this line - true if low.
 * @param consumer Name of the consumer.
 * @param timeout Maximum wait time for each iteration.
 * @param poll_cb Callback function to call when waiting for events. Can
 *                be NULL.
 * @param event_cb Callback function to call on event occurrence.
 * @param data User data passed to the callback.
 * @return 0 no errors were encountered, -1 if an error occurred.
 * @note The poll callback can be NULL in which case the routine will fall
 *       back to a basic, ppoll() based callback.
 *
 * Internally this routine opens the GPIO chip, requests the set of lines for
 * both-edges events and calls the polling callback in a loop. The role of the
 * polling callback is to detect input events on a set of file descriptors and
 * notify the caller about the fds ready for reading.
 *
 * The ctxless event loop then reads each queued event from marked descriptors
 * and calls the event callback. Both callbacks can stop the loop at any
 * point.
 *
 * The poll_cb argument can be NULL in which case the function falls back to
 * a default, ppoll() based callback.
 */
int gpiod_ctxless_event_loop_multiple (
    const(char)* device,
    const(uint)* offsets,
    uint num_lines,
    bool active_low,
    const(char)* consumer,
    const(timespec)* timeout,
    gpiod_ctxless_event_poll_cb poll_cb,
    gpiod_ctxless_event_handle_cb event_cb,
    void* data);

/**
 * @brief Wait for events on a single GPIO line.
 * @param device Name, path, number or label of the gpiochip.
 * @param event_type Type of events to listen for.
 * @param offset GPIO line offset to monitor.
 * @param active_low The active state of this line - true if low.
 * @param consumer Name of the consumer.
 * @param timeout Maximum wait time for each iteration.
 * @param poll_cb Callback function to call when waiting for events.
 * @param event_cb Callback function to call for each line event.
 * @param data User data passed to the callback.
 * @return 0 if no errors were encountered, -1 if an error occurred.
 * @note The way the ctxless event loop works is described in detail in
 *       ::gpiod_ctxless_event_monitor_multiple - this is just a wrapper aound
 *       this routine which calls it for a single GPIO line.
 */
int gpiod_ctxless_event_monitor (
    const(char)* device,
    int event_type,
    uint offset,
    bool active_low,
    const(char)* consumer,
    const(timespec)* timeout,
    gpiod_ctxless_event_poll_cb poll_cb,
    gpiod_ctxless_event_handle_cb event_cb,
    void* data);

/**
 * @brief Wait for events on a single GPIO line.
 * @param device Name, path, number or label of the gpiochip.
 * @param event_type Type of events to listen for.
 * @param offset GPIO line offset to monitor.
 * @param active_low The active state of this line - true if low.
 * @param consumer Name of the consumer.
 * @param timeout Maximum wait time for each iteration.
 * @param poll_cb Callback function to call when waiting for events.
 * @param event_cb Callback function to call for each line event.
 * @param data User data passed to the callback.
 * @param flags The flags for the line.
 * @return 0 if no errors were encountered, -1 if an error occurred.
 * @note The way the ctxless event loop works is described in detail in
 *       ::gpiod_ctxless_event_monitor_multiple - this is just a wrapper aound
 *       this routine which calls it for a single GPIO line.
 */
int gpiod_ctxless_event_monitor_ext (
    const(char)* device,
    int event_type,
    uint offset,
    bool active_low,
    const(char)* consumer,
    const(timespec)* timeout,
    gpiod_ctxless_event_poll_cb poll_cb,
    gpiod_ctxless_event_handle_cb event_cb,
    void* data,
    int flags);

/**
 * @brief Wait for events on multiple GPIO lines.
 * @param device Name, path, number or label of the gpiochip.
 * @param event_type Type of events to listen for.
 * @param offsets Array of GPIO line offsets to monitor.
 * @param num_lines Number of lines to monitor.
 * @param active_low The active state of this line - true if low.
 * @param consumer Name of the consumer.
 * @param timeout Maximum wait time for each iteration.
 * @param poll_cb Callback function to call when waiting for events. Can
 *                be NULL.
 * @param event_cb Callback function to call on event occurrence.
 * @param data User data passed to the callback.
 * @return 0 no errors were encountered, -1 if an error occurred.
 * @note The poll callback can be NULL in which case the routine will fall
 *       back to a basic, ppoll() based callback.
 *
 * Internally this routine opens the GPIO chip, requests the set of lines for
 * the type of events specified in the event_type parameter and calls the
 * polling callback in a loop. The role of the polling callback is to detect
 * input events on a set of file descriptors and notify the caller about the
 * fds ready for reading.
 *
 * The ctxless event loop then reads each queued event from marked descriptors
 * and calls the event callback. Both callbacks can stop the loop at any
 * point.
 *
 * The poll_cb argument can be NULL in which case the function falls back to
 * a default, ppoll() based callback.
 */
int gpiod_ctxless_event_monitor_multiple (
    const(char)* device,
    int event_type,
    const(uint)* offsets,
    uint num_lines,
    bool active_low,
    const(char)* consumer,
    const(timespec)* timeout,
    gpiod_ctxless_event_poll_cb poll_cb,
    gpiod_ctxless_event_handle_cb event_cb,
    void* data);

/**
 * @brief Wait for events on multiple GPIO lines.
 * @param device Name, path, number or label of the gpiochip.
 * @param event_type Type of events to listen for.
 * @param offsets Array of GPIO line offsets to monitor.
 * @param num_lines Number of lines to monitor.
 * @param active_low The active state of this line - true if low.
 * @param consumer Name of the consumer.
 * @param timeout Maximum wait time for each iteration.
 * @param poll_cb Callback function to call when waiting for events. Can
 *                be NULL.
 * @param event_cb Callback function to call on event occurrence.
 * @param data User data passed to the callback.
 * @param flags The flags for the lines.
 * @return 0 no errors were encountered, -1 if an error occurred.
 * @note The poll callback can be NULL in which case the routine will fall
 *       back to a basic, ppoll() based callback.
 *
 * Internally this routine opens the GPIO chip, requests the set of lines for
 * the type of events specified in the event_type parameter and calls the
 * polling callback in a loop. The role of the polling callback is to detect
 * input events on a set of file descriptors and notify the caller about the
 * fds ready for reading.
 *
 * The ctxless event loop then reads each queued event from marked descriptors
 * and calls the event callback. Both callbacks can stop the loop at any
 * point.
 *
 * The poll_cb argument can be NULL in which case the function falls back to
 * a default, ppoll() based callback.
 */
int gpiod_ctxless_event_monitor_multiple_ext (
    const(char)* device,
    int event_type,
    const(uint)* offsets,
    uint num_lines,
    bool active_low,
    const(char)* consumer,
    const(timespec)* timeout,
    gpiod_ctxless_event_poll_cb poll_cb,
    gpiod_ctxless_event_handle_cb event_cb,
    void* data,
    int flags);

/**
 * @brief Determine the chip name and line offset of a line with given name.
 * @param name The name of the GPIO line to lookup.
 * @param chipname Buffer in which the name of the GPIO chip will be stored.
 * @param chipname_size Size of the chip name buffer.
 * @param offset Pointer to an integer in which the line offset will be stored.
 * @return -1 on error, 0 if the line with given name doesn't exist and 1 if
 *         the line was found. In the first two cases the contents of chipname
 *         and offset remain unchanged.
 * @note The chip name is truncated if the buffer can't hold its entire size.
 */
int gpiod_ctxless_find_line (
    const(char)* name,
    char* chipname,
    size_t chipname_size,
    uint* offset);

/**
 * @}
 *
 * @defgroup __chips__ GPIO chip operations
 * @{
 *
 * Functions and data structures dealing with GPIO chips.
 */

/**
 * @brief Open a gpiochip by path.
 * @param path Path to the gpiochip device file.
 * @return GPIO chip handle or NULL if an error occurred.
 */
gpiod_chip* gpiod_chip_open (const(char)* path);

/**
 * @brief Open a gpiochip by name.
 * @param name Name of the gpiochip to open.
 * @return GPIO chip handle or NULL if an error occurred.
 *
 * This routine appends name to '/dev/' to create the path.
 */
gpiod_chip* gpiod_chip_open_by_name (const(char)* name);

/**
 * @brief Open a gpiochip by number.
 * @param num Number of the gpiochip.
 * @return GPIO chip handle or NULL if an error occurred.
 *
 * This routine appends num to '/dev/gpiochip' to create the path.
 */
gpiod_chip* gpiod_chip_open_by_number (uint num);

/**
 * @brief Open a gpiochip by label.
 * @param label Label of the gpiochip to open.
 * @return GPIO chip handle or NULL if the chip with given label was not found
 *         or an error occured.
 * @note If the chip cannot be found but no other error occurred, errno is set
 *       to ENOENT.
 */
gpiod_chip* gpiod_chip_open_by_label (const(char)* label);

/**
 * @brief Open a gpiochip based on the best guess what the path is.
 * @param descr String describing the gpiochip.
 * @return GPIO chip handle or NULL if an error occurred.
 *
 * This routine tries to figure out whether the user passed it the path to the
 * GPIO chip, its name, label or number as a string. Then it tries to open it
 * using one of the gpiod_chip_open** variants.
 */
gpiod_chip* gpiod_chip_open_lookup (const(char)* descr);

/**
 * @brief Close a GPIO chip handle and release all allocated resources.
 * @param chip The GPIO chip object.
 */
void gpiod_chip_close (gpiod_chip* chip);

/**
 * @brief Get the GPIO chip name as represented in the kernel.
 * @param chip The GPIO chip object.
 * @return Pointer to a human-readable string containing the chip name.
 */
const(char)* gpiod_chip_name (gpiod_chip* chip);

/**
 * @brief Get the GPIO chip label as represented in the kernel.
 * @param chip The GPIO chip object.
 * @return Pointer to a human-readable string containing the chip label.
 */
const(char)* gpiod_chip_label (gpiod_chip* chip);

/**
 * @brief Get the number of GPIO lines exposed by this chip.
 * @param chip The GPIO chip object.
 * @return Number of GPIO lines.
 */
uint gpiod_chip_num_lines (gpiod_chip* chip);

/**
 * @brief Get the handle to the GPIO line at given offset.
 * @param chip The GPIO chip object.
 * @param offset The offset of the GPIO line.
 * @return Pointer to the GPIO line handle or NULL if an error occured.
 */
gpiod_line* gpiod_chip_get_line (gpiod_chip* chip, uint offset);

/**
 * @brief Retrieve a set of lines and store them in a line bulk object.
 * @param chip The GPIO chip object.
 * @param offsets Array of offsets of lines to retrieve.
 * @param num_offsets Number of lines to retrieve.
 * @param bulk Line bulk object in which to store the line handles.
 * @return 0 on success, -1 on error.
 */
int gpiod_chip_get_lines (
    gpiod_chip* chip,
    uint* offsets,
    uint num_offsets,
    gpiod_line_bulk* bulk);

/**
 * @brief Retrieve all lines exposed by a chip and store them in a bulk object.
 * @param chip The GPIO chip object.
 * @param bulk Line bulk object in which to store the line handles.
 * @return 0 on success, -1 on error.
 */
int gpiod_chip_get_all_lines (gpiod_chip* chip, gpiod_line_bulk* bulk);

/**
 * @brief Find a GPIO line by name among lines associated with given GPIO chip.
 * @param chip The GPIO chip object.
 * @param name The name of the GPIO line.
 * @return Pointer to the GPIO line handle or NULL if the line could not be
 *         found or an error occurred.
 * @note In case a line with given name is not associated with given chip, the
 *       function sets errno to ENOENT.
 */
gpiod_line* gpiod_chip_find_line (gpiod_chip* chip, const(char)* name);

/**
 * @brief Find a set of GPIO lines by names among lines exposed by this chip.
 * @param chip The GPIO chip object.
 * @param names Array of pointers to C-strings containing the names of the
 *              lines to lookup. Must end with a NULL-pointer.
 * @param bulk Line bulk object in which the located lines will be stored.
 * @return 0 if all lines were located, -1 on error.
 * @note If at least one line from the list could not be found among the lines
 *       exposed by this chip, the function sets errno to ENOENT.
 */
int gpiod_chip_find_lines (
    gpiod_chip* chip,
    const(char*)* names,
    gpiod_line_bulk* bulk);

/**
 * @}
 *
 * @defgroup __lines__ GPIO line operations
 * @{
 *
 * Functions and data structures dealing with GPIO lines.
 *
 * @defgroup __line_bulk__ Operating on multiple lines
 * @{
 *
 * Convenience data structures and helper functions for storing and operating
 * on multiple lines at once.
 */

/**
 * @brief Maximum number of GPIO lines that can be requested at once.
 */
enum GPIOD_LINE_BULK_MAX_LINES = 64;

/**
 * @brief Helper structure for storing a set of GPIO line objects.
 *
 * This structure is used in all operations involving sets of GPIO lines. If
 * a bulk object is being passed to a function while containing zero lines,
 * the result is undefined.
 */
struct gpiod_line_bulk
{
    gpiod_line*[GPIOD_LINE_BULK_MAX_LINES] lines;
    /**< Buffer for line pointers. */
    uint num_lines;
    /**< Number of lines currently held in this structure. */
}

/**
 * @brief Static initializer for GPIO bulk objects.
 *
 * This macro simply sets the internally held number of lines to 0.
 */

/**
 * @brief Initialize a GPIO bulk object.
 * @param bulk Line bulk object.
 *
 * This routine simply sets the internally held number of lines to 0.
 */
void gpiod_line_bulk_init (gpiod_line_bulk* bulk);

/**
 * @brief Add a single line to a GPIO bulk object.
 * @param bulk Line bulk object.
 * @param line Line to add.
 */
void gpiod_line_bulk_add (gpiod_line_bulk* bulk, gpiod_line* line);

/**
 * @brief Retrieve the line handle from a line bulk object at given offset.
 * @param bulk Line bulk object.
 * @param offset Line offset.
 * @return Line handle at given offset.
 */
gpiod_line* gpiod_line_bulk_get_line (gpiod_line_bulk* bulk, uint offset);

/**
 * @brief Retrieve the number of GPIO lines held by this line bulk object.
 * @param bulk Line bulk object.
 * @return Number of lines held by this line bulk.
 */
uint gpiod_line_bulk_num_lines (gpiod_line_bulk* bulk);

/**
 * @brief Iterate over all line handles held by a line bulk object.
 * @param bulk Line bulk object.
 * @param line GPIO line handle. On each iteration, the subsequent line handle
 *             is assigned to this pointer.
 * @param lineptr Pointer to a GPIO line handle used to store the loop state.
 */

/**
 * @brief Iterate over all line handles held by a line bulk object (integer
 *        counter variant).
 * @param bulk Line bulk object.
 * @param line GPIO line handle. On each iteration, the subsequent line handle
 *             is assigned to this pointer.
 * @param offset An integer variable used to store the loop state.
 *
 * This is a variant of ::gpiod_line_bulk_foreach_line which uses an integer
 * variable (either signed or unsigned) to store the loop state. This offset
 * variable is guaranteed to correspond to the offset of the current line in
 * the bulk->lines array.
 */

/**
 * @}
 *
 * @defgroup __line_info__ Line info
 * @{
 *
 * Definitions and functions for retrieving kernel information about both
 * requested and free lines.
 */

/**
 * @brief Possible direction settings.
 */
enum
{
    GPIOD_LINE_DIRECTION_INPUT = 1,
    /**< Direction is input - we're reading the state of a GPIO line. */
    GPIOD_LINE_DIRECTION_OUTPUT = 2
    /**< Direction is output - we're driving the GPIO line. */
}

/**
 * @brief Possible active state settings.
 */
enum
{
    GPIOD_LINE_ACTIVE_STATE_HIGH = 1,
    /**< The active state of a GPIO is active-high. */
    GPIOD_LINE_ACTIVE_STATE_LOW = 2
    /**< The active state of a GPIO is active-low. */
}

/**
 * @brief Possible internal bias settings.
 */
enum
{
    GPIOD_LINE_BIAS_AS_IS = 1,
    /**< The internal bias state is unknown. */
    GPIOD_LINE_BIAS_DISABLE = 2,
    /**< The internal bias is disabled. */
    GPIOD_LINE_BIAS_PULL_UP = 3,
    /**< The internal pull-up bias is enabled. */
    GPIOD_LINE_BIAS_PULL_DOWN = 4
    /**< The internal pull-down bias is enabled. */
}

/**
 * @brief Read the GPIO line offset.
 * @param line GPIO line object.
 * @return Line offset.
 */
uint gpiod_line_offset (gpiod_line* line);

/**
 * @brief Read the GPIO line name.
 * @param line GPIO line object.
 * @return Name of the GPIO line as it is represented in the kernel. This
 *         routine returns a pointer to a null-terminated string or NULL if
 *         the line is unnamed.
 */
const(char)* gpiod_line_name (gpiod_line* line);

/**
 * @brief Read the GPIO line consumer name.
 * @param line GPIO line object.
 * @return Name of the GPIO consumer name as it is represented in the
 *         kernel. This routine returns a pointer to a null-terminated string
 *         or NULL if the line is not used.
 */
const(char)* gpiod_line_consumer (gpiod_line* line);

/**
 * @brief Read the GPIO line direction setting.
 * @param line GPIO line object.
 * @return Returns GPIOD_LINE_DIRECTION_INPUT or GPIOD_LINE_DIRECTION_OUTPUT.
 */
int gpiod_line_direction (gpiod_line* line);

/**
 * @brief Read the GPIO line active state setting.
 * @param line GPIO line object.
 * @return Returns GPIOD_LINE_ACTIVE_STATE_HIGH or GPIOD_LINE_ACTIVE_STATE_LOW.
 */
int gpiod_line_active_state (gpiod_line* line);

/**
 * @brief Read the GPIO line bias setting.
 * @param line GPIO line object.
 * @return Returns GPIOD_LINE_BIAS_PULL_UP, GPIOD_LINE_BIAS_PULL_DOWN,
 *         GPIOD_LINE_BIAS_DISABLE or GPIOD_LINE_BIAS_AS_IS.
 */
int gpiod_line_bias (gpiod_line* line);

/**
 * @brief Check if the line is currently in use.
 * @param line GPIO line object.
 * @return True if the line is in use, false otherwise.
 *
 * The user space can't know exactly why a line is busy. It may have been
 * requested by another process or hogged by the kernel. It only matters that
 * the line is used and we can't request it.
 */
bool gpiod_line_is_used (gpiod_line* line);

/**
 * @brief Check if the line is an open-drain GPIO.
 * @param line GPIO line object.
 * @return True if the line is an open-drain GPIO, false otherwise.
 */
bool gpiod_line_is_open_drain (gpiod_line* line);

/**
 * @brief Check if the line is an open-source GPIO.
 * @param line GPIO line object.
 * @return True if the line is an open-source GPIO, false otherwise.
 */
bool gpiod_line_is_open_source (gpiod_line* line);

/**
 * @brief Re-read the line info.
 * @param line GPIO line object.
 * @return 0 if the operation succeeds. In case of an error this routine
 *         returns -1 and sets the last error number.
 *
 * The line info is initially retrieved from the kernel by
 * gpiod_chip_get_line() and is later re-read after every successful request.
 * Users can use this function to manually re-read the line info when needed.
 *
 * We currently have no mechanism provided by the kernel for keeping the line
 * info synchronized and for the sake of speed and simplicity of this low-level
 * library we don't want to re-read the line info automatically everytime
 * a property is retrieved. Any daemon using this library must track the state
 * of lines on its own and call this routine if needed.
 *
 * The state of requested lines is kept synchronized (or rather cannot be
 * changed by external agents while the ownership of the line is taken) so
 * there's no need to call this function in that case.
 */
int gpiod_line_update (gpiod_line* line);

/**
 * @brief Check if the line info needs to be updated.
 * @param line GPIO line object.
 * @return Deprecated and no longer functional - always returns false.
 */
bool gpiod_line_needs_update (gpiod_line* line);

/**
 * @}
 *
 * @defgroup __line_request__ Line requests
 * @{
 *
 * Interface for requesting GPIO lines from userspace for both values and
 * events.
 */

/**
 * @brief Available types of requests.
 */
enum
{
    GPIOD_LINE_REQUEST_DIRECTION_AS_IS = 1,
    /**< Request the line(s), but don't change current direction. */
    GPIOD_LINE_REQUEST_DIRECTION_INPUT = 2,
    /**< Request the line(s) for reading the GPIO line state. */
    GPIOD_LINE_REQUEST_DIRECTION_OUTPUT = 3,
    /**< Request the line(s) for setting the GPIO line state. */
    GPIOD_LINE_REQUEST_EVENT_FALLING_EDGE = 4,
    /**< Monitor both types of events. */
    GPIOD_LINE_REQUEST_EVENT_RISING_EDGE = 5,
    /**< Only watch rising edge events. */
    GPIOD_LINE_REQUEST_EVENT_BOTH_EDGES = 6
    /**< Only watch falling edge events. */
}

/**
 * @brief Miscellaneous GPIO request flags.
 */
enum
{
    GPIOD_LINE_REQUEST_FLAG_OPEN_DRAIN = GPIOD_BIT(0),
    /**< The line is an open-drain port. */
    GPIOD_LINE_REQUEST_FLAG_OPEN_SOURCE = GPIOD_BIT(1),
    /**< The line is an open-source port. */
    GPIOD_LINE_REQUEST_FLAG_ACTIVE_LOW = GPIOD_BIT(2),
    /**< The active state of the line is low (high is the default). */
    GPIOD_LINE_REQUEST_FLAG_BIAS_DISABLE = GPIOD_BIT(3),
    /**< The line has neither either pull-up nor pull-down resistor. */
    GPIOD_LINE_REQUEST_FLAG_BIAS_PULL_DOWN = GPIOD_BIT(4),
    /**< The line has pull-down resistor enabled. */
    GPIOD_LINE_REQUEST_FLAG_BIAS_PULL_UP = GPIOD_BIT(5)
    /**< The line has pull-up resistor enabled. */
}

/**
 * @brief Structure holding configuration of a line request.
 */
struct gpiod_line_request_config
{
    const(char)* consumer;
    /**< Name of the consumer. */
    int request_type;
    /**< Request type. */
    int flags;
    /**< Other configuration flags. */
}

/**
 * @brief Reserve a single line.
 * @param line GPIO line object.
 * @param config Request options.
 * @param default_val Initial line value - only relevant if we're setting
 *                    the direction to output.
 * @return 0 if the line was properly reserved. In case of an error this
 *         routine returns -1 and sets the last error number.
 *
 * If this routine succeeds, the caller takes ownership of the GPIO line until
 * it's released.
 */
int gpiod_line_request (
    gpiod_line* line,
    const(gpiod_line_request_config)* config,
    int default_val);

/**
 * @brief Reserve a single line, set the direction to input.
 * @param line GPIO line object.
 * @param consumer Name of the consumer.
 * @return 0 if the line was properly reserved, -1 on failure.
 */
int gpiod_line_request_input (gpiod_line* line, const(char)* consumer);

/**
 * @brief Reserve a single line, set the direction to output.
 * @param line GPIO line object.
 * @param consumer Name of the consumer.
 * @param default_val Initial line value.
 * @return 0 if the line was properly reserved, -1 on failure.
 */
int gpiod_line_request_output (
    gpiod_line* line,
    const(char)* consumer,
    int default_val);

/**
 * @brief Request rising edge event notifications on a single line.
 * @param line GPIO line object.
 * @param consumer Name of the consumer.
 * @return 0 if the operation succeeds, -1 on failure.
 */
int gpiod_line_request_rising_edge_events (
    gpiod_line* line,
    const(char)* consumer);

/**
 * @brief Request falling edge event notifications on a single line.
 * @param line GPIO line object.
 * @param consumer Name of the consumer.
 * @return 0 if the operation succeeds, -1 on failure.
 */
int gpiod_line_request_falling_edge_events (
    gpiod_line* line,
    const(char)* consumer);

/**
 * @brief Request all event type notifications on a single line.
 * @param line GPIO line object.
 * @param consumer Name of the consumer.
 * @return 0 if the operation succeeds, -1 on failure.
 */
int gpiod_line_request_both_edges_events (
    gpiod_line* line,
    const(char)* consumer);

/**
 * @brief Reserve a single line, set the direction to input.
 * @param line GPIO line object.
 * @param consumer Name of the consumer.
 * @param flags Additional request flags.
 * @return 0 if the line was properly reserved, -1 on failure.
 */
int gpiod_line_request_input_flags (
    gpiod_line* line,
    const(char)* consumer,
    int flags);

/**
 * @brief Reserve a single line, set the direction to output.
 * @param line GPIO line object.
 * @param consumer Name of the consumer.
 * @param flags Additional request flags.
 * @param default_val Initial line value.
 * @return 0 if the line was properly reserved, -1 on failure.
 */
int gpiod_line_request_output_flags (
    gpiod_line* line,
    const(char)* consumer,
    int flags,
    int default_val);

/**
 * @brief Request rising edge event notifications on a single line.
 * @param line GPIO line object.
 * @param consumer Name of the consumer.
 * @param flags Additional request flags.
 * @return 0 if the operation succeeds, -1 on failure.
 */
int gpiod_line_request_rising_edge_events_flags (
    gpiod_line* line,
    const(char)* consumer,
    int flags);

/**
 * @brief Request falling edge event notifications on a single line.
 * @param line GPIO line object.
 * @param consumer Name of the consumer.
 * @param flags Additional request flags.
 * @return 0 if the operation succeeds, -1 on failure.
 */
int gpiod_line_request_falling_edge_events_flags (
    gpiod_line* line,
    const(char)* consumer,
    int flags);

/**
 * @brief Request all event type notifications on a single line.
 * @param line GPIO line object.
 * @param consumer Name of the consumer.
 * @param flags Additional request flags.
 * @return 0 if the operation succeeds, -1 on failure.
 */
int gpiod_line_request_both_edges_events_flags (
    gpiod_line* line,
    const(char)* consumer,
    int flags);

/**
 * @brief Reserve a set of GPIO lines.
 * @param bulk Set of GPIO lines to reserve.
 * @param config Request options.
 * @param default_vals Initial line values - only relevant if we're setting
 *                     the direction to output.
 * @return 0 if the all lines were properly requested. In case of an error
 *         this routine returns -1 and sets the last error number.
 *
 * If this routine succeeds, the caller takes ownership of the GPIO lines
 * until they're released. All the requested lines must be prodivided by the
 * same gpiochip.
 */
int gpiod_line_request_bulk (
    gpiod_line_bulk* bulk,
    const(gpiod_line_request_config)* config,
    const(int)* default_vals);

/**
 * @brief Reserve a set of GPIO lines, set the direction to input.
 * @param bulk Set of GPIO lines to reserve.
 * @param consumer Name of the consumer.
 * @return 0 if the lines were properly reserved, -1 on failure.
 */
int gpiod_line_request_bulk_input (
    gpiod_line_bulk* bulk,
    const(char)* consumer);

/**
 * @brief Reserve a set of GPIO lines, set the direction to output.
 * @param bulk Set of GPIO lines to reserve.
 * @param consumer Name of the consumer.
 * @param default_vals Initial line values.
 * @return 0 if the lines were properly reserved, -1 on failure.
 */
int gpiod_line_request_bulk_output (
    gpiod_line_bulk* bulk,
    const(char)* consumer,
    const(int)* default_vals);

/**
 * @brief Request rising edge event notifications on a set of lines.
 * @param bulk Set of GPIO lines to request.
 * @param consumer Name of the consumer.
 * @return 0 if the operation succeeds, -1 on failure.
 */
int gpiod_line_request_bulk_rising_edge_events (
    gpiod_line_bulk* bulk,
    const(char)* consumer);

/**
 * @brief Request falling edge event notifications on a set of lines.
 * @param bulk Set of GPIO lines to request.
 * @param consumer Name of the consumer.
 * @return 0 if the operation succeeds, -1 on failure.
 */
int gpiod_line_request_bulk_falling_edge_events (
    gpiod_line_bulk* bulk,
    const(char)* consumer);

/**
 * @brief Request all event type notifications on a set of lines.
 * @param bulk Set of GPIO lines to request.
 * @param consumer Name of the consumer.
 * @return 0 if the operation succeeds, -1 on failure.
 */
int gpiod_line_request_bulk_both_edges_events (
    gpiod_line_bulk* bulk,
    const(char)* consumer);

/**
 * @brief Reserve a set of GPIO lines, set the direction to input.
 * @param bulk Set of GPIO lines to reserve.
 * @param consumer Name of the consumer.
 * @param flags Additional request flags.
 * @return 0 if the lines were properly reserved, -1 on failure.
 */
int gpiod_line_request_bulk_input_flags (
    gpiod_line_bulk* bulk,
    const(char)* consumer,
    int flags);

/**
 * @brief Reserve a set of GPIO lines, set the direction to output.
 * @param bulk Set of GPIO lines to reserve.
 * @param consumer Name of the consumer.
 * @param flags Additional request flags.
 * @param default_vals Initial line values.
 * @return 0 if the lines were properly reserved, -1 on failure.
 */
int gpiod_line_request_bulk_output_flags (
    gpiod_line_bulk* bulk,
    const(char)* consumer,
    int flags,
    const(int)* default_vals);

/**
 * @brief Request rising edge event notifications on a set of lines.
 * @param bulk Set of GPIO lines to request.
 * @param consumer Name of the consumer.
 * @param flags Additional request flags.
 * @return 0 if the operation succeeds, -1 on failure.
 */
int gpiod_line_request_bulk_rising_edge_events_flags (
    gpiod_line_bulk* bulk,
    const(char)* consumer,
    int flags);

/**
 * @brief Request falling edge event notifications on a set of lines.
 * @param bulk Set of GPIO lines to request.
 * @param consumer Name of the consumer.
 * @param flags Additional request flags.
 * @return 0 if the operation succeeds, -1 on failure.
 */
int gpiod_line_request_bulk_falling_edge_events_flags (
    gpiod_line_bulk* bulk,
    const(char)* consumer,
    int flags);

/**
 * @brief Request all event type notifications on a set of lines.
 * @param bulk Set of GPIO lines to request.
 * @param consumer Name of the consumer.
 * @param flags Additional request flags.
 * @return 0 if the operation succeeds, -1 on failure.
 */
int gpiod_line_request_bulk_both_edges_events_flags (
    gpiod_line_bulk* bulk,
    const(char)* consumer,
    int flags);

/**
 * @brief Release a previously reserved line.
 * @param line GPIO line object.
 */
void gpiod_line_release (gpiod_line* line);

/**
 * @brief Release a set of previously reserved lines.
 * @param bulk Set of GPIO lines to release.
 *
 * If the lines were not previously requested together, the behavior is
 * undefined.
 */
void gpiod_line_release_bulk (gpiod_line_bulk* bulk);

/**
 * @brief Check if the calling user has ownership of this line.
 * @param line GPIO line object.
 * @return True if given line was requested, false otherwise.
 */
bool gpiod_line_is_requested (gpiod_line* line);

/**
 * @brief Check if the calling user has neither requested ownership of this
 *        line nor configured any event notifications.
 * @param line GPIO line object.
 * @return True if given line is free, false otherwise.
 */
bool gpiod_line_is_free (gpiod_line* line);

/**
 * @}
 *
 * @defgroup __line_value__ Reading & setting line values
 * @{
 *
 * Functions allowing to read and set GPIO line values for single lines and
 * in bulk.
 */

/**
 * @brief Read current value of a single GPIO line.
 * @param line GPIO line object.
 * @return 0 or 1 if the operation succeeds. On error this routine returns -1
 *         and sets the last error number.
 */
int gpiod_line_get_value (gpiod_line* line);

/**
 * @brief Read current values of a set of GPIO lines.
 * @param bulk Set of GPIO lines to reserve.
 * @param values An array big enough to hold line_bulk->num_lines values.
 * @return 0 is the operation succeeds. In case of an error this routine
 *         returns -1 and sets the last error number.
 *
 * If succeeds, this routine fills the values array with a set of values in
 * the same order, the lines are added to line_bulk. If the lines were not
 * previously requested together, the behavior is undefined.
 */
int gpiod_line_get_value_bulk (gpiod_line_bulk* bulk, int* values);

/**
 * @brief Set the value of a single GPIO line.
 * @param line GPIO line object.
 * @param value New value.
 * @return 0 is the operation succeeds. In case of an error this routine
 *         returns -1 and sets the last error number.
 */
int gpiod_line_set_value (gpiod_line* line, int value);

/**
 * @brief Set the values of a set of GPIO lines.
 * @param bulk Set of GPIO lines to reserve.
 * @param values An array holding line_bulk->num_lines new values for lines.
 *               A NULL pointer is interpreted as a logical low for all lines.
 * @return 0 is the operation succeeds. In case of an error this routine
 *         returns -1 and sets the last error number.
 *
 * If the lines were not previously requested together, the behavior is
 * undefined.
 */
int gpiod_line_set_value_bulk (gpiod_line_bulk* bulk, const(int)* values);

/**
 * @}
 *
 * @defgroup __line_config__ Setting line configuration
 * @{
 *
 * Functions allowing modification of config options of GPIO lines requested
 * from user-space.
 */

/**
 * @brief Update the configuration of a single GPIO line.
 * @param line GPIO line object.
 * @param direction Updated direction which may be one of
 *                  GPIOD_LINE_REQUEST_DIRECTION_AS_IS,
 *                  GPIOD_LINE_REQUEST_DIRECTION_INPUT, or
 *                  GPIOD_LINE_REQUEST_DIRECTION_OUTPUT.
 * @param flags Replacement flags.
 * @param value The new output value for the line when direction is
 *              GPIOD_LINE_REQUEST_DIRECTION_OUTPUT.
 * @return 0 is the operation succeeds. In case of an error this routine
 *         returns -1 and sets the last error number.
 */
int gpiod_line_set_config (
    gpiod_line* line,
    int direction,
    int flags,
    int value);

/**
 * @brief Update the configuration of a set of GPIO lines.
 * @param bulk Set of GPIO lines.
 * @param direction Updated direction which may be one of
 *                  GPIOD_LINE_REQUEST_DIRECTION_AS_IS,
 *                  GPIOD_LINE_REQUEST_DIRECTION_INPUT, or
 *                  GPIOD_LINE_REQUEST_DIRECTION_OUTPUT.
 * @param flags Replacement flags.
 * @param values An array holding line_bulk->num_lines new logical values
 *               for lines when direction is
 *               GPIOD_LINE_REQUEST_DIRECTION_OUTPUT.
 *               A NULL pointer is interpreted as a logical low for all lines.
 * @return 0 is the operation succeeds. In case of an error this routine
 *         returns -1 and sets the last error number.
 *
 * If the lines were not previously requested together, the behavior is
 * undefined.
 */
int gpiod_line_set_config_bulk (
    gpiod_line_bulk* bulk,
    int direction,
    int flags,
    const(int)* values);

/**
 * @brief Update the configuration flags of a single GPIO line.
 * @param line GPIO line object.
 * @param flags Replacement flags.
 * @return 0 is the operation succeeds. In case of an error this routine
 *         returns -1 and sets the last error number.
 */
int gpiod_line_set_flags (gpiod_line* line, int flags);

/**
 * @brief Update the configuration flags of a set of GPIO lines.
 * @param bulk Set of GPIO lines.
 * @param flags Replacement flags.
 * @return 0 is the operation succeeds. In case of an error this routine
 *         returns -1 and sets the last error number.
 *
 * If the lines were not previously requested together, the behavior is
 * undefined.
 */
int gpiod_line_set_flags_bulk (gpiod_line_bulk* bulk, int flags);

/**
 * @brief Set the direction of a single GPIO line to input.
 * @param line GPIO line object.
 * @return 0 is the operation succeeds. In case of an error this routine
 *         returns -1 and sets the last error number.
 */
int gpiod_line_set_direction_input (gpiod_line* line);

/**
 * @brief Set the direction of a set of GPIO lines to input.
 * @param bulk Set of GPIO lines.
 * @return 0 is the operation succeeds. In case of an error this routine
 *         returns -1 and sets the last error number.
 *
 * If the lines were not previously requested together, the behavior is
 * undefined.
 */
int gpiod_line_set_direction_input_bulk (gpiod_line_bulk* bulk);

/**
 * @brief Set the direction of a single GPIO line to output.
 * @param line GPIO line object.
 * @param value The logical value output on the line.
 * @return 0 is the operation succeeds. In case of an error this routine
 *         returns -1 and sets the last error number.
 */
int gpiod_line_set_direction_output (gpiod_line* line, int value);

/**
 * @brief Set the direction of a set of GPIO lines to output.
 * @param bulk Set of GPIO lines.
 * @param values An array holding line_bulk->num_lines new logical values
 *               for lines.  A NULL pointer is interpreted as a logical low
 *               for all lines.
 * @return 0 is the operation succeeds. In case of an error this routine
 *         returns -1 and sets the last error number.
 *
 * If the lines were not previously requested together, the behavior is
 * undefined.
 */
int gpiod_line_set_direction_output_bulk (
    gpiod_line_bulk* bulk,
    const(int)* values);

/**
 * @}
 *
 * @defgroup __line_event__ Line events handling
 * @{
 *
 * Structures and functions allowing to poll lines for events and read them,
 * both for individual lines as well as in bulk. Also contains functions for
 * retrieving the associated file descriptors and operate on them for easy
 * integration with standard unix interfaces.
 */

/**
 * @brief Event types.
 */
enum
{
    GPIOD_LINE_EVENT_RISING_EDGE = 1,
    /**< Rising edge event. */
    GPIOD_LINE_EVENT_FALLING_EDGE = 2
    /**< Falling edge event. */
}

/**
 * @brief Structure holding event info.
 */
struct gpiod_line_event
{
    timespec ts;
    /**< Best estimate of time of event occurrence. */
    int event_type;
    /**< Type of the event that occurred. */
}

/**
 * @brief Wait for an event on a single line.
 * @param line GPIO line object.
 * @param timeout Wait time limit.
 * @return 0 if wait timed out, -1 if an error occurred, 1 if an event
 *         occurred.
 */
int gpiod_line_event_wait (gpiod_line* line, const(timespec)* timeout);

/**
 * @brief Wait for events on a set of lines.
 * @param bulk Set of GPIO lines to monitor.
 * @param timeout Wait time limit.
 * @param event_bulk Bulk object in which to store the line handles on which
 *                   events occurred. Can be NULL.
 * @return 0 if wait timed out, -1 if an error occurred, 1 if at least one
 *         event occurred.
 */
int gpiod_line_event_wait_bulk (
    gpiod_line_bulk* bulk,
    const(timespec)* timeout,
    gpiod_line_bulk* event_bulk);

/**
 * @brief Read next pending event from the GPIO line.
 * @param line GPIO line object.
 * @param event Buffer to which the event data will be copied.
 * @return 0 if the event was read correctly, -1 on error.
 * @note This function will block if no event was queued for this line.
 */
int gpiod_line_event_read (gpiod_line* line, gpiod_line_event* event);

/**
 * @brief Read up to a certain number of events from the GPIO line.
 * @param line GPIO line object.
 * @param events Buffer to which the event data will be copied. Must hold at
 *               least the amount of events specified in num_events.
 * @param num_events Specifies how many events can be stored in the buffer.
 * @return On success returns the number of events stored in the buffer, on
 *         failure -1 is returned.
 */
int gpiod_line_event_read_multiple (
    gpiod_line* line,
    gpiod_line_event* events,
    uint num_events);

/**
 * @brief Get the event file descriptor.
 * @param line GPIO line object.
 * @return Number of the event file descriptor or -1 if the user tries to
 *         retrieve the descriptor from a line that wasn't configured for
 *         event monitoring.
 *
 * Users may want to poll the event file descriptor on their own. This routine
 * allows to access it.
 */
int gpiod_line_event_get_fd (gpiod_line* line);

/**
 * @brief Read the last GPIO event directly from a file descriptor.
 * @param fd File descriptor.
 * @param event Buffer in which the event data will be stored.
 * @return 0 if the event was read correctly, -1 on error.
 *
 * Users who directly poll the file descriptor for incoming events can also
 * directly read the event data from it using this routine. This function
 * translates the kernel representation of the event to the libgpiod format.
 */
int gpiod_line_event_read_fd (int fd, gpiod_line_event* event);

/**
 * @brief Read up to a certain number of events directly from a file descriptor.
 * @param fd File descriptor.
 * @param events Buffer to which the event data will be copied. Must hold at
 *               least the amount of events specified in num_events.
 * @param num_events Specifies how many events can be stored in the buffer.
 * @return On success returns the number of events stored in the buffer, on
 *         failure -1 is returned.
 */
int gpiod_line_event_read_fd_multiple (
    int fd,
    gpiod_line_event* events,
    uint num_events);

/**
 * @}
 *
 * @defgroup __line_misc__ Misc line functions
 * @{
 *
 * Functions that didn't fit anywhere else.
 */

/**
 * @brief Get a GPIO line handle by GPIO chip description and offset.
 * @param device String describing the gpiochip.
 * @param offset The offset of the GPIO line.
 * @return GPIO line handle or NULL if an error occurred.
 *
 * This routine provides a shorter alternative to calling
 * ::gpiod_chip_open_lookup and ::gpiod_chip_get_line.
 *
 * If this function succeeds, the caller is responsible for closing the
 * associated GPIO chip.
 */
gpiod_line* gpiod_line_get (const(char)* device, uint offset);

/**
 * @brief Find a GPIO line by its name.
 * @param name Name of the GPIO line.
 * @return Returns the GPIO line handle if the line exists in the system or
 *         NULL if it couldn't be located or an error occurred.
 *
 * If this routine succeeds, the user must manually close the GPIO chip owning
 * this line to avoid memory leaks. If the line could not be found, this
 * functions sets errno to ENOENT.
 */
gpiod_line* gpiod_line_find (const(char)* name);

/**
 * @brief Close a GPIO chip owning this line and release all resources.
 * @param line GPIO line object
 *
 * After this function returns, the line must no longer be used.
 */
void gpiod_line_close_chip (gpiod_line* line);

/**
 * @brief Get the handle to the GPIO chip controlling this line.
 * @param line The GPIO line object.
 * @return Pointer to the GPIO chip handle controlling this line.
 */
gpiod_chip* gpiod_line_get_chip (gpiod_line* line);

/**
 * @}
 *
 * @}
 *
 * @defgroup __iterators__ Iterators for GPIO chips and lines
 * @{
 *
 * These functions and data structures allow easy iterating over GPIO
 * chips and lines.
 */

/**
 * @brief Create a new gpiochip iterator.
 * @return Pointer to a new chip iterator object or NULL if an error occurred.
 *
 * Internally this routine scans the /dev/ directory for GPIO chip device
 * files, opens them and stores their the handles until ::gpiod_chip_iter_free
 * or ::gpiod_chip_iter_free_noclose is called.
 */
gpiod_chip_iter* gpiod_chip_iter_new ();

/**
 * @brief Release all resources allocated for the gpiochip iterator and close
 *        the most recently opened gpiochip (if any).
 * @param iter The gpiochip iterator object.
 */
void gpiod_chip_iter_free (gpiod_chip_iter* iter);

/**
 * @brief Release all resources allocated for the gpiochip iterator but
 *        don't close the most recently opened gpiochip (if any).
 * @param iter The gpiochip iterator object.
 *
 * Users may want to break the loop when iterating over gpiochips and keep
 * the most recently opened chip active while freeing the iterator data.
 * This routine enables that.
 */
void gpiod_chip_iter_free_noclose (gpiod_chip_iter* iter);

/**
 * @brief Get the next gpiochip handle.
 * @param iter The gpiochip iterator object.
 * @return Pointer to the next open gpiochip handle or NULL if no more chips
 *         are present in the system.
 * @note The previous chip handle will be closed using ::gpiod_chip_iter_free.
 */
gpiod_chip* gpiod_chip_iter_next (gpiod_chip_iter* iter);

/**
 * @brief Get the next gpiochip handle without closing the previous one.
 * @param iter The gpiochip iterator object.
 * @return Pointer to the next open gpiochip handle or NULL if no more chips
 *         are present in the system.
 * @note This function works just like ::gpiod_chip_iter_next but doesn't
 *       close the most recently opened chip handle.
 */
gpiod_chip* gpiod_chip_iter_next_noclose (gpiod_chip_iter* iter);

/**
 * @brief Iterate over all GPIO chips present in the system.
 * @param iter An initialized GPIO chip iterator.
 * @param chip Pointer to a GPIO chip handle. On each iteration the newly
 *             opened chip handle is assigned to this argument.
 *
 * The user must not close the GPIO chip manually - instead the previous chip
 * handle is closed automatically on the next iteration. The last chip to be
 * opened is closed internally by ::gpiod_chip_iter_free.
 */

/**
 * @brief Iterate over all chips present in the system without closing them.
 * @param iter An initialized GPIO chip iterator.
 * @param chip Pointer to a GPIO chip handle. On each iteration the newly
 *             opened chip handle is assigned to this argument.
 *
 * The user must close all the GPIO chips manually after use, until then, the
 * chips remain open. Free the iterator by calling
 * ::gpiod_chip_iter_free_noclose to avoid closing the last chip automatically.
 */

/**
 * @brief Create a new line iterator.
 * @param chip Active gpiochip handle over the lines of which we want
 *             to iterate.
 * @return New line iterator or NULL if an error occurred.
 */
gpiod_line_iter* gpiod_line_iter_new (gpiod_chip* chip);

/**
 * @brief Free all resources associated with a GPIO line iterator.
 * @param iter Line iterator object.
 */
void gpiod_line_iter_free (gpiod_line_iter* iter);

/**
 * @brief Get the next GPIO line handle.
 * @param iter The GPIO line iterator object.
 * @return Pointer to the next GPIO line handle or NULL if there are no more
 *         lines left.
 */
gpiod_line* gpiod_line_iter_next (gpiod_line_iter* iter);

/**
 * @brief Iterate over all GPIO lines of a single chip.
 * @param iter An initialized GPIO line iterator.
 * @param line Pointer to a GPIO line handle - on each iteration, the
 *             next GPIO line will be assigned to this argument.
 */

/**
 * @}
 *
 * @defgroup __misc__ Stuff that didn't fit anywhere else
 * @{
 *
 * Various libgpiod-related functions.
 */

/**
 * @brief Get the API version of the library as a human-readable string.
 * @return Human-readable string containing the library version.
 */
const(char)* gpiod_version_string ();

/**
 * @}
 */

/* extern "C" */

/* __LIBGPIOD_GPIOD_H__ */
