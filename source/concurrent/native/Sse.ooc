/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

include xmmintrin
include emmintrin

// TODO: write test for untested parts
M128: cover from __m128
M128i: cover from __m128i
_mm_set_ps: extern func (Float, Float, Float, Float) -> M128
_mm_set_epi32: extern func (Int, Int, Int, Int) -> M128i
_mm_add_ps: extern func (M128, M128) -> M128
_mm_add_epi32: extern func (M128i, M128i) -> M128i
_mm_sub_ps: extern func (M128, M128) -> M128
_mm_mul_ps: extern func (M128, M128) -> M128
_mm_mullo_epi16: extern func (M128i, M128i) -> M128i
_mm_div_ps: extern func (M128, M128) -> M128
_mm_sqrt_ps: extern func (M128) -> M128
_mm_min_ps: extern func (M128, M128) -> M128
_mm_max_ps: extern func (M128, M128) -> M128
_mm_and_ps: extern func (M128, M128) -> M128
_mm_or_ps: extern func (M128, M128) -> M128
_mm_cvtps_epi32: extern func (M128) -> M128i
_mm_cvtepi32_ps: extern func (M128i) ->M128
