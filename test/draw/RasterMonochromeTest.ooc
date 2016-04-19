/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

use base
use draw
use geometry
use unit

RasterMonochromeTest: class extends Fixture {
	sourceSpace := "test/draw/input/Space.png"
	sourceFlower := "test/draw/input/Flower.png"
	init: func {
		super("RasterMonochrome")
		this add("equals 1", func {
			image1 := RasterMonochrome open(this sourceFlower)
			image2 := RasterMonochrome open(this sourceSpace)
			expect(image1 equals(image1), is true)
			expect(image1 equals(image2), is false)
			image1 referenceCount decrease(); image2 referenceCount decrease()
		})
		this add("equals 2", func {
			output := "test/draw/output/RasterMonochrome_test.png"
			image1 := RasterMonochrome open(this sourceFlower)
			image1 save(output)
			image2 := RasterMonochrome open(output)
			expect(image1 equals(image2), is true)
			image1 referenceCount decrease(); image2 referenceCount decrease()
		})
		this add("distance, same image", func {
			image1 := RasterMonochrome open(this sourceSpace)
			image2 := RasterMonochrome open(this sourceSpace)
			expect(image1 distance(image1), is equal to(0.0f))
			expect(image1 distance(image2), is equal to(0.0f))
			image1 referenceCount decrease(); image2 referenceCount decrease()
		})
		this add("distance, convertFrom self", func {
			image1 := RasterMonochrome open(this sourceFlower)
			image2 := RasterMonochrome convertFrom(image1)
			expect(image1 distance(image2), is equal to(0.0f))
			expect(image1 equals(image2))
			image1 referenceCount decrease(); image2 referenceCount decrease()
		})
		this add("getRow and getColumn", func {
			size := IntVector2D new(500, 256)
			image := RasterMonochrome new(size)
			for (row in 0 .. size y)
				for (column in 0 .. size x)
					image[column, row] = ColorMonochrome new(row)
			for (column in 0 .. size x) {
				columnData := image getColumn(column)
				expect(columnData count, is equal to(size y))
				for (i in 0 .. columnData count)
					expect(columnData[i] as Int, is equal to(i))
				columnData free()
			}
			for (row in 0 .. size y) {
				rowData := image getRow(row)
				expect(rowData count, is equal to(size x))
				for (i in 0 .. rowData count)
					expect(rowData[i] as Int, is equal to(row))
				rowData free()
			}
			image referenceCount decrease()
		})
		this add("resizeUv", func {
			outputY := "test/draw/output/TestImageY.png"
			outputUV := "test/draw/output/TestImageUV.png"
			output := "test/draw/output/TestImage.png"
			imageLarge := RasterYuv420Semiplanar open(this sourceFlower)
			imageSmall := RasterYuv420Semiplanar new(imageLarge size / 5)
			imageLarge scaleInto(imageSmall, 2)
			imageSmall scaleInto(imageLarge, 2)
			imageLarge y save(outputY)
			imageLarge uv save(outputUV)
			imageLarge save(output)
			imageSmall referenceCount decrease()
			imageLarge referenceCount decrease()
			output free()
		})
		this add("copy", func {
			image := RasterMonochrome open(this sourceFlower)
			image2 := image copy()
			expect(image size == image2 size)
			expect(image stride, is equal to(image2 stride))
			expect(image transform == image2 transform)
			expect(image coordinateSystem == image2 coordinateSystem)
			expect(image crop == image2 crop)
			expect(image wrap, is equal to(image2 wrap))
			expect(image referenceCount != image2 referenceCount)
			image referenceCount decrease()
			image2 referenceCount decrease()
		})
		this add("color monochrome from unsigned types", func {
			image := RasterMonochrome new(IntVector2D new(10, 10))
			value: UInt = 128
			value32: UInt = 128
			value64: ULong = 128
			image[0, 0] = ColorMonochrome new(value32)
			image[0, 1] = ColorMonochrome new(value64)
			image[0, 2] = ColorMonochrome new(value)
			expect(image[0, 0] y as Int, is equal to(value32 as Int))
			expect(image[0, 1] y as Int, is equal to(value64 as Int))
			expect(image[0, 2] y as Int, is equal to(value as Int))
			image referenceCount decrease()
		})
		this add("distance, convertFrom RasterRgba", func {
			source := this sourceFlower
			output := "test/draw/output/RasterRgbToMonochrome.png"
			image1 := RasterMonochrome open(source)
			image2 := RasterMonochrome convertFrom(RasterRgba open(source))
			expect(image1 distance(image2), is equal to(0.0f))
		})
	}
}

RasterMonochromeTest new() run() . free()
