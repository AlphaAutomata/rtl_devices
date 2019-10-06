
namespace periph {

    template<std::size_t N>
    void pwm::set_polarity( std::bitset<1> polarity ) {
        static_assert( ( N >= 0 ) && ( N < num_outputs ), "Invalid PWM output index" );

        auto pols = read_polarity_all();
        pols.set( N, polarity[0] );

        set_polarity_all( pols );
    }

    template<std::size_t N>
    std::bitset<1> pwm::read_polarity( void ) const {
        static_assert( ( N >= 0 ) && ( N < num_outputs ), "Invalid PWM output index" );

        std::bitset<1> ret;
        ret[0] = read_polarity_all()[N];

        return ret;
    }

    template<std::size_t N>
    void pwm::set_duty( std::int32_t duty ) {
        static_assert( ( N >= 0 ) && ( N < num_outputs ), "Invalid PWM output index" );

        set_duty_priv( memory.outputs[N], duty );
    }

    template<std::size_t N>
    void pwm::set_phase( std::int32_t phase ) {
        static_assert( ( N >= 0 ) && ( N < num_outputs ), "Invalid PWM output index" );

        set_phase_priv( memory.outputs[N], phase );
    }

}
