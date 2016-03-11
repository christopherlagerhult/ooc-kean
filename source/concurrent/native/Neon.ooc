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
UShort16x8: cover from uint16x8_t
vdupq_n_u16: extern func (UShort) -> UShort16x8
vdupq_n_s32: extern func (Int) -> Int32x4
vaddq_u16: extern func (UShort16x8, UShort16x8) -> UShort16x8
vaddq_s32: extern func (Int32x4, Int32x4) -> Int32x4
vmulq_n_u16: extern func (UShort16x8, UShort) -> UShort16x8
vmulq_n_s32: extern func (Int32x4, Int) -> Int32x4
vld1q_u16: extern func (UShort*) -> UShort16x8
vld1q_s32: extern func (Int*) -> Int32x4
vst1q_u16: extern func (UShort*, UShort16x8)
vst1q_s32: extern func (Int*, Int32x4)
vgetq_lane_u16: extern func (UShort16x8, Int) -> UShort
vgetq_lane_s32: extern func (Int32x4, Int) -> Int

div_s32: func (source: Int32x4, value: Int) -> Int32x4 {
	store := malloc(Int size * 4) as Int*
	vst1q_s32(store, source)
	for (i in 0 .. 4)
		store[i] /= value
	result := vld1q_s32(store)
	memfree(store)
	result
}
}
