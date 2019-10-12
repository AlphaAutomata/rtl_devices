# from 3.3 onwards, detecting whether a string exists in a list has a new syntax using if()
cmake_minimum_required(VERSION 3.3)

####################################
# Set Project-Level Configurations #
####################################

project(rtl_periph CXX)

# set language standards
set(CMAKE_CXX_STANDARD          17)
set(CMAKE_CXX_STANDARD_REQUIRED TRUE)

# set the policy to enable inter-procedural optimization if available
if(POLICY CMP0069)
    cmake_policy(SET CMP0069 NEW)
endif()
if(NOT DEFINED IPO_SUPPORTED)
    # check for inter-procedural optimization support
    include(CheckIPOSupported OPTIONAL RESULT_VARIABLE HAS_CHECK_IPO)
    if(HAS_CHECK_IPO)
        message(STATUS "Determining inter-procedural optimization support")
        
        check_ipo_supported(RESULT IPO)
        
        if(IPO)
            message(STATUS "Inter-procedural optimization enabled")
        else()
            message(STATUS "Inter-procedural optimization disabled")
        endif()
    else()
        message(STATUS "Cannot determine inter-procedural optimization support")
        message(STATUS "Inter-procedural optimization is disabled")
        
        set(IPO FALSE)
    endif()
    
    set(IPO_SUPPORTED ${IPO} CACHE STRING "Inter-procedural optimization support")
    set(CMAKE_INTERPROCEDURAL_OPTIMIZATION ${IPO} CACHE INTERNAL "" FORCE)
endif()

######################
# Derive Directories #
######################

set(PWM_DIR ${CMAKE_CURRENT_LIST_DIR}/pwm/driver)

set(PWM_INC_DIR ${PWM_DIR}/include)
set(PWM_IPP_DIR ${PWM_INC_DIR}/ipp)
set(PWM_SRC_DIR ${PWM_DIR}/src)

set(PWB_DIR ${CMAKE_CURRENT_LIST_DIR}/pw_bit/driver)

set(PWB_INC_DIR ${PWB_DIR}/include)
set(PWB_IPP_DIR ${PWB_INC_DIR}/ipp)
set(PWB_SRC_DIR ${PWB_DIR}/src)

#########################
# Gather Target Sources #
#########################

set(PWM_INC_FILES ${PWM_INC_DIR}/periph_pwm.hpp)
set(PWM_IPP_FILES ${PWM_IPP_DIR}/periph_pwm.ipp)
set(PWM_SRC_FILES ${PWM_SRC_DIR}/periph_pwm.cpp)

set(TEST_PWM_SRC_FILES ${PWM_DIR}/test/test_pwm.cpp PARENT_SCOPE)

set(PWB_INC_FILES ${PWB_INC_DIR}/periph_pw_bit.hpp)
set(PWB_SRC_FILES ${PWB_SRC_DIR}/periph_pw_bit.cpp)

set(TEST_PWB_SRC_FILES ${PWB_DIR}/test/test_pw_bit.cpp PARENT_SCOPE)

############################
# Configure Library Target #
############################

# compile peripheral interface library as static library
add_library(
    periph
    STATIC
        ${PWM_INC_FILES}
        ${PWM_IPP_FILES}
        ${PWM_SRC_FILES}
        ${PWB_INC_FILES}
        ${PWB_SRC_FILES}
)
# set include directories
target_include_directories(
    periph
    PUBLIC
        ${PWM_INC_DIR}
        ${PWM_IPP_DIR}
        ${PWB_INC_DIR}
)
