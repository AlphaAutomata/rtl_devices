#include <atomic>

#include "periph_pw_bit.hpp"

using namespace periph;

namespace {

    /**
     * Register-wise access struct for pulse-width-bit peripheral memory-mapped registers.
     */
    struct memory_map {
        volatile std::atomic_uint32_t fifo_write;    //!< Data FIFO write register.
        volatile std::uint32_t        byte_mask;     //!< Byte mask register.
        volatile std::uint32_t        RESERVED_0x08; //!< Reserved.
        volatile std::uint32_t        RESERVED_0x0C; //!< Reserved.
        volatile std::uint32_t        period;        //!< Bit period register.
        volatile std::uint32_t        duty_1b;       //!< 1-bit duty time register.
        volatile std::uint32_t        duty_0b;       //!< 0-bit duty time register.
        volatile std::uint32_t        cfg;           //!< Enable register.

        /**
         * Copy configurations from another pulse-width-bit memory block.
         * 
         * \param[in] rhs The peripheral memory block to copy from.
         * 
         * \return Returns self-reference.
         */
        memory_map& operator=( const memory_map& rhs ) {
            this->byte_mask = rhs.byte_mask;
            this->period = rhs.period;
            this->duty_1b = rhs.duty_1b;
            this->duty_0b = rhs.duty_0b;
            this->cfg = rhs.cfg;

            return *this;
        }
    };
    static_assert(
        sizeof( pw_bit ) == sizeof( memory_map ),
        "User handle and register memory map size mismatch"
    );

    /**
     * Cast a user pulse-width-bit class to a register memory map.
     * 
     * \param[in] dev The opaque user class to cast.
     * 
     * \return Returns the memory-mapped registers corresponding to the opaque user class.
     */
    memory_map& to_map( pw_bit& dev ) {
        return *reinterpret_cast<memory_map*>( &dev );
    }

    /**
     * Cast a read-only user pulse-width-bit class to a register memory map.
     * 
     * \param[in] dev The read-only opaque user class to cast.
     * 
     * \return Returns the read-only memory-mapped registers corresponding to the opaque user class.
     */
    const memory_map& to_map( const pw_bit& dev ) {
        return *reinterpret_cast<const memory_map*>( &dev );
    }

}

pw_bit& pw_bit::operator=( const pw_bit& rhs ) {
    to_map( *this ) = to_map( rhs );

    return *this;
}

pw_bit& pw_bit::operator=( pw_bit&& rhs ) {
    auto& other_map = to_map( rhs );

    to_map( *this ) = other_map;

    other_map.byte_mask = 0;
    other_map.period = 0;
    other_map.duty_1b = 0;
    other_map.duty_0b = 0;
    other_map.cfg = 0;

    return *this;
}

void pw_bit::enable() {
    to_map( *this ).cfg = 1;
}

void pw_bit::disable() {
    to_map( *this ).cfg = 0;
}

void pw_bit::write( std::uint32_t data ) {
    to_map( *this ).fifo_write = data;
}

void pw_bit::set_active_bytes( int num_bytes ) {
    switch(num_bytes) {
        case 0  :
            to_map( *this ).byte_mask = 0x00000000;
            break;

        case 1  :
            to_map( *this ).byte_mask = 0x00000001;
            break;

        case 2  :
            to_map( *this ).byte_mask = 0x00000003;
            break;

        case 3  :
            to_map( *this ).byte_mask = 0x00000007;
            break;

        case 4  :
            to_map( *this ).byte_mask = 0x0000000F;
            break;

        default :
            return;
    }
}

void pw_bit::set_period( std::uint32_t period ) {
    to_map( *this ).period = period;
}

void pw_bit::set_1b_duty( std::uint32_t duty ) {
    to_map( *this ).duty_1b = duty;
}

void pw_bit::set_0b_duty( std::uint32_t duty ) {
    to_map( *this ).duty_0b = duty;
}
