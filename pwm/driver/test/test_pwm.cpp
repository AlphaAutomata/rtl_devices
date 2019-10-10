#include <cstdint>

#include "periph_pwm.hpp"

periph::pwm* const pwm_0 = (periph::pwm*)(intptr_t)0x43C00000;

int main( int argc, char* argv[] ) {
    pwm_0->reset();
    pwm_0->set_period( 50000 ); // 1ms at 50MHz

    while(true) {
        pwm_0->set_duty<0>( 10000 );
        for ( volatile int i = 0; i < 100000000; i++ );
        pwm_0->set_duty<0>( 25000 );
        for ( volatile int i = 0; i < 100000000; i++ );
    }
}
