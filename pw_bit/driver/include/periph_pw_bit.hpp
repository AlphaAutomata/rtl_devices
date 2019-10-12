#ifndef PERIPH_PW_BIT_HPP
#define PERIPH_PW_BIT_HPP

#include <cstdint>
#include <cstddef>

#include <array>

namespace periph {

    constexpr std::size_t block_size = 32;

    /**
     * A pulse-width-based bit protocol peripheral.
     */
    class pw_bit {
        public:
            pw_bit() = delete;                //!< Disallow default construction.
            ~pw_bit() = delete;               //!< Disallow construction.
            pw_bit( const pw_bit& ) = delete; //!< Disallow copy construction.
            pw_bit( pw_bit&& ) = delete;      //!< Disallow move construction.

            /**
             * Copy the configuration of the given pulse-width-bit peripheral to this peripheral.
             * 
             * \param[in] rhs The pulse-width-bit peripheral to copy the configuration of.
             * 
             * \return Returns self-reference.
             */
            pw_bit& operator=( const pw_bit& rhs );

            /**
             * Move the configuration of the given pulse-width-bit peripheral to this peripheral.
             * 
             * The moved-from pulse-width-bit peripheral is reset and disabled.
             * 
             * \param[in,out] rhs The pulse-width-bit peripheral to move configurations from.
             * 
             * \return Returns self-reference.
             */
            pw_bit& operator=( pw_bit&& rhs );

            void enable();  //!< Enable this peripheral's output without affecting its settings.
            void disable(); //!< Disable this peripheral's output without affecting its settings.

            /**
             * Write data out through the peripheral.
             * 
             * The lowest bytes are transmitted through the pulse-width-bit protocol. The number of
             * low bytes to transmit are set by set_active_bytes( int ).
             * 
             * \param data The data to write.
             */
            void write( std::uint32_t data );

            /**
             * Set the number of bytes that actually get transmitted when data is written.
             * 
             * On each data write, the lowest \a num_bytes bytes of data are transmitted through the
             * pulse-width-bit protocol.
             * 
             * \param num_bytes The number of bytes to transmit on each write.
             */
            void set_active_bytes( int num_bytes );

            /**
             * Set the transmission pulse period.
             * 
             * \param period The transmission pulse period, in number of peripheral clock cycles.
             */
            void set_period( std::uint32_t period );

            /**
             * Set the transmission pulse-width corresponding to a high bit.
             * 
             * \param period The transmission pulse-width of a high bit, in number of peripheral
             *               clock cycles.
             */
            void set_1b_duty( std::uint32_t duty );

            /**
             * Set the transmission pulse-width corresponding to a low bit.
             * 
             * \param period The transmission pulse-width of a low bit, in number of peripheral
             *               clock cycles.
             */
            void set_0b_duty( std::uint32_t duty );

        private:
            /**
             * Size-equivalent stand-in for all memory-mapped registers in this peripheral device.
             */
            std::array<volatile std::byte,block_size> memory;
    };

}

#endif // #ifndef PERIPH_PW_BIT_HPP
