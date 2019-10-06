#ifndef PHERIH_PWM_HPP
#define PHERIH_PWM_HPP

#include <cstdint>

typedef enum {
	pwm_align_edge     = 0,
	pwm_align_midpulse = 1
} pwm_eAlignment;

typedef struct {
	int32_t        period;
	pwm_eAlignment align;
	uint32_t       pol_map;
	int32_t        duty[];
} pwm_info;

/**
 * Initialize a set of phase-locked PWMs.
 *
 * \param [in] dev_base Base address of the PWM peripheral.
 * \param [in] info     Information to initialize the PWMs with.
 */
void pwm_init(void* dev_base, pwm_info* info);

/**
 * Change the settings for a group of phase-locked PWMs.
 *
 * \param [in] dev_base Base address of the PWM peripheral.
 * \param [in] info     Information to configure the PWMs with.
 */
void pwm_set(void* dev_base, pwm_info* info);

/**
 * Set the period of a group of phase-locked PWMs.
 *
 * \param [in] dev_base Base address of the PWM peripheral.
 * \param      period   The period to configure the PWMs with, in number of PWM peripheral clock
 *                      cycles.
 */
void pwm_set_period(void* dev_base, int32_t period);

/**
 * Set the polarity of all outputs in a phase-locked PWM group.
 *
 * \param [in] dev_base Base address of the PWM peripheral.
 * \param      pol_map  Bitfield specifying the polarity of each output.
 */
void pwm_set_polarity(void* dev_base, uint32_t pol_map);

/**
 * Set the phase alignment type of a group of phase-locked PWMs.
 *
 * |    Alignment Type    |                             Decription                             |
 * |:--------------------:|:------------------------------------------------------------------:|
 * | ::pwm_align_edge     | PWM signals are edge-aligned, and phase offsets are edge-relative. |
 * | ::pwm_aligh_midpulse | PWM signals are mid-pulse aligned, and phase offsets are disabled. |
 *
 * \param [in] dev_base Base address of the PWM peripheral.
 * \param      align    The alignment type to configure the PWM group with.
 */
void pwm_set_alignment(void* dev_base, pwm_eAlignment align);

/**
 * Set the duty cycles of a number of phase-locked PWMs.
 *
 * \param [in] dev_base       Base address of the PWM peripheral.
 * \param      duty           Duty cycle to configure all the specified PWMs with, in number of PWM
 *                            peripheral clock cycles.
 * \param      outputs_to_set Bitfield specifying which phase-locked PWM outputs to configure.
 */
void pwm_set_duty(void* dev_base, int32_t duty, uint32_t outputs_to_set);

/**
 * Set the phase offset of a number of phase-locked PWMs.
 *
 * \param [in] dev_base       Base address of the PWM peripheral.
 * \param      phase          Phase offset to configure all specified PWMs with, in number of PWM
 *                            peripheral clock cycles to be early by.
 * \param      outputs_to_set Bitfield specifying which phase-locked PWM outputs to configure.
 */
void pwm_set_phase(void* dev_base, int32_t phase, uint32_t outputs_to_set);

#endif // #ifndef PHERIH_PWM_HPP
