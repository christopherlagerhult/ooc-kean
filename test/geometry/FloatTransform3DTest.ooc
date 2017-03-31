/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016-2017 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

use unit
use geometry

FloatTransform3DTest: class extends Fixture {
	transform0 := FloatTransform3D new(-1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12)
	transform1 := FloatTransform3D new(-1, 2, 3, 4, 5, 6, 7, 8, -5, 10, 11, 12)
	transform2 := FloatTransform3D new(30, 32, 36, 58, 81, 96, -10, 14, 24, 128, 182, 216)
	transform3 := FloatTransform3D new(0.5f, 1, -0.5f, 1, -5, 3, -0.5f, 3.66666666666666f, -2.16666666666667f, 0, 1, -2)
	transform4 := FloatTransform3D new(10, 20, 30, 40, 50, 60, 70, 80, 90, 100, 110, 120)
	transform5 := FloatTransform3D new(1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1)
	point0 := FloatPoint3D new(34, 10, 30)
	point1 := FloatPoint3D new(226, 369, 444)
	init: func {
		tolerance := 1.0e-5f
		super("FloatTransform3D")
		this add("fixture", func {
			expect(this transform0, is equal to(this transform0))
		})
		this add("equality", func {
			transform := FloatTransform3D new()
			expect(this transform0 == this transform0, is true)
			expect(this transform0 == this transform1, is false)
			expect(this transform0 == transform, is false)
			expect(transform == transform, is true)
			expect(transform == this transform0, is false)
		})
		this add("determinant", func {
			expect(this transform0 determinant, is equal to(6.0f) within(tolerance))
			transform := FloatTransform3D new()
			expect(transform determinant, is equal to(0.0f) within(tolerance))
		})
		this add("inverse transform", func {
			transform := FloatTransform3D new(0.035711678574190f, 0.849129305868777f, 0.933993247757551f, 0.678735154857773f, 0.757740130578333f, 0.743132468124916f, 0.392227019534168f, 0.655477890177557f, 0.171186687811562f, 0.706046088019609f, 0.031832846377421f, 0.276922984960890f)
			transformInverseCorrect := FloatTransform3D new(-1.304260393891308f, 1.703723523873863f, -0.279939209639535f, 0.639686782697661f, -1.314595978968342f, 2.216619899417434f, 0.538976631155336f, 1.130007253038916f, -2.004511083979782f, 0.751249880258891f, -1.473984978790241f, 0.682183855876876f)
			transformInverse := transform inverse
			expect(transformInverse a, is equal to(transformInverseCorrect a) within(tolerance))
			expect(transformInverse b, is equal to(transformInverseCorrect b) within(tolerance))
			expect(transformInverse c, is equal to(transformInverseCorrect c) within(tolerance))
			expect(transformInverse d, is equal to(transformInverseCorrect d) within(tolerance))
			expect(transformInverse e, is equal to(transformInverseCorrect e) within(tolerance))
			expect(transformInverse f, is equal to(transformInverseCorrect f) within(tolerance))
			expect(transformInverse g, is equal to(transformInverseCorrect g) within(tolerance))
			expect(transformInverse h, is equal to(transformInverseCorrect h) within(tolerance))
			expect(transformInverse i, is equal to(transformInverseCorrect i) within(tolerance))
			expect(transformInverse j, is equal to(transformInverseCorrect j) within(tolerance))
			expect(transformInverse k, is equal to(transformInverseCorrect k) within(tolerance))
			expect(transformInverse l, is equal to(transformInverseCorrect l) within(tolerance))
		})
		this add("multiplication transform - transform", func {
			result := this transform0 * this transform1
			expect(result == this transform2)
		})
		this add("multiplication transform - point", func {
			result := this transform0 * this point0
			expect(result == this point1)
		})
		this add("create zero transform", func {
			transform := FloatTransform3D new()
			expect(transform a, is equal to(0.0f) within(tolerance))
			expect(transform b, is equal to(0.0f) within(tolerance))
			expect(transform c, is equal to(0.0f) within(tolerance))
			expect(transform d, is equal to(0.0f) within(tolerance))
			expect(transform e, is equal to(0.0f) within(tolerance))
			expect(transform f, is equal to(0.0f) within(tolerance))
			expect(transform g, is equal to(0.0f) within(tolerance))
			expect(transform h, is equal to(0.0f) within(tolerance))
			expect(transform i, is equal to(0.0f) within(tolerance))
			expect(transform j, is equal to(0.0f) within(tolerance))
			expect(transform k, is equal to(0.0f) within(tolerance))
			expect(transform l, is equal to(0.0f) within(tolerance))
		})
		this add("create identity", func {
			transform := FloatTransform3D identity
			expect(transform a, is equal to(1.0f) within(tolerance))
			expect(transform b, is equal to(0.0f) within(tolerance))
			expect(transform c, is equal to(0.0f) within(tolerance))
			expect(transform d, is equal to(0.0f) within(tolerance))
			expect(transform e, is equal to(0.0f) within(tolerance))
			expect(transform f, is equal to(1.0f) within(tolerance))
			expect(transform g, is equal to(0.0f) within(tolerance))
			expect(transform h, is equal to(0.0f) within(tolerance))
			expect(transform i, is equal to(0.0f) within(tolerance))
			expect(transform j, is equal to(0.0f) within(tolerance))
			expect(transform k, is equal to(1.0f) within(tolerance))
			expect(transform l, is equal to(0.0f) within(tolerance))
			expect(transform m, is equal to(0.0f) within(tolerance))
			expect(transform n, is equal to(0.0f) within(tolerance))
			expect(transform o, is equal to(0.0f) within(tolerance))
			expect(transform p, is equal to(1.0f) within(tolerance))
		})
		this add("scale", func {
			scale := 20.0f
			transform := FloatTransform3D createScaling(scale)
			transform = transform scale(1.0f / scale)
			expect(transform a, is equal to(1.0f) within(tolerance))
			expect(transform b, is equal to(0.0f) within(tolerance))
			expect(transform c, is equal to(0.0f) within(tolerance))
			expect(transform d, is equal to(0.0f) within(tolerance))
			expect(transform e, is equal to(0.0f) within(tolerance))
			expect(transform f, is equal to(1.0f) within(tolerance))
			expect(transform g, is equal to(0.0f) within(tolerance))
			expect(transform h, is equal to(0.0f) within(tolerance))
			expect(transform i, is equal to(0.0f) within(tolerance))
			expect(transform j, is equal to(0.0f) within(tolerance))
			expect(transform k, is equal to(1.0f) within(tolerance))
			expect(transform l, is equal to(0.0f) within(tolerance))
			expect(transform m, is equal to(0.0f) within(tolerance))
			expect(transform n, is equal to(0.0f) within(tolerance))
			expect(transform o, is equal to(0.0f) within(tolerance))
			expect(transform p, is equal to(1.0f) within(tolerance))
		})
		this add("translate", func {
			xDelta := 40.0f
			yDelta := -40.0f
			zDelta := 30.0f
			transform := FloatTransform3D createTranslation(xDelta, yDelta, zDelta)
			transform = transform translate(-xDelta, -yDelta, -zDelta)
			expect(transform a, is equal to(1.0f) within(tolerance))
			expect(transform b, is equal to(0.0f) within(tolerance))
			expect(transform c, is equal to(0.0f) within(tolerance))
			expect(transform d, is equal to(0.0f) within(tolerance))
			expect(transform e, is equal to(0.0f) within(tolerance))
			expect(transform f, is equal to(1.0f) within(tolerance))
			expect(transform g, is equal to(0.0f) within(tolerance))
			expect(transform h, is equal to(0.0f) within(tolerance))
			expect(transform i, is equal to(0.0f) within(tolerance))
			expect(transform j, is equal to(0.0f) within(tolerance))
			expect(transform k, is equal to(1.0f) within(tolerance))
			expect(transform l, is equal to(0.0f) within(tolerance))
			expect(transform m, is equal to(0.0f) within(tolerance))
			expect(transform n, is equal to(0.0f) within(tolerance))
			expect(transform o, is equal to(0.0f) within(tolerance))
			expect(transform p, is equal to(1.0f) within(tolerance))
		})
		this add("create rotation x", func {
			angle := Float pi / 9.0f
			transform := FloatTransform3D createRotationX(angle)
			expect(transform a, is equal to(1.0f) within(tolerance))
			expect(transform b, is equal to(0.0f) within(tolerance))
			expect(transform c, is equal to(0.0f) within(tolerance))
			expect(transform d, is equal to(0.0f) within(tolerance))
			expect(transform e, is equal to(0.0f) within(tolerance))
			expect(transform f, is equal to(angle cos()) within(tolerance))
			expect(transform g, is equal to(angle sin()) within(tolerance))
			expect(transform h, is equal to(0.0f) within(tolerance))
			expect(transform i, is equal to(0.0f) within(tolerance))
			expect(transform j, is equal to((-angle) sin()) within(tolerance))
			expect(transform k, is equal to(angle cos()) within(tolerance))
			expect(transform l, is equal to(0.0f) within(tolerance))
			expect(transform m, is equal to(0.0f) within(tolerance))
			expect(transform n, is equal to(0.0f) within(tolerance))
			expect(transform o, is equal to(0.0f) within(tolerance))
			expect(transform p, is equal to(1.0f) within(tolerance))
		})
		this add("create rotation y", func {
			angle := Float pi / 9.0f
			transform := FloatTransform3D createRotationY(angle)
			expect(transform a, is equal to(angle cos()) within(tolerance))
			expect(transform b, is equal to(0.0f) within(tolerance))
			expect(transform c, is equal to(-angle sin()) within(tolerance))
			expect(transform d, is equal to(0.0f) within(tolerance))
			expect(transform e, is equal to(0.0f) within(tolerance))
			expect(transform f, is equal to(1.0f) within(tolerance))
			expect(transform g, is equal to(0.0f) within(tolerance))
			expect(transform h, is equal to(0.0f) within(tolerance))
			expect(transform i, is equal to(angle sin()) within(tolerance))
			expect(transform j, is equal to(0.0f) within(tolerance))
			expect(transform k, is equal to(angle cos()) within(tolerance))
			expect(transform l, is equal to(0.0f) within(tolerance))
			expect(transform m, is equal to(0.0f) within(tolerance))
			expect(transform n, is equal to(0.0f) within(tolerance))
			expect(transform o, is equal to(0.0f) within(tolerance))
			expect(transform p, is equal to(1.0f) within(tolerance))
		})
		this add("create rotation z", func {
			angle := Float pi / 9.0f
			transform := FloatTransform3D createRotationZ(angle)
			expect(transform a, is equal to(angle cos()) within(tolerance))
			expect(transform b, is equal to(angle sin()) within(tolerance))
			expect(transform c, is equal to(0.0f) within(tolerance))
			expect(transform d, is equal to(0.0f) within(tolerance))
			expect(transform e, is equal to(-angle sin()) within(tolerance))
			expect(transform f, is equal to(angle cos()) within(tolerance))
			expect(transform g, is equal to(0.0f) within(tolerance))
			expect(transform h, is equal to(0.0f) within(tolerance))
			expect(transform i, is equal to(0.0f) within(tolerance))
			expect(transform j, is equal to(0.0f) within(tolerance))
			expect(transform k, is equal to(1.0f) within(tolerance))
			expect(transform l, is equal to(0.0f) within(tolerance))
			expect(transform m, is equal to(0.0f) within(tolerance))
			expect(transform n, is equal to(0.0f) within(tolerance))
			expect(transform o, is equal to(0.0f) within(tolerance))
			expect(transform p, is equal to(1.0f) within(tolerance))
		})
		this add("create scale", func {
			scale := 20.0f
			transform := FloatTransform3D createScaling(scale, scale, scale)
			expect(transform a, is equal to(scale) within(tolerance))
			expect(transform b, is equal to(0.0f) within(tolerance))
			expect(transform c, is equal to(0.0f) within(tolerance))
			expect(transform d, is equal to(0.0f) within(tolerance))
			expect(transform e, is equal to(0.0f) within(tolerance))
			expect(transform f, is equal to(scale) within(tolerance))
			expect(transform g, is equal to(0.0f) within(tolerance))
			expect(transform h, is equal to(0.0f) within(tolerance))
			expect(transform i, is equal to(0.0f) within(tolerance))
			expect(transform j, is equal to(0.0f) within(tolerance))
			expect(transform k, is equal to(scale) within(tolerance))
			expect(transform l, is equal to(0.0f) within(tolerance))
			expect(transform m, is equal to(0.0f) within(tolerance))
			expect(transform n, is equal to(0.0f) within(tolerance))
			expect(transform o, is equal to(0.0f) within(tolerance))
			expect(transform p, is equal to(1.0f) within(tolerance))
		})
		this add("create translation", func {
			xDelta := 40.0f
			yDelta := -40.0f
			zDelta := 30.0f
			transform := FloatTransform3D createTranslation(xDelta, yDelta, zDelta)
			expect(transform a, is equal to(1.0f) within(tolerance))
			expect(transform b, is equal to(0.0f) within(tolerance))
			expect(transform c, is equal to(0.0f) within(tolerance))
			expect(transform d, is equal to(0.0f) within(tolerance))
			expect(transform e, is equal to(0.0f) within(tolerance))
			expect(transform f, is equal to(1.0f) within(tolerance))
			expect(transform g, is equal to(0.0f) within(tolerance))
			expect(transform h, is equal to(0.0f) within(tolerance))
			expect(transform i, is equal to(0.0f) within(tolerance))
			expect(transform j, is equal to(0.0f) within(tolerance))
			expect(transform k, is equal to(1.0f) within(tolerance))
			expect(transform l, is equal to(0.0f) within(tolerance))
			expect(transform m, is equal to(xDelta) within(tolerance))
			expect(transform n, is equal to(yDelta) within(tolerance))
			expect(transform o, is equal to(zDelta) within(tolerance))
			expect(transform p, is equal to(1.0f) within(tolerance))
		})
		this add("get scalingX", func {
			scale := this transform0 scalingX
			expect(scale, is equal to(3.7416575f) within(tolerance))
		})
		this add("get scalingY", func {
			scale := this transform0 scalingY
			expect(scale, is equal to(8.77496433f) within(tolerance))
		})
		this add("get scalingZ", func {
			scale := this transform0 scalingZ
			expect(scale, is equal to(13.9283886f) within(tolerance))
		})
		this add("get scaling", func {
			scale := this transform0 scaling
			expect(scale as Float, is equal to(8.8150f) within(tolerance))
		})
		this add("get translation", func {
			translation := this transform0 translation
			expect(translation x, is equal to(10.0f) within(tolerance))
			expect(translation y, is equal to(11.0f) within(tolerance))
			expect(translation z, is equal to(12.0f) within(tolerance))
		})
		this add("casting", func {
			value := "10.00000000, 40.00000000, 70.00000000, 100.00000000\n20.00000000, 50.00000000, 80.00000000, 110.00000000\n30.00000000, 60.00000000, 90.00000000, 120.00000000\n0.00000000, 0.00000000, 0.00000000, 1.00000000"
			string := this transform4 toString()
			expect(string, is equal to(value))
			string free()
		})
		this add("setScaling", func {
			transform := this transform0 setScaling(4.0f)
			expect(transform a, is equal to (-0.45377181f) within (tolerance))
			expect(transform b, is equal to (0.907543614f) within (tolerance))
			expect(transform c, is equal to (1.361315421f) within (tolerance))
			expect(transform d, is equal to (0.0f) within (tolerance))
			expect(transform e, is equal to (1.815087228f) within (tolerance))
			expect(transform f, is equal to (2.268859035f) within (tolerance))
			expect(transform g, is equal to (2.722630842f) within (tolerance))
			expect(transform h, is equal to (0.0f) within (tolerance))
			expect(transform i, is equal to (3.176402649f) within (tolerance))
			expect(transform j, is equal to (3.630174456f) within (tolerance))
			expect(transform k, is equal to (4.083946263f) within (tolerance))
			expect(transform l, is equal to (0.0f) within (tolerance))
			expect(transform m, is equal to (4.53771807f) within (tolerance))
			expect(transform n, is equal to (4.99148988f) within (tolerance))
			expect(transform o, is equal to (5.44526168f) within (tolerance))
			expect(transform p, is equal to (1.0f) within (tolerance))
		})
		this add("setXScaling", func {
			transform := this transform0 setXScaling(4.0f)
			expect(transform a, is equal to (-1.06904497f) within (tolerance))
			expect(transform b, is equal to (2.0f) within (tolerance))
			expect(transform c, is equal to (3.0f) within (tolerance))
			expect(transform d, is equal to (0.0f) within (tolerance))
			expect(transform e, is equal to (4.2761798704f) within (tolerance))
			expect(transform f, is equal to (5.0f) within (tolerance))
			expect(transform g, is equal to (6.0f) within (tolerance))
			expect(transform h, is equal to (0.0f) within (tolerance))
			expect(transform i, is equal to (7.4833147732f) within (tolerance))
			expect(transform j, is equal to (8.0f) within (tolerance))
			expect(transform k, is equal to (9.0f) within (tolerance))
			expect(transform l, is equal to (0.0f) within (tolerance))
			expect(transform m, is equal to (10.690449676f) within (tolerance))
			expect(transform n, is equal to (11.0f) within (tolerance))
			expect(transform o, is equal to (12.0f) within (tolerance))
			expect(transform p, is equal to (1.0f) within (tolerance))
		})
		this add("setYScaling", func {
			transform := this transform0 setYScaling(4.0f)
			expect(transform a, is equal to (-1.0f) within (tolerance))
			expect(transform b, is equal to (0.9116846116f) within (tolerance))
			expect(transform c, is equal to (3.0f) within (tolerance))
			expect(transform d, is equal to (0.0f) within (tolerance))
			expect(transform e, is equal to (4.0f) within (tolerance))
			expect(transform f, is equal to (2.279211529f) within (tolerance))
			expect(transform g, is equal to (6.0f) within (tolerance))
			expect(transform h, is equal to (0.0f) within (tolerance))
			expect(transform i, is equal to (7.0f) within (tolerance))
			expect(transform j, is equal to (3.6467384464f) within (tolerance))
			expect(transform k, is equal to (9.0f) within (tolerance))
			expect(transform l, is equal to (0.0f) within (tolerance))
			expect(transform m, is equal to (10.0f) within (tolerance))
			expect(transform n, is equal to (5.0142653638f) within (tolerance))
			expect(transform o, is equal to (12.0f) within (tolerance))
			expect(transform p, is equal to (1.0f) within (tolerance))
		})
		this add("setZScaling", func {
			transform := this transform0 setZScaling(4.0f)
			expect(transform a, is equal to (-1.0f) within (tolerance))
			expect(transform b, is equal to (2.0f) within (tolerance))
			expect(transform c, is equal to (0.8615497905f) within (tolerance))
			expect(transform d, is equal to (0.0f) within (tolerance))
			expect(transform e, is equal to (4.0f) within (tolerance))
			expect(transform f, is equal to (5.0f) within (tolerance))
			expect(transform g, is equal to (1.723099581f) within (tolerance))
			expect(transform h, is equal to (0.0f) within (tolerance))
			expect(transform i, is equal to (7.0f) within (tolerance))
			expect(transform j, is equal to (8.0f) within (tolerance))
			expect(transform k, is equal to (2.5846493715f) within (tolerance))
			expect(transform l, is equal to (0.0f) within (tolerance))
			expect(transform m, is equal to (10.0f) within (tolerance))
			expect(transform n, is equal to (11.0f) within (tolerance))
			expect(transform o, is equal to (3.446199162f) within (tolerance))
			expect(transform p, is equal to (1.0f) within (tolerance))
		})
		this add("rotateX", func {
			transform := this transform0 rotateX(Float pi / 4)
			expect(transform a, is equal to (-1.0f) within (tolerance))
			expect(transform b, is equal to (-0.70710678f) within (tolerance))
			expect(transform c, is equal to (3.535533906f) within (tolerance))
			expect(transform d, is equal to (0.0f) within (tolerance))
			expect(transform e, is equal to (4.0f) within (tolerance))
			expect(transform f, is equal to (-0.70710678f) within (tolerance))
			expect(transform g, is equal to (7.7781745932f) within (tolerance))
			expect(transform h, is equal to (0.0f) within (tolerance))
			expect(transform i, is equal to (7.0f) within (tolerance))
			expect(transform j, is equal to (-0.70710678f) within (tolerance))
			expect(transform k, is equal to (12.0208152804f) within (tolerance))
			expect(transform l, is equal to (0.0f) within (tolerance))
			expect(transform m, is equal to (10.0f) within (tolerance))
			expect(transform n, is equal to (-0.70710678f) within (tolerance))
			expect(transform o, is equal to (16.2634559676f) within (tolerance))
			expect(transform p, is equal to (1.0f) within (tolerance))
		})
		this add("rotateY", func {
			transform := this transform0 rotateY(Float pi / 4)
			expect(transform a, is equal to (1.4142135588f) within (tolerance))
			expect(transform b, is equal to (2.0f) within (tolerance))
			expect(transform c, is equal to (2.8284271236f) within (tolerance))
			expect(transform d, is equal to (0.0f) within (tolerance))
			expect(transform e, is equal to (7.0710678048f) within (tolerance))
			expect(transform f, is equal to (5.0f) within (tolerance))
			expect(transform g, is equal to (1.4142135672f) within (tolerance))
			expect(transform h, is equal to (0.0f) within (tolerance))
			expect(transform i, is equal to (11.3137084884f) within (tolerance))
			expect(transform j, is equal to (8.0f) within (tolerance))
			expect(transform k, is equal to (1.4142135708f) within (tolerance))
			expect(transform l, is equal to (0.0f) within (tolerance))
			expect(transform m, is equal to (15.556349172f) within (tolerance))
			expect(transform n, is equal to (11.0f) within (tolerance))
			expect(transform o, is equal to (1.4142135744f) within (tolerance))
			expect(transform p, is equal to (1.0f) within (tolerance))
		})
		this add("rotateZ", func {
			transform := this transform0 rotateZ(Float pi / 4)
			expect(transform a, is equal to (-2.121320343f) within (tolerance))
			expect(transform b, is equal to (0.7071067814f) within (tolerance))
			expect(transform c, is equal to (3.0f) within (tolerance))
			expect(transform d, is equal to (0.0f) within (tolerance))
			expect(transform e, is equal to (-0.7071067802f) within (tolerance))
			expect(transform f, is equal to (6.36396103f) within (tolerance))
			expect(transform g, is equal to (6.0f) within (tolerance))
			expect(transform h, is equal to (0.0f) within (tolerance))
			expect(transform i, is equal to (-0.7071067796f) within (tolerance))
			expect(transform j, is equal to (10.6066017166f) within (tolerance))
			expect(transform k, is equal to (9.0f) within (tolerance))
			expect(transform l, is equal to (0.0f) within (tolerance))
			expect(transform m, is equal to (-0.707106779f) within (tolerance))
			expect(transform n, is equal to (14.849242403f) within (tolerance))
			expect(transform o, is equal to (12.0f) within (tolerance))
			expect(transform p, is equal to (1.0f) within (tolerance))
		})
		this add("reflectX", func {
			transform := this transform0 reflectX()
			expect(transform a, is equal to (1.0f) within (tolerance))
			expect(transform b, is equal to (2.0f) within (tolerance))
			expect(transform c, is equal to (3.0f) within (tolerance))
			expect(transform d, is equal to (0.0f) within (tolerance))
			expect(transform e, is equal to (-4.0f) within (tolerance))
			expect(transform f, is equal to (5.0f) within (tolerance))
			expect(transform g, is equal to (6.0f) within (tolerance))
			expect(transform h, is equal to (0.0f) within (tolerance))
			expect(transform i, is equal to (-7.0f) within (tolerance))
			expect(transform j, is equal to (8.0f) within (tolerance))
			expect(transform k, is equal to (9.0f) within (tolerance))
			expect(transform l, is equal to (0.0f) within (tolerance))
			expect(transform m, is equal to (-10.0f) within (tolerance))
			expect(transform n, is equal to (11.0f) within (tolerance))
			expect(transform o, is equal to (12.0f) within (tolerance))
			expect(transform p, is equal to (1.0f) within (tolerance))
		})
		this add("reflectY", func {
			transform := this transform0 reflectY()
			expect(transform a, is equal to (-1.0f) within (tolerance))
			expect(transform b, is equal to (-2.0f) within (tolerance))
			expect(transform c, is equal to (3.0f) within (tolerance))
			expect(transform d, is equal to (0.0f) within (tolerance))
			expect(transform e, is equal to (4.0f) within (tolerance))
			expect(transform f, is equal to (-5.0f) within (tolerance))
			expect(transform g, is equal to (6.0f) within (tolerance))
			expect(transform h, is equal to (0.0f) within (tolerance))
			expect(transform i, is equal to (7.0f) within (tolerance))
			expect(transform j, is equal to (-8.0f) within (tolerance))
			expect(transform k, is equal to (9.0f) within (tolerance))
			expect(transform l, is equal to (0.0f) within (tolerance))
			expect(transform m, is equal to (10.0f) within (tolerance))
			expect(transform n, is equal to (-11.0f) within (tolerance))
			expect(transform o, is equal to (12.0f) within (tolerance))
			expect(transform p, is equal to (1.0f) within (tolerance))
		})
		this add("reflectZ", func {
			transform := this transform0 reflectZ()
			expect(transform a, is equal to (-1.0f) within (tolerance))
			expect(transform b, is equal to (2.0f) within (tolerance))
			expect(transform c, is equal to (-3.0f) within (tolerance))
			expect(transform d, is equal to (0.0f) within (tolerance))
			expect(transform e, is equal to (4.0f) within (tolerance))
			expect(transform f, is equal to (5.0f) within (tolerance))
			expect(transform g, is equal to (-6.0f) within (tolerance))
			expect(transform h, is equal to (0.0f) within (tolerance))
			expect(transform i, is equal to (7.0f) within (tolerance))
			expect(transform j, is equal to (8.0f) within (tolerance))
			expect(transform k, is equal to (-9.0f) within (tolerance))
			expect(transform l, is equal to (0.0f) within (tolerance))
			expect(transform m, is equal to (10.0f) within (tolerance))
			expect(transform n, is equal to (11.0f) within (tolerance))
			expect(transform o, is equal to (-12.0f) within (tolerance))
			expect(transform p, is equal to (1.0f) within (tolerance))
		})
		this add("createProjection", func {
			projection := FloatTransform3D createProjection(7.5f)
			expect(projection a, is equal to (7.5f) within (tolerance))
			expect(projection b, is equal to (0.0f) within (tolerance))
			expect(projection c, is equal to (0.0f) within (tolerance))
			expect(projection d, is equal to (0.0f) within (tolerance))
			expect(projection e, is equal to (0.0f) within (tolerance))
			expect(projection f, is equal to (7.5f) within (tolerance))
			expect(projection g, is equal to (0.0f) within (tolerance))
			expect(projection h, is equal to (0.0f) within (tolerance))
			expect(projection i, is equal to (0.0f) within (tolerance))
			expect(projection j, is equal to (0.0f) within (tolerance))
			expect(projection k, is equal to (7.5f) within (tolerance))
			expect(projection l, is equal to (1.0f) within (tolerance))
			expect(projection m, is equal to (0.0f) within (tolerance))
			expect(projection n, is equal to (0.0f) within (tolerance))
			expect(projection o, is equal to (0.0f) within (tolerance))
			expect(projection p, is equal to (0.0f) within (tolerance))
		})
		this add("createReflectionX", func {
			reflection := FloatTransform3D createReflectionX()
			expect(reflection a, is equal to (-1.0f) within (tolerance))
			expect(reflection b, is equal to (0.0f) within (tolerance))
			expect(reflection c, is equal to (0.0f) within (tolerance))
			expect(reflection d, is equal to (0.0f) within (tolerance))
			expect(reflection e, is equal to (0.0f) within (tolerance))
			expect(reflection f, is equal to (1.0f) within (tolerance))
			expect(reflection g, is equal to (0.0f) within (tolerance))
			expect(reflection h, is equal to (0.0f) within (tolerance))
			expect(reflection i, is equal to (0.0f) within (tolerance))
			expect(reflection j, is equal to (0.0f) within (tolerance))
			expect(reflection k, is equal to (1.0f) within (tolerance))
			expect(reflection l, is equal to (0.0f) within (tolerance))
			expect(reflection m, is equal to (0.0f) within (tolerance))
			expect(reflection n, is equal to (0.0f) within (tolerance))
			expect(reflection o, is equal to (0.0f) within (tolerance))
			expect(reflection p, is equal to (1.0f) within (tolerance))
		})
		this add("createReflectionY", func {
			reflection := FloatTransform3D createReflectionY()
			expect(reflection a, is equal to (1.0f) within (tolerance))
			expect(reflection b, is equal to (0.0f) within (tolerance))
			expect(reflection c, is equal to (0.0f) within (tolerance))
			expect(reflection d, is equal to (0.0f) within (tolerance))
			expect(reflection e, is equal to (0.0f) within (tolerance))
			expect(reflection f, is equal to (-1.0f) within (tolerance))
			expect(reflection g, is equal to (0.0f) within (tolerance))
			expect(reflection h, is equal to (0.0f) within (tolerance))
			expect(reflection i, is equal to (0.0f) within (tolerance))
			expect(reflection j, is equal to (0.0f) within (tolerance))
			expect(reflection k, is equal to (1.0f) within (tolerance))
			expect(reflection l, is equal to (0.0f) within (tolerance))
			expect(reflection m, is equal to (0.0f) within (tolerance))
			expect(reflection n, is equal to (0.0f) within (tolerance))
			expect(reflection o, is equal to (0.0f) within (tolerance))
			expect(reflection p, is equal to (1.0f) within (tolerance))
		})
		this add("createReflectionZ", func {
			reflection := FloatTransform3D createReflectionZ()
			expect(reflection a, is equal to (1.0f) within (tolerance))
			expect(reflection b, is equal to (0.0f) within (tolerance))
			expect(reflection c, is equal to (0.0f) within (tolerance))
			expect(reflection d, is equal to (0.0f) within (tolerance))
			expect(reflection e, is equal to (0.0f) within (tolerance))
			expect(reflection f, is equal to (1.0f) within (tolerance))
			expect(reflection g, is equal to (0.0f) within (tolerance))
			expect(reflection h, is equal to (0.0f) within (tolerance))
			expect(reflection i, is equal to (0.0f) within (tolerance))
			expect(reflection j, is equal to (0.0f) within (tolerance))
			expect(reflection k, is equal to (-1.0f) within (tolerance))
			expect(reflection l, is equal to (0.0f) within (tolerance))
			expect(reflection m, is equal to (0.0f) within (tolerance))
			expect(reflection n, is equal to (0.0f) within (tolerance))
			expect(reflection o, is equal to (0.0f) within (tolerance))
			expect(reflection p, is equal to (1.0f) within (tolerance))
		})
		this add("project", func {
			newPoint := this transform0 project(this point0, 5.0f)
			expect(newPoint x, is equal to (5.66666667f) within (tolerance))
			expect(newPoint y, is equal to (1.66666667f) within (tolerance))
		})
		this add ("transformAndProject ~FloatPoint2D (focalLength > epsilon)", func {
			transformAndProject := this transform0 transformAndProject(FloatPoint2D new(34, 10), 5.0f)
			expect(transformAndProject x, is equal to (1.16438356f) within (tolerance))
			expect(transformAndProject y, is equal to (3.85844749f) within (tolerance))
		})
		this add ("transformAndProject ~FloatPoint2D (focalLength < epsilon)", func {
			transformAndProject := this transform0 transformAndProject(FloatPoint2D new(34, 10), Float epsilon - (Float epsilon / 2))
			expect(transformAndProject x, is equal to (16.00000083f) within (tolerance))
			expect(transformAndProject y, is equal to (129.00000095f) within (tolerance))
		})
		this add ("transformAndProject ~FloatBox2D (focalLength > epsilon)", func {
			resultedBox := this transform0 transformAndProject(FloatBox2D new (1.0f, 2.0f, 3.0f, 4.0f), 5.0f)
			expect(resultedBox left, is equal to (3.095238095f) within (tolerance))
			expect(resultedBox top, is equal to (4.238095238f) within (tolerance))
			expect(resultedBox width, is equal to (0.515873016f) within (tolerance))
			expect(resultedBox height, is equal to (0.136904762f) within (tolerance))
		})
		this add ("transformAndProject ~FloatBox2D (focalLength < epsilon)", func {
			resultedBox := this transform0 transformAndProject(FloatBox2D new (1.0f, 2.0f, 3.0f, 4.0f), Float epsilon - (Float epsilon / 2))
			expect(resultedBox left, is equal to (17.00000083447f) within (tolerance))
			expect(resultedBox top, is equal to (23.00000095368f) within (tolerance))
			expect(resultedBox width, is equal to (13.0f) within (tolerance))
			expect(resultedBox height, is equal to (26.00f) within (tolerance))
		})
		this add("transformAndProjectCorners (focalLength > epsilon)", func {
			resultedVectorList := this transform0 transformAndProjectCorners(FloatBox2D new (1.0f, 2.0f, 3.0f, 4.0f), 5.0f)
			expect(resultedVectorList[0] x, is equal to (3.611111111f) within (tolerance))
			expect(resultedVectorList[0] y, is equal to (4.375f) within (tolerance))
			expect(resultedVectorList[1] x, is equal to (3.541666666f) within (tolerance))
			expect(resultedVectorList[1] y, is equal to (4.322916666f) within (tolerance))
			expect(resultedVectorList[2] x, is equal to (3.095238095f) within (tolerance))
			expect(resultedVectorList[2] y, is equal to (4.238095238f) within (tolerance))
			expect(resultedVectorList[3] x, is equal to (3.024691358f) within (tolerance))
			expect(resultedVectorList[3] y, is equal to (4.259259260f) within (tolerance))
			resultedVectorList free()
		})
		this add("transformAndProjectCorners (focalLength < epsilon)", func {
			resultedVectorList := this transform0 transformAndProjectCorners(FloatBox2D new (1.0f, 2.0f, 3.0f, 4.0f), Float epsilon - (Float epsilon / 2))
			expect(resultedVectorList[0] x, is equal to (17.00000083447f) within (tolerance))
			expect(resultedVectorList[0] y, is equal to (23.00000095368f) within (tolerance))
			expect(resultedVectorList[1] x, is equal to (33.00000083447f) within (tolerance))
			expect(resultedVectorList[1] y, is equal to (43.00000095367f) within (tolerance))
			expect(resultedVectorList[2] x, is equal to (30.00000083446f) within (tolerance))
			expect(resultedVectorList[2] y, is equal to (49.00000095367f) within (tolerance))
			expect(resultedVectorList[3] x, is equal to (14.00000083447f) within (tolerance))
			expect(resultedVectorList[3] y, is equal to (29.00000095367f) within (tolerance))
			resultedVectorList free()
		})
	}
}
FloatTransform3DTest new() run() . free()
