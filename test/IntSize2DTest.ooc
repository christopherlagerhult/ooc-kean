use ooc-unit
use ooc-math
import math
import lang/IO
//import ../../../source/FloatExtension

IntSize2DTest: class extends Fixture {
	precision := 1.0f / 1_0000.0f
	vector0 := IntSize2D new (22, -3)
	vector1 := IntSize2D new (12, 13)
	vector2 := IntSize2D new (34, 10)
	vector3 := IntSize2D new (10, 20)
	init: func () {
		super("IntSize2D")
		this add("equality", func() {
			point := IntSize2D new()
//			FIXME: There is no equals interface yet
//			expect(this vector0, is equal to(this vector0))
//			expect(this vector0 equals(this vector0 as Object), is true)
			expect(this vector0 == this vector0, is true)
			expect(this vector0 != this vector1, is true)
			expect(this vector0 == point, is false)
			expect(point == point, is true)
			expect(point == this vector0, is false)
		})
		this add("addition", func() {
			expect((this vector0 + this vector1) width, is equal to(this vector2 width))
			expect((this vector0 + this vector1) height, is equal to(this vector2 height))
		})
		this add("subtraction", func() {
//			FIXME: Unary minus compiler bug
//			expect(this vector0 - this vector0, is equal to(IntSize2D new()))
		})
		this add("scalar multiplication", func() {
//			FIXME: Unary minus compiler bug
//			expect((-1) * this vector0, is equal to(-vector0)) (-1)
		})
		this add("scalar division", func() {
//			FIXME: Unary minus compiler bug
//			expect(this vector0 / (-1), is equal to(-vector0))
		})
		this add("get values", func() {
			expect(this vector0 width, is equal to(22))
			expect(this vector0 height, is equal to(-3))
		})
		this add("swap", func()	{
			result := this vector0 swap() 
			expect(result width, is equal to(this vector0 height))
			expect(result height, is equal to(this vector0 width))
		})
		this add("casting", func() {
			value := "10, 20"
			expect(this vector3 toString(), is equal to(value))
//			FIXME: Equals interface
//			expect(IntSize2D parse(value), is equal to(this vector3))
		})
		this add("casts", func() {
//			FIXME: We have no integer versions of anything yet
		})
	}
}
IntSize2DTest new() run()
