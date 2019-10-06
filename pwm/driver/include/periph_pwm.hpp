#ifndef PHERIH_PWM_HPP
#define PHERIH_PWM_HPP

#include <cstdint>
#include <cstddef>

#include <bitset>
#include <array>

namespace periph {

    constexpr std::size_t header_size = 16; //!< The size of the PWM peripheral configuration block.
    constexpr std::size_t output_size = 8;  //!< The size of a register block controlling one PWM.
    constexpr std::size_t num_outputs = 32; //!< The number of hardware PWM outputs.

    /**
     * A block of multiple phase-aligned PWM outputs.
     */
    class pwm {
        public:
            /**
             * The point to align the PWM phases at.
             */
            enum class align : bool {
                edge     = 0, //!< Align all PWM outputs at a rising or falling edge.
                midpulse = 1  //!< Align all PWM outputs at the midpoint between edges.
            };

            pwm() = delete;             //!< Disallow default construction.
            ~pwm() = delete;            //!< Disallow destruction.
            pwm( const pwm& ) = delete; //!< Disallow copy construction.
            pwm( pwm&& ) = delete;      //!< Disallow move construction.

            /**
             * Copy the configuration of the given PWM peripheral to this PWM peripheral.
             * 
             * \param[in] rhs The PWM peripheral to copy the configuration of.
             * 
             * \return Returns self-reference.
             */
            pwm& operator=( const pwm& rhs ) = default;

            /**
             * Move the configuration of the given PWM peripheral to this PWM peripheral.
             * 
             * The moved-from PWM peripheral is reset.
             * 
             * \param[in,out] rhs The PWM peripheral to move configurations from and reset.
             * 
             * \return Returns self-reference.
             */
            pwm& operator=( pwm&& rhs );

            /**
             * Reset all PWM outputs, setting their frequencies to zero and pulling the outputs low.
             */
            void reset( void );

            /**
             * Set the period of all PWM outputs.
             * 
             * \param period The period to configure the PWMs with, in number of PWM peripheral
             *               clock cycles.
             */
            void set_period( std::int32_t period );

            /**
             * Set the polarity of a single PWM output.
             * 
             * A high polarity sets the PWM signal's leading edge to a rising edge. A low polarity
             * sets the PWM signal's leading edge to a falling edge.
             * 
             * \tparam N The index of the PWM output to set the polarity of.
             * 
             * \param polarity The polarity to set the given PWM output to.
             */
            template<std::size_t N>
            void set_polarity( std::bitset<1> polarity );

            /**
             * Read the polarity of a single PWM output.
             * 
             * \tparam N The index of the PWM output to read the polarity of.
             * 
             * \return Returns the polarity of the specified output.
             */
            template<std::size_t N>
            std::bitset<1> read_polarity( void ) const;

            /**
             * Set the polarities of all PWM outputs.
             * 
             * \param polarity_map Bitfield specifying the polarity of each output. The LSB
             *                     corresponds to the output with index zero.
             */
            void set_polarity_all( std::bitset<num_outputs> polarity_map );

            /**
             * Read the polarities of all PWM outputs.
             * 
             * \return Returns the polarities of all PWM outputs.
             */
            std::bitset<num_outputs> read_polarity_all( void ) const;

            /**
             * Set the phase alignment mode applying to all PWM outputs.
             * 
             * \param mode The phase alignment mode to use to align all PWM outputs.
             */
            void set_alignment( align mode );

            /**
             * Set the duty time of a single PWM output.
             * 
             * \tparam N The index of the PWM output to set the duty time of.
             * 
             * \param duty Duty time to configure the specified PWM output with, in number of PWM
             *             peripheral clock cycles.
             */
            template<std::size_t N>
            void set_duty( std::int32_t duty );

            /**
             * Set the duty time of all PWM outputs.
             * 
             * \param duty Duty time to configure all PWM outputs with, in number of PWM peripheral
             *             clock cycles.
             */
            void set_duty_all( std::int32_t duty );

            /**
             * Set the phase offset the specified PWM output.
             * 
             * Phase offsets are set relative to the global pulse period, set using
             * set_period( std::int32_t ). When the global pulse alignment mode is set to
             * align::edge, a zero phase offset sets the signal's leading edge to coincide with the
             * beginning of each period. When the global pulse alignment mode is set to
             * align::midpulse, a zero phase offset sets the midpoint between the signal's edges at
             * the middle of each period.
             * 
             * \tparam N The index of the PWM output to set the phase offset of.
             * 
             * \param phase The phase offset to apply to the given PWM output.
             */
            template<std::size_t N>
            void set_phase( std::int32_t phase );

            /**
             * Set the phase offset of all PWM outputs.
             * 
             * Applies the same phase offset, relative to the global pulse period set using
             * set_period( std::int32_t ), to all PWM outputs. This effectively phase-aligns all PWM
             * outputs with each other regardless of the value passed in.
             * 
             * \param phase The phase offset to apply to all PWM outputs.
             */
            void set_phase_all( std::int32_t phase );

        private:
            /**
             * Size-equivalent stand-in for registers controlling a single PWM output.
             */
            using output = std::array<std::byte,output_size>;

            /**
             * Size-equivalent stand-in for all memory-mapped registers in this peripheral device.
             */
            struct {
                std::array<std::byte,header_size> header;  //!< Global configuration registers.
                std::array<output,num_outputs>    outputs; //!< Individual output registers.
            } memory;

            /**
             * Set the duty time of the given PWM output.
             * 
             * \param[out] signal The memory-mapped register block corresponding to the PWM output
             *                    to set the duty time of.
             * \param      duty   The duty time to configure the PWM output with.
             */
            void set_duty_priv( output& signal, std::int32_t duty );

            /**
             * Set the phase offset of the given PWM output.
             * 
             * \param[out] signal The memory-mapped register block corresponding to the PWM output
             *                    to set the phase offset of.
             * \param      phase  The phase offset to configure the PWM output with.
             */
            void set_phase_priv( output& signal, std::int32_t phase );
    };

}

#include "periph_pwm.ipp"

#endif // #ifndef PHERIH_PWM_HPP
