/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */
version(android){
include arm_neon

// TODO: write test
Int32x4: cover from int32x4_t
UInt32x4: cover from uint32x4_t
Float32x4: cover from float32x4_t
//UShort16x8: cover from uint16x8_t
//vdupq_n_u16: extern func (UShort) -> UShort16x8
vdupq_n_s32: extern func (Int) -> Int32x4
vdupq_n_f32: extern func (Float) -> Float32x4
//vaddq_u16: extern func (UShort16x8, UShort16x8) -> UShort16x8
vaddq_s32: extern func (Int32x4, Int32x4) -> Int32x4
vaddq_f32: extern func (Float32x4, Float32x4) -> Float32x4
//vmulq_n_u16: extern func (UShort16x8, UShort) -> UShort16x8
vsubq_s32: extern func (Int32x4, Int32x4) -> Int32x4
vsubq_f32: extern func (Float32x4, Float32x4) -> Float32x4
vmulq_f32: extern func (Float32x4, Float32x4) -> Float32x4
vmulq_s32: extern func (Int32x4, Int32x4) -> Int32x4
vmulq_n_s32: extern func (Int32x4, Int) -> Int32x4
//vld1q_u16: extern func (UShort*) -> UShort16x8
vld1q_s32: extern func (Int*) -> Int32x4
vld1q_f32: extern func (Float*) -> Float32x4
vgetq_lane_f32: extern func(Float32x4, Int) -> Float
vgetq_lane_s32: extern func(Int32x4, Int) -> Int
//vst1q_u16: extern func (UShort*, UShort16x8)
vst1q_s32: extern func (Int*, Int32x4)
vst1q_u32: extern func (UInt*, UInt32x4)
vst1q_f32: extern func (Float*, Float32x4)
vcvtq_f32_s32: extern func (Int32x4) -> Float32x4
vcvtq_s32_f32: extern func (Float32x4) -> Int32x4
//vreinterpretq_s32_f32: extern func (Float32x4) -> Int32x4
vrecpeq_f32: extern func (Float32x4) -> Float32x4
vrecpsq_f32: extern func (Float32x4, Float32x4) -> Float32x4

vcltq_f32: extern func (Float32x4, Float32x4) -> UInt32x4
vcgtq_f32: extern func (Float32x4, Float32x4) -> UInt32x4
vclgq_s32: extern func (Int32x4, Int32x4) -> UInt32x4
vbslq_f32: extern func (UInt32x4, Float32x4, Float32x4) -> Float32x4

div_s32: func (source: Int32x4, value: Int) -> Int32x4 {
	//vcvtq_s32_f32(vmulq_f32(vcvtq_f32_s32(source), vrecpeq_f32(vdupq_n_f32(value as Float))))
	vcvtq_s32_f32(div_f32(vcvtq_f32_s32(source), value as Float))
}
div_f32: func (source: Float32x4, value: Float) -> Float32x4 {
	neonValue := vdupq_n_f32(value)
	reciprocal := vrecpeq_f32(neonValue)
	reciprocal = vmulq_f32(vrecpsq_f32(neonValue, reciprocal), reciprocal)
	reciprocal = vmulq_f32(vrecpsq_f32(neonValue, reciprocal), reciprocal)
	vmulq_f32(source, reciprocal)
}

/*div_u16: func (source: UShort16x8, value: Int) -> UShort16x8 {
	//vcvtq_s32_f32(vmulq_f32(vcvtq_f32_s32(source), vrecpeq_f32(vdupq_n_f32(value as Float))))


	store := malloc(UShort size * 8) as UShort*
	vst1q_u16(store, source)
	for (i in 0 .. 8)
		store[i] /= value
	result := vld1q_u16(store)
	memfree(store)
	result
}*/
}
