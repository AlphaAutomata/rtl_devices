#include "periph_pwm.hpp"

typedef struct {
	int32_t duty;
	int32_t phase;
} output_map;

typedef struct {
	uint32_t   cfg;
	uint32_t   period;
	uint32_t   pol_map;
	uint32_t   RESERVED_0x0C;
	output_map out[32];
} pwm_mem_map;

#define NUM_OUTPUTS 4

#define CAST_MEM_MAP(base) ((pwm_mem_map*)(base))

#define CNT_UP_DOWN_BIT (1 << 1)

void pwm_init(void* dev_base, pwm_info* info) {
	pwm_set(dev_base, info);
}

void pwm_set(void* dev_base, pwm_info* info) {
	int i;
	pwm_mem_map* mem;
	
	mem = CAST_MEM_MAP(dev_base);
	
	switch (info->align) {
		case pwm_align_edge     : mem->cfg &= ~(CNT_UP_DOWN_BIT); break;
		case pwm_align_midpulse : mem->cfg |= CNT_UP_DOWN_BIT;    break;
		default                 : return;
	}
	mem->period  = info->period;
	mem->pol_map = info->pol_map;
	for (i=0; i<NUM_OUTPUTS; i++) {
		mem->out[i].duty = info->duty[i];
	}
}

void pwm_set_period(void* dev_base, int32_t period) {
	pwm_mem_map* mem;
	
	mem = CAST_MEM_MAP(dev_base);
	
	mem->period = period;
}

void pwm_set_polarity(void* dev_base, uint32_t pol_map) {
	pwm_mem_map* mem;
	
	mem = CAST_MEM_MAP(dev_base);
	
	mem->pol_map = pol_map;
}

void pwm_set_alignment(void* dev_base, pwm_eAlignment align) {
	pwm_mem_map* mem;
	
	mem = CAST_MEM_MAP(dev_base);
	
	switch (align) {
		case pwm_align_edge     : mem->cfg &= ~(CNT_UP_DOWN_BIT);
		case pwm_align_midpulse : mem->cfg |= CNT_UP_DOWN_BIT;
		default                 : return;
	}
}

void pwm_set_duty(void* dev_base, int32_t duty, uint32_t outputs_to_set) {
	int i;
	pwm_mem_map* mem;
	
	mem = CAST_MEM_MAP(dev_base);
	
	for (i=0; i<NUM_OUTPUTS; i++) {
		if ((outputs_to_set >> i) & 0x00000001) {
			mem->out[i].duty = duty;
		}
	}
}

void pwm_set_phase(void* dev_base, int32_t phase, uint32_t outputs_to_set) {
	int i;
	pwm_mem_map* mem;
	
	mem = CAST_MEM_MAP(dev_base);
	
	for (i=0; i<NUM_OUTPUTS; i++) {
		if ((outputs_to_set >> i) & 0x00000001) {
			mem->out[i].phase = phase;
		}
	}
}
