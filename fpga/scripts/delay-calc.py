#!/usr/bin/env python3

# Light speed in Km/s (void)
cKm_s_void = 299792.0

# Electricity speed in a copper wire (worst case)
cKm_s = 0.59 * cKm_s_void
# cKm_s = 0.77 * cKm_s_void


def signal_prop_delay(factor, cm):
    '''
    Appsox. signal prop. delay.

    :param factor Speed of signal on the wire, expressed as `factor * c`,
    being `c` the speed of light in the void.

    :param cm Centimeters of wire

    '''
    # Light speed in Km/s (void)
    cKm_s_void = 299792.0
    cKm_s = factor * cKm_s_void
    cCm_s = cKm_s * 1e3 * 1e2
    cCm_ns = cCm_s * 1e-9

    # Time (seconds) that takes to travel 1 cm.
    delay_cm_ns = 1.0 / cCm_ns

    return delay_cm_ns * cm


if __name__ == '__main__':
    # Extracted from wikipedia
    worst_case_factor = 0.59
    best_case_factor = 0.77

    print('Min. delay {} ns'.format(signal_prop_delay(best_case_factor, 30)))
    print('Max. delay {} ns'.format(signal_prop_delay(worst_case_factor, 30)))
