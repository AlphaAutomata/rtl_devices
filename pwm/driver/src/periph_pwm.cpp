#include <cstring>

#include "periph_pwm.hpp"

using namespace periph;

namespace {

    /**
     * Bitwise access struct for PWM peripheral configuration register.
     */
    struct cfg_reg {
        volatile std::uint32_t RESERVED_0 : 30; //!< Reserved uppermost 30 bits.
        volatile pwm::align    alignment  : 1;  //!< The phase alignment mode bit.
        volatile std::uint32_t RESERVED_1 : 1;  //!< Reserved least-significant-bit.
    };
    static_assert(
        sizeof( cfg_reg ) == sizeof( std::uint32_t ),
        "Invalid configuration register struct size"
    );

    /**
     * Register-wise access struct for individual PWM output configuration registers.
     */
    struct output_cfg {
        volatile std::int32_t duty;  //!< The duty time register.
        volatile std::int32_t phase; //!< The phase offset register.
    };

    /**
     * Register-wise access struct for memory-mapped PWM peripheral.
     */
    struct memory_map {
        volatile cfg_reg                   config;        //!< Device-wide configuration registers.
        volatile std::uint32_t             period;        //!< Device-wide PWM pulse period.
        volatile std::uint32_t             pol_map;       //!< Per-output polarity control register.
        volatile std::uint32_t             RESERVED_0x0C; //!< Reserved register.
        std::array<output_cfg,num_outputs> outputs;       //!< Per-output configuration registers.
    };
    static_assert(
        sizeof( pwm ) == sizeof( memory_map ),
        "User handle and register memory map size mismatch"
    );

    /**
     * Cast a memory-mapped register type to a normal data type.
     * 
     * \tparam T The normal type to cast to.
     * 
     * \param [in] val The value to cast.
     * 
     * \return Returns the original value cast to a normal type.
     */
    template<typename T>
    T& normal_type( volatile T& val ) {
        return const_cast<T&>( val );
    }

    /**
     * Cast a PWM user class to a register memory map.
     */
    memory_map& to_map( pwm& dev ) {
        return *reinterpret_cast<memory_map*>( &dev );
    }

    /**
     * Cast a read-only PWM user class to a register memory map.
     */
    const memory_map& to_map( const pwm& dev ) {
        return *reinterpret_cast<const memory_map*>( &dev );
    }

    /**
     * Cast a PWM output memory-mapped register block to a register memory map.
     */
    output_cfg& to_map( std::array<volatile std::byte,output_size>& output ) {
        static_assert(
            sizeof( output ) == sizeof( output_cfg ),
            "User handle and register memory map size mismatch"
        );

        return *reinterpret_cast<output_cfg*>( &output );
    }

}

pwm& pwm::operator=( pwm&& rhs ) {
    *this = rhs;
    rhs.reset();

    return *this;
}

void pwm::reset( void ) {
    memset( &memory, 0, sizeof(memory) );
}

void pwm::set_period( std::int32_t period ) {
    to_map( *this ).period = period;
}

void pwm::set_polarity_all( std::bitset<num_outputs> polarity_map ) {
    to_map( *this ).pol_map = polarity_map.to_ulong();
}

std::bitset<num_outputs> pwm::read_polarity_all( void ) const {
    return normal_type( to_map( *this ).pol_map );
}

void pwm::set_alignment( align mode ) {
    to_map( *this ).config.alignment = mode;
}

void pwm::set_duty_all( std::int32_t duty ) {
    for ( auto& output : to_map( *this ).outputs ) {
        output.duty = duty;
    }
}

void pwm::set_phase_all( std::int32_t phase ) {
    for ( auto& output : to_map( *this ).outputs ) {
        output.phase = phase;
    }
}

void pwm::set_duty_priv( output& signal, std::int32_t duty ) {
    to_map( signal ).duty = duty;
}

void pwm::set_phase_priv( output& signal, std::int32_t phase ) {
    to_map( signal ).phase = phase;
}
