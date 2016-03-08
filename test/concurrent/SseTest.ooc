/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

use base
use unit
import ../../source/concurrent/native/Sse
import ../../source/system/Memory

SseTest: class extends Fixture {
	floatResult: static Float*
	intResult: static Int*
	init: func {
		super("Sse")
		this add("set_ps", This _set_ps)
		this add("add_ps", This _add_ps)
		this add("sub_ps", This _sub_ps)
		this add("mul_ps", This _mul_ps)
		this add("div_ps", This _div_ps)
		this add("sqrt_ps", This _sqrt_ps)
		this add("min_ps", This _min_ps)
		this add("max_ps", This _max_ps)
		this add("and_ps", This _and_ps)
		this add("or_ps", This _or_ps)
		this add("set_epi", This _set_epi)
		this add("add_epi", This _add_epi)
		this add("mullo_epi16", This _mullo_epi16)
		this add("cvtps_epi32", This _cvtps_epi32)
		this add("cvtepi32_ps", This _cvtepi32_ps)
	}
	_set_ps: static func {
		length := 4
		posix_memalign(floatResult& as Void**, 16, length * Float size)
		sseResult := floatResult as M128*
		sseResult[0] = _mm_set_ps(1.0f, 2.0f, 3.0f, 4.0f)
		expect(floatResult[3], is equal to(1.0f))
		expect(floatResult[2], is equal to(2.0f))
		expect(floatResult[1], is equal to(3.0f))
		expect(floatResult[0], is equal to(4.0f))
		memfree(floatResult)
	}
	_add_ps: static func {
		length := 4
		posix_memalign(floatResult& as Void**, 16, length * Float size)
		sseResult := floatResult as M128*
		sseResult[0] = _mm_add_ps(_mm_set_ps(1.0f, 2.0f, 3.0f, 4.0f), _mm_set_ps(2.0f, 3.0f, 4.0f, 5.0f))
		expect(floatResult[3], is equal to(3.0f))
		expect(floatResult[2], is equal to(5.0f))
		expect(floatResult[1], is equal to(7.0f))
		expect(floatResult[0], is equal to(9.0f))
		memfree(floatResult)
	}
	_sub_ps: static func {
		length := 4
		posix_memalign(floatResult& as Void**, 16, length * Float size)
		sseResult := floatResult as M128*
		sseResult[0] = _mm_sub_ps(_mm_set_ps(1.0f, 2.0f, 3.0f, 4.0f), _mm_set_ps(2.0f, 3.0f, 4.0f, 5.0f))
		expect(floatResult[3], is equal to(-1.0f))
		expect(floatResult[2], is equal to(-1.0f))
		expect(floatResult[1], is equal to(-1.0f))
		expect(floatResult[0], is equal to(-1.0f))
		memfree(floatResult)
	}
	_mul_ps: static func {
		length := 4
		posix_memalign(floatResult& as Void**, 16, length * Float size)
		sseResult := floatResult as M128*
		sseResult[0] = _mm_mul_ps(_mm_set_ps(1.0f, 2.0f, 3.0f, 4.0f), _mm_set_ps(2.0f, 3.0f, 4.0f, 5.0f))
		expect(floatResult[3], is equal to(2.0f))
		expect(floatResult[2], is equal to(6.0f))
		expect(floatResult[1], is equal to(12.0f))
		expect(floatResult[0], is equal to(20.0f))
		memfree(floatResult)
	}
	_div_ps: static func {
		length := 4
		posix_memalign(floatResult& as Void**, 16, length * Float size)
		sseResult := floatResult as M128*
		sseResult[0] = _mm_div_ps(_mm_set_ps(1.0f, 2.0f, 3.0f, 4.0f), _mm_set_ps(2.0f, 3.0f, 4.0f, 5.0f))
		expect(floatResult[3], is equal to(1.0f/2.0f))
		expect(floatResult[2], is equal to(2.0f/3.0f))
		expect(floatResult[1], is equal to(3.0f/4.0f))
		expect(floatResult[0], is equal to(4.0f/5.0f))
		memfree(floatResult)
	}
	_sqrt_ps: static func {
		length := 4
		posix_memalign(floatResult& as Void**, 16, length * Float size)
		sseResult := floatResult as M128*
		sseResult[0] = _mm_sqrt_ps(_mm_set_ps(1.0f, 2.0f, 3.0f, 4.0f))
		expect(floatResult[3], is equal to(sqrt(1.0f)))
		expect(floatResult[2], is equal to(sqrt(2.0f)))
		expect(floatResult[1], is equal to(sqrt(3.0f)))
		expect(floatResult[0], is equal to(sqrt(4.0f)))
		memfree(floatResult)
	}
	_min_ps: static func {
		length := 4
		posix_memalign(floatResult& as Void**, 16, length * Float size)
		sseResult := floatResult as M128*
		sseResult[0] = _mm_min_ps(_mm_set_ps(1.0f, 3.0f, 0.0f, -4.0f), _mm_set_ps(1.0f, 2.0f, 3.0f, 4.0f))
		expect(floatResult[3], is equal to(1.0f))
		expect(floatResult[2], is equal to(2.0f))
		expect(floatResult[1], is equal to(0.0f))
		expect(floatResult[0], is equal to(-4.0f))
		//memfree(floatResult)
	}
	_max_ps: static func {
		length := 4
		posix_memalign(floatResult& as Void**, 16, length * Float size)
		sseResult := floatResult as M128*
		sseResult[0] = _mm_max_ps(_mm_set_ps(1.0f, 3.0f, 0.0f, -4.0f), _mm_set_ps(1.0f, 2.0f, 3.0f, 4.0f))
		expect(floatResult[3], is equal to(1.0f))
		expect(floatResult[2], is equal to(3.0f))
		expect(floatResult[1], is equal to(3.0f))
		expect(floatResult[0], is equal to(4.0f))
		memfree(floatResult)
	}
	_and_ps: static func {
		length := 4
		posix_memalign(floatResult& as Void**, 16, length * Float size)
		sseResult := floatResult as M128*
		sseResult[0] = _mm_and_ps(_mm_set_ps(1.0f, 3.0f, 0.0f, 4.0f), _mm_set_ps(1.0f, 2.0f, 3.0f, 6.0f))
		expect(floatResult[3], is equal to(1.0f))
		expect(floatResult[2], is equal to(2.0f))
		expect(floatResult[1], is equal to(0.0f))
		expect(floatResult[0], is equal to(4.0f))
		memfree(floatResult)
	}
	_or_ps: static func {
		length := 4
		posix_memalign(floatResult& as Void**, 16, length * Float size)
		sseResult := floatResult as M128*
		sseResult[0] = _mm_or_ps(_mm_set_ps(1.0f, 3.0f, 0.0f, 4.0f), _mm_set_ps(1.0f, 2.0f, 3.0f, 6.0f))
		expect(floatResult[3], is equal to(1.0f))
		expect(floatResult[2], is equal to(3.0f))
		expect(floatResult[1], is equal to(3.0f))
		expect(floatResult[0], is equal to(6.0f))
		memfree(floatResult)
	}
	_set_epi: static func {
		length := 4
		posix_memalign(intResult& as Void**, 16, length * Int size)
		sseResult := intResult as M128i*
		sseResult[0] = _mm_set_epi32(1, 2, 3, 4)
		expect(intResult[3], is equal to(1))
		expect(intResult[2], is equal to(2))
		expect(intResult[1], is equal to(3))
		expect(intResult[0], is equal to(4))
		memfree(intResult)
	}
	_add_epi: static func {
		length := 4
		posix_memalign(intResult& as Void**, 16, length * Int size)
		sseResult := intResult as M128i*
		sseResult[0] = _mm_add_epi32(_mm_set_epi32(1, 2, 3, 4), _mm_set_epi32(1, 2, 3, 4))
		expect(intResult[3], is equal to(2))
		expect(intResult[2], is equal to(4))
		expect(intResult[1], is equal to(6))
		expect(intResult[0], is equal to(8))
		memfree(intResult)
	}
	_mullo_epi16: static func {
		length := 4
		posix_memalign(intResult& as Void**, 16, length * Int size)
		sseResult := intResult as M128i*
		sseResult[0] = _mm_mullo_epi16(_mm_set_epi32(1, 2, 3, 4), _mm_set_epi32(1, 2, 3, 4))
		expect(intResult[3], is equal to(1))
		expect(intResult[2], is equal to(4))
		expect(intResult[1], is equal to(9))
		expect(intResult[0], is equal to(16))
		memfree(intResult)
	}
	_cvtps_epi32: static func {
		length := 4
		posix_memalign(intResult& as Void**, 16, length * Int size)
		sseResult := intResult as M128i*
		sseResult[0] = _mm_cvtps_epi32(_mm_set_ps(1.0f, 2.0f, 3.0f, 4.0f))
		expect(intResult[3], is equal to(1))
		expect(intResult[2], is equal to(2))
		expect(intResult[1], is equal to(3))
		expect(intResult[0], is equal to(4))
		memfree(intResult)
	}
	_cvtepi32_ps: static func {
		length := 4
		posix_memalign(floatResult& as Void**, 16, length * Float size)
		sseResult := floatResult as M128*
		sseResult[0] = _mm_cvtepi32_ps(_mm_set_epi32(1, 2, 3, 4))
		expect(floatResult[3], is equal to(1.0f))
		expect(floatResult[2], is equal to(2.0f))
		expect(floatResult[1], is equal to(3.0f))
		expect(floatResult[0], is equal to(4.0f))
		memfree(floatResult)
	}

}

SseTest new() run() . free()
