/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

use geometry
use base
import RasterPacked
import RasterImage
import RasterYuvSemiplanar
import RasterMonochrome
import RasterUv
import Image
import Color
import Pen
import RasterRgb
import StbImage
import io/File
import io/FileReader
import io/Reader
import io/FileWriter
import Canvas, RasterCanvas
use concurrent //optimize
use system //optimize

RasterYuv420SemiplanarCanvas: class extends RasterCanvas {
	target ::= this _target as RasterYuv420Semiplanar
	init: func (image: RasterYuv420Semiplanar) { super(image) }
	_drawPoint: override func (x, y: Int, pen: Pen) {
		position := this _map(IntPoint2D new(x, y))
		if (this target isValidIn(position x, position y))
			this target[position x, position y] = this target[position x, position y] blend(pen alphaAsFloat, pen color toYuv())
	}
}

RasterYuv420Semiplanar: class extends RasterYuvSemiplanar {
	stride ::= this _y stride
	init: func ~fromRasterImages (yImage: RasterMonochrome, uvImage: RasterUv) { super(yImage, uvImage) }
	init: func ~allocateOffset (size: IntVector2D, stride: UInt, uvOffset: UInt) {
		(yImage, uvImage) := This _allocate(size, stride, uvOffset)
		this init(yImage, uvImage)
	}
	init: func ~allocateStride (size: IntVector2D, stride: UInt) { this init(size, stride, stride * size y) }
	init: func ~allocate (size: IntVector2D) { this init(size, size x) }
	init: func ~fromThis (original: This) {
		(yImage, uvImage) := This _allocate(original size, original stride, original stride * original size y)
		super(original, yImage, uvImage)
	}
	init: func ~fromByteBuffer (buffer: ByteBuffer, size: IntVector2D, stride: UInt, uvOffset: UInt) {
		(yImage, uvImage) := This _createSubimages(buffer, size, stride, uvOffset)
		this init(yImage, uvImage)
	}
	create: override func (size: IntVector2D) -> Image { This new(size) }
	copy: override func -> This {
		result := This new(this)
		this y buffer copyTo(result y buffer)
		this uv buffer copyTo(result uv buffer)
		result
	}
	resizeTo: override func (size: IntVector2D) -> This {
		result: This
		if (this size == size)
			result = this copy()
		else version (experimentOptimized) {
			result = This new(size, size x + (size x isOdd ? 1 : 0))
			this resizeIntoOptimized(result)
		}
		else {
			result = This new(size, size x + (size x isOdd ? 1 : 0))
			this resizeInto(result)
		}
		result
	}
	resizeIntoOptimized: func (target: This) {
		thisYBuffer := this y buffer pointer //buffer: ByteBuffer
		targetYBuffer := target y buffer pointer //buffer: ByteBuffer
		sseLength := 4
		thisStride, targetStride, srcColumn, targetIndex, thisIndex: Int*
		posix_memalign(thisStride& as Void**, 16, sseLength * Int size)
		posix_memalign(targetStride& as Void**, 16, sseLength * Int size)
		posix_memalign(srcColumn& as Void**, 16, sseLength * Int size)
		posix_memalign(targetIndex& as Void**, 16, sseLength * Int size)
		posix_memalign(thisIndex& as Void**, 16, sseLength * Int size)
		thisStrideSse := thisStride as M128i*
		targetStrideSse := targetStride as M128i*
		srcColumnSse := srcColumn as M128i*
		targetIndexSse := targetIndex as M128i*
		thisIndexSse := thisIndex as M128i*
		row := 0
		while ( row + (sseLength - 1) < target size y) {
			thisStrideSse[0] = _mm_mullo_epi16(_mm_set1_epi32(this size y), _mm_set_epi32(row, row + 1, row + 2, row + 3))
			for (i in 0 .. sseLength)
				thisStride[i] /= target size y
			thisStrideSse[0] = _mm_mullo_epi16(_mm_set_epi32(thisStride[0], thisStride[1], thisStride[2], thisStride[3]), _mm_set1_epi32(this y stride))
			targetStrideSse[0] = _mm_mullo_epi16(_mm_set_epi32(row, row + 1, row + 2, row + 3), _mm_set1_epi32(target y stride))
			for (stride in 0 .. sseLength) {
				column := 0
				while (column + (sseLength - 1) < target size x) {
					srcColumnSse[0] = _mm_mullo_epi16(_mm_set1_epi32(this size x), _mm_set_epi32(column, column + 1, column + 2, column + 3))
					for (i in 0 .. sseLength)
						srcColumn[i] /= target size x
					targetIndexSse[0] = _mm_add_epi32(_mm_set_epi32(column + 3, column + 2, column + 1, column), _mm_set1_epi32(targetStride[(sseLength - 1) - stride]))
					thisIndexSse[0] = _mm_add_epi32(_mm_set_epi32(srcColumn[0], srcColumn[1], srcColumn[2], srcColumn[3]), _mm_set1_epi32(thisStride[stride]))
					targetYBuffer[targetIndex[0]] = thisYBuffer[thisIndex[0]]
					targetYBuffer[targetIndex[1]] = thisYBuffer[thisIndex[1]]
					targetYBuffer[targetIndex[2]] = thisYBuffer[thisIndex[2]]
					targetYBuffer[targetIndex[3]] = thisYBuffer[thisIndex[3]]
					column += sseLength
				}
				for (remaningColumn in column .. target size x) {
					srcColumn := (this size x * remaningColumn) / target size x
					targetYBuffer[remaningColumn + targetStride[(sseLength - 1) - stride]] = thisYBuffer[srcColumn + thisStride[stride]]
				}
			}
			row += sseLength
		}
		for (remainingRow in row .. target size y) {
			srcRow := (this size y * remainingRow) / target size y
			thisStride := srcRow * this y stride
			targetStride := remainingRow * target y stride
			for (column in 0 .. target size x) {
				srcColumn := (this size x * column) / target size x
				targetYBuffer[column + targetStride] = thisYBuffer[srcColumn + thisStride]
			}
		}
		targetSizeHalf := target size / 2
		thisSizeHalf := this size / 2
		thisUvBuffer := this uv buffer pointer as ColorUv*
		targetUvBuffer := target uv buffer pointer as ColorUv*
		row = 0
		if (target size y isOdd)
			targetSizeHalf = IntVector2D new(targetSizeHalf x, targetSizeHalf y + 1)
		while ( row + (sseLength - 1) < targetSizeHalf y) {
			thisStrideSse[0] = _mm_mullo_epi16(_mm_set1_epi32(thisSizeHalf y), _mm_set_epi32(row, row + 1, row + 2, row + 3))
			for (i in 0 .. sseLength)
				thisStride[i] /= targetSizeHalf y
			thisStrideSse[0] = _mm_mullo_epi16(_mm_set_epi32(thisStride[0], thisStride[1], thisStride[2], thisStride[3]), _mm_set1_epi32(this uv stride / 2))
			targetStrideSse[0] = _mm_mullo_epi16(_mm_set_epi32(row, row + 1, row + 2, row + 3), _mm_set1_epi32(target uv stride / 2))
			for (stride in 0 .. sseLength) {
				column := 0
				while (column + (sseLength - 1) < targetSizeHalf x) {
					srcColumnSse[0] = _mm_mullo_epi16(_mm_set1_epi32(thisSizeHalf x), _mm_set_epi32(column, column + 1, column + 2, column + 3))
					for (i in 0 .. sseLength)
						srcColumn[i] /=  targetSizeHalf x
					targetIndexSse[0] = _mm_add_epi32(_mm_set_epi32(column + 3, column + 2, column + 1, column), _mm_set1_epi32(targetStride[(sseLength - 1) - stride]))
					thisIndexSse[0] = _mm_add_epi32(_mm_set_epi32(srcColumn[0], srcColumn[1], srcColumn[2], srcColumn[3]), _mm_set1_epi32(thisStride[stride]))
					targetUvBuffer[targetIndex[0]] = thisUvBuffer[thisIndex[0]]
					targetUvBuffer[targetIndex[1]] = thisUvBuffer[thisIndex[1]]
					targetUvBuffer[targetIndex[2]] = thisUvBuffer[thisIndex[2]]
					targetUvBuffer[targetIndex[3]] = thisUvBuffer[thisIndex[3]]
					column += sseLength
				}
				for (remainingColumn in column .. targetSizeHalf x) {
					srcColumn := (thisSizeHalf x * remainingColumn) / targetSizeHalf x
					targetUvBuffer[remainingColumn + targetStride[(sseLength - 1) - stride]] = thisUvBuffer[srcColumn + thisStride[stride]]
				}
			}
			row += sseLength
		}
		for (remainingRow in row .. targetSizeHalf y) {
			srcRow := (thisSizeHalf y * remainingRow) / targetSizeHalf y
			thisStride := srcRow * this uv stride / 2
			targetStride := remainingRow * target uv stride / 2
			for (column in 0 .. targetSizeHalf x) {
				srcColumn := (thisSizeHalf x * column) / targetSizeHalf x
				targetUvBuffer[column + targetStride] = thisUvBuffer[srcColumn + thisStride]
			}
		}
		memfree(thisStride)
		memfree(targetStride)
		memfree(srcColumn)
		memfree(targetIndex)
		memfree(thisIndex)
	}
	resizeInto: func (target: This) {
		thisYBuffer := this y buffer pointer
		targetYBuffer := target y buffer pointer
		for (row in 0 .. target size y) {
			srcRow := (this size y * row) / target size y
			thisStride := srcRow * this y stride
			targetStride := row * target y stride
			for (column in 0 .. target size x) {
				srcColumn := (this size x * column) / target size x
				targetYBuffer[column + targetStride] = thisYBuffer[srcColumn + thisStride]
			}
		}
		targetSizeHalf := target size / 2
		thisSizeHalf := this size / 2
		thisUvBuffer := this uv buffer pointer as ColorUv*
		targetUvBuffer := target uv buffer pointer as ColorUv*
		if (target size y isOdd)
			targetSizeHalf = IntVector2D new(targetSizeHalf x, targetSizeHalf y + 1)
		for (row in 0 .. targetSizeHalf y) {
			srcRow := (thisSizeHalf y * row) / targetSizeHalf y
			thisStride := srcRow * this uv stride / 2
			targetStride := row * target uv stride / 2
			for (column in 0 .. targetSizeHalf x) {
				srcColumn := (thisSizeHalf x * column) / targetSizeHalf x
				targetUvBuffer[column + targetStride] = thisUvBuffer[srcColumn + thisStride]
			}
		}
	}
	crop: func (region: FloatBox2D) -> This {
		size := region size toIntVector2D()
		result := This new(size, size x + (size x isOdd ? 1 : 0)) as This
		this cropInto(region, result)
		result
	}
	cropInto: func (region: FloatBox2D, target: This) {
		thisYBuffer := this y buffer pointer
		targetYBuffer := target y buffer pointer
		for (row in region top .. region size y + region top) {
			thisStride := row * this y stride
			targetStride := ((row - region top) as Int) * target y stride
			for (column in region left .. region size x + region left)
				targetYBuffer[(column - region left) as Int + targetStride] = thisYBuffer[column + thisStride]
		}
		regionSizeHalf := region size / 2
		regionTopHalf := region top / 2
		regionLeftHalf := region left / 2
		thisUvBuffer := this uv buffer pointer as ColorUv*
		targetUvBuffer := target uv buffer pointer as ColorUv*
		for (row in regionTopHalf .. regionSizeHalf y + regionTopHalf) {
			thisStride := row * this uv stride / 2
			targetStride := ((row - regionTopHalf) as Int) * target uv stride / 2
			for (column in regionLeftHalf .. regionSizeHalf x + regionLeftHalf)
				targetUvBuffer[(column - regionLeftHalf) as Int + targetStride] = thisUvBuffer[column + thisStride]
		}
	}
	apply: override func ~rgb (action: Func(ColorRgb)) {
		convert := ColorConvert fromYuv(action)
		this apply(convert)
		(convert as Closure) free()
	}
	apply: override func ~yuv (action: Func (ColorYuv)) {
		yRow := this y buffer pointer
		ySource := yRow
		uvRow := this uv buffer pointer
		vSource := uvRow
		uSource := uvRow + 1
		width := this size x
		height := this size y

		for (y in 0 .. height) {
			for (x in 0 .. width) {
				action(ColorYuv new(ySource@, uSource@, vSource@))
				ySource += 1
				if (x % 2 == 1) {
					uSource += 2
					vSource += 2
				}
			}
			yRow += this y stride
			if (y % 2 == 1) {
				uvRow += this uv stride
			}
			ySource = yRow
			vSource = uvRow
			uSource = uvRow + 1
		}
	}
	apply: override func ~monochrome (action: Func(ColorMonochrome)) {
		convert := ColorConvert fromYuv(action)
		this apply(convert)
		(convert as Closure) free()
	}
	save: override func (filename: String) -> Int {
		rgb := RasterRgb convertFrom(this)
		result := rgb save(filename)
		rgb free()
		result
	}
	saveRaw: func (filename: String) {
		fileWriter := FileWriter new(filename)
		fileWriter write(this y buffer pointer as Char*, this y buffer size)
		fileWriter write(this uv buffer pointer as Char*, this uv buffer size)
		fileWriter close()
	}
	_createCanvas: override func -> Canvas { RasterYuv420SemiplanarCanvas new(this) }

	operator [] (x, y: Int) -> ColorYuv {
		ColorYuv new(this y[x, y] y, this uv [x / 2, y / 2] u, this uv [x / 2, y / 2] v)
	}
	operator []= (x, y: Int, value: ColorYuv) {
		this y[x, y] = ColorMonochrome new(value y)
		this uv[x / 2, y / 2] = ColorUv new(value u, value v)
	}
	_allocate: static func (size: IntVector2D, stride: UInt, uvOffset: UInt) -> (RasterMonochrome, RasterUv) {
		length := uvOffset + stride * (size y + 1) / 2
		buffer := ByteBuffer new(length)
		This _createSubimages(buffer, size, stride, uvOffset)
	}
	_createSubimages: static func (buffer: ByteBuffer, size: IntVector2D, stride: UInt, uvOffset: UInt) -> (RasterMonochrome, RasterUv) {
		yLength := stride * size y
		uvLength := stride * size y / 2
		(RasterMonochrome new(buffer slice(0, yLength), size, stride), RasterUv new(buffer slice(uvOffset, uvLength), This _uvSize(size), stride))
	}
	_uvSize: static func (size: IntVector2D) -> IntVector2D {
		IntVector2D new(size x / 2 + (size x isOdd ? 1 : 0), size y / 2 + (size y isOdd ? 1 : 0))
	}
	convertFrom: static func (original: RasterImage) -> This {
		result: This
		if (original instanceOf(This))
			result = (original as This) copy()
		else {
			result = This new(original size)
			y := 0
			x := 0
			width := result size x
			yRow := result y buffer pointer
			yDestination := yRow
			uvRow := result uv buffer pointer
			uvDestination := uvRow
			totalOffset := 0
			f := func (color: ColorYuv) {
				yDestination@ = color y
				yDestination += 1
				if (x % 2 == 0 && y % 2 == 0 && totalOffset < result uv buffer size) {
					uvDestination@ = color v
					uvDestination += 1
					uvDestination@ = color u
					uvDestination += 1
					totalOffset += 2
				}
				x += 1
				if (x >= width) {
					x = 0
					y += 1
					yRow += result y stride
					yDestination = yRow
					if (y % 2 == 0) {
						uvRow += result uv stride
						uvDestination = uvRow
					}
				}
			}
			original apply(f)
			(f as Closure) free()
		}
		result
	}
	open: static func (filename: String, coordinateSystem := CoordinateSystem Default) -> This {
		rgb := RasterRgb open(filename, coordinateSystem)
		result := This convertFrom(rgb)
		rgb free()
		result
	}
	openRaw: static func (filename: String, size: IntVector2D) -> This {
		fileReader := FileReader new(FStream open(filename, "rb"))
		result := This new(size)
		fileReader read((result y buffer pointer as Char*), 0, result y buffer size)
		fileReader read((result uv buffer pointer as Char*), 0, result uv buffer size)
		fileReader close()
		fileReader free()
		result
	}
}
