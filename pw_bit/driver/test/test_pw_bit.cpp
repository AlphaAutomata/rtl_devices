#include <cstdint>

#include "periph_pw_bit.hpp"

periph::pw_bit* const pwb_0 = (periph::pw_bit*)(intptr_t)0x43C10000;
periph::pw_bit* const pwb_1 = (periph::pw_bit*)(intptr_t)0x43C10020;
periph::pw_bit* const pwb_2 = (periph::pw_bit*)(intptr_t)0x43C10040;
periph::pw_bit* const pwb_3 = (periph::pw_bit*)(intptr_t)0x43C10060;

int main( int argc, char* argv[] ) {
    for ( volatile int i = 0; i < 50000000; i++ );

    pwb_1->set_active_bytes( 3 );
    pwb_1->set_period( 125 );
    pwb_1->set_1b_duty( 80 );
    pwb_1->set_0b_duty( 40 );

    pwb_1->enable();

    while(true) {
        pwb_1->write( 0x000000FF );
        for ( volatile int i = 0; i < 50000000; i++ );
        pwb_1->write( 0x0000FF00 );
        for ( volatile int i = 0; i < 50000000; i++ );
        pwb_1->write( 0x00FF0000 );
        for ( volatile int i = 0; i < 50000000; i++ );
    }
}
