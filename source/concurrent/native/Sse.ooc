/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

version (sse) {
include xmmintrin

M128: cover from __m128
_mm_set_ps: extern func (Float, Float, Float, Float) -> M128
_mm_add_ps: extern func (M128, M128) -> M128
_mm_sub_ps: extern func (M128, M128) -> M128
_mm_mul_ps: extern func (M128, M128) -> M128
_mm_div_ps: extern func (M128, M128) -> M128
_mm_sqrt_ps: extern func (M128) -> M128
_mm_min_ps: extern func (M128, M128) -> M128
_mm_max_ps: extern func (M128, M128) -> M128
_mm_and_ps: extern func (M128, M128) -> M128
_mm_or_ps: extern func (M128, M128) -> M128
}