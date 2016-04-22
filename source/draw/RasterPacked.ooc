/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

use geometry
use concurrent
use base
import io/File
import ByteBuffer
import StbImage
import RasterImage
import RasterRgb
import RasterRgba
import RasterMonochrome
import Image
import Canvas, RasterCanvas

import RasterUv

RasterPackedCanvas: abstract class extends RasterCanvas {
	target ::= this _target as RasterPacked
	init: func (image: RasterPacked) { super(image) }
	_resizePacked: func <T> (sourceBuffer: T*, source: RasterPacked, sourceBox, resultBox: IntBox2D, interpolate: Bool) {
		if (this target size == source size && this target stride == source stride && sourceBox == resultBox && sourceBox size == source size && sourceBox leftTop x == 0 && sourceBox leftTop y == 0 && source coordinateSystem == this target coordinateSystem)
			memcpy(this target buffer pointer, sourceBuffer, this target stride * this target height)
		else if (interpolate)
			This _resizeBilinear(source, this target, sourceBox, resultBox)
		else
			This _resizeNearestNeighbour(sourceBuffer, this target buffer pointer as T*, source, this target, sourceBox, resultBox)
	}
	_transformCoordinates: static func (column, row, width, height: Int, coordinateSystem: CoordinateSystem) -> (Int, Int) {
		if ((coordinateSystem & CoordinateSystem XLeftward) != 0)
			column = width - column - 1
		if ((coordinateSystem & CoordinateSystem YUpward) != 0)
			row = height - row - 1
		(column, row)
	}
	_resizeNearestNeighbour: static func <T> (sourceBuffer, resultBuffer: T*, source, target: RasterPacked, sourceBox, resultBox: IntBox2D) {
		bytesPerPixel := target bytesPerPixel
		(resultWidth, resultHeight) := (resultBox size x, resultBox size y)
		(sourceWidth, sourceHeight) := (sourceBox size x, sourceBox size y)
		(sourceStride, resultStride) := (source stride / bytesPerPixel, target stride / bytesPerPixel)
		sourceStartColumn := sourceBox leftTop x
		sourceStartRow := sourceBox leftTop y
		resultStartColumn := resultBox leftTop x
		resultStartRow := resultBox leftTop y
		for (row in 0 .. resultHeight) {
			sourceRow := (sourceHeight * row) / resultHeight + sourceStartRow
			for (column in 0 .. resultWidth) {
				sourceColumn := (sourceWidth * column) / resultWidth + sourceStartColumn
				(resultColumnTransformed, resultRowTransformed) := This _transformCoordinates(column + resultStartColumn, row + resultStartRow, target width, target height, target coordinateSystem)
				(sourceColumnTransformed, sourceRowTransformed) := This _transformCoordinates(sourceColumn, sourceRow, source width, source height, source coordinateSystem)
				resultBuffer[resultColumnTransformed + resultStride * resultRowTransformed] = sourceBuffer[sourceColumnTransformed + sourceStride * sourceRowTransformed]
			}
		}
	}
	_resizeBilinear: static func (source, target: RasterPacked, sourceBox, resultBox: IntBox2D) {
		bytesPerPixel := target bytesPerPixel
		(resultWidth, resultHeight) := (resultBox size x, resultBox size y)
		(sourceWidth, sourceHeight) := (sourceBox size x, sourceBox size y)
		(sourceStartColumn, sourceStartRow) := (sourceBox leftTop x, sourceBox leftTop y)
		(resultStartColumn, resultStartRow) := (resultBox leftTop x, resultBox leftTop y)
		(sourceStride, resultStride) := (source stride, target stride)
		(sourceBuffer, resultBuffer) := (source buffer pointer as Byte*, target buffer pointer as Byte*)
		//printed := static false
		/*if (printed == false && bytesPerPixel == 2) {
			"source: w: #{sourceWidth}, s: #{sourceStride}" println() . free()
			"result: w: #{resultWidth}, s: #{resultStride}" println() . free()
			printed = true
		}*/
		for (row in 0 .. resultHeight) {
			sourceRow := ((sourceHeight as Float) * row) / resultHeight + sourceStartRow
			sourceRowUp := sourceRow floor() as Int
			weightDown := sourceRow - sourceRowUp as Float
			sourceRowDown := (sourceRow - weightDown) as Int + 1
			if (sourceRowDown >= sourceHeight)
				weightDown = 0.0f
			for (column in 0 .. resultWidth) {
				sourceColumn := ((sourceWidth as Float) * column) / resultWidth + sourceStartColumn
				sourceColumnLeft := sourceColumn floor() as Int
				weightRight := sourceColumn - sourceColumnLeft as Float
				if (sourceColumnLeft + 1 >= sourceWidth)
					weightRight = 0.0f
				(resultColumnTransformed, resultRowTransformed) := This _transformCoordinates(column + resultStartColumn, row + resultStartRow, target width, target height, target coordinateSystem)
				(sourceColumnLeftTransformed, sourceRowUpTransformed) := This _transformCoordinates(sourceColumnLeft, sourceRowUp, source width, source height, source coordinateSystem)
				(topLeft, topRight) := ((1.0f - weightDown) * (1.0f - weightRight), (1.0f - weightDown) * weightRight)
				(bottomLeft, bottomRight) := (weightDown * (1.0f - weightRight), weightDown * weightRight)
				This _blendSquare(sourceBuffer, resultBuffer, sourceStride, resultStride, sourceRowUpTransformed, sourceColumnLeftTransformed, resultRowTransformed, resultColumnTransformed, topLeft, topRight, bottomLeft, bottomRight, bytesPerPixel)
			}
		}
	}
	_resizeBilinear: static func ~range (source, target: RasterPacked, sourceBox, resultBox: IntBox2D, startRow, endRow, startColumn, endColumn: Int) {
		targetCoordinateSystemXLeftward := target coordinateSystem & CoordinateSystem XLeftward
		targetCoordinateSystemYUpward := target coordinateSystem & CoordinateSystem YUpward
		sourceCoordinateSystemXLeftward := source coordinateSystem & CoordinateSystem XLeftward
		sourceCoordinateSystemYUpward := source coordinateSystem & CoordinateSystem YUpward
		bytesPerPixel := target bytesPerPixel
		(resultWidth, resultHeight) := (resultBox size x, resultBox size y)
		(sourceWidth, sourceHeight) := (sourceBox size x, sourceBox size y)
		(sourceStartColumn, sourceStartRow) := (sourceBox leftTop x, sourceBox leftTop y)
		(resultStartColumn, resultStartRow) := (resultBox leftTop x, resultBox leftTop y)
		(sourceStride, resultStride) := (source stride, target stride)
		(sourceBuffer, resultBuffer) := (source buffer pointer as Byte*, target buffer pointer as Byte*)
		for (row in startRow .. endRow) {
			sourceRow := ((sourceHeight as Float) * row) / resultHeight + sourceStartRow
			sourceRowUp := sourceRow as Int
			weightDown := 0.0f
			if (sourceRowUp + 1 < sourceHeight)
				weightDown = sourceRow - sourceRowUp as Float
			for (column in startColumn .. endColumn) {
				sourceColumn := ((sourceWidth as Float) * column) / resultWidth + sourceStartColumn
				sourceColumnLeft := sourceColumn as Int
				weightRight := 0.0f
				if (sourceColumnLeft + 1 < sourceWidth)
					weightRight = sourceColumn - sourceColumnLeft as Float
				resultColumnTransformed := (targetCoordinateSystemXLeftward != 0) ? target width - (column + resultStartColumn) - 1 : column + resultStartColumn
				resultRowTransformed := (targetCoordinateSystemYUpward != 0) ? target height - (row + resultStartRow) - 1 : row + resultStartRow
				sourceColumnLeftTransformed := (sourceCoordinateSystemXLeftward != 0) ? source width - sourceColumnLeft - 1 : sourceColumnLeft
				sourceRowUpTransformed := (sourceCoordinateSystemYUpward != 0) ? source height - sourceRowUp - 1 : sourceRowUp
				(topLeft, topRight) := ((1.0f - weightDown) * (1.0f - weightRight), (1.0f - weightDown) * weightRight)
				(bottomLeft, bottomRight) := (weightDown * (1.0f - weightRight), weightDown * weightRight)
				This _blendSquare(sourceBuffer, resultBuffer, sourceStride, resultStride, sourceRowUpTransformed, sourceColumnLeftTransformed, resultRowTransformed, resultColumnTransformed, topLeft, topRight, bottomLeft, bottomRight, bytesPerPixel)
			}
		}
	}
	_resizeTest: static func (source, target: RasterPacked, sourceBox, resultBox: IntBox2D, startRow, endRow, startColumn, endColumn: Int) {
		(sourceStride, resultStride) := (source stride, target stride)
		(sourceBuffer, resultBuffer) := (source buffer pointer as Byte*, target buffer pointer as Byte*)
		bytesPerPixel := target bytesPerPixel
		(w, h) := (sourceBox size x, sourceBox size y)
		(w2, h2) := (resultBox size x, resultBox size y)
		a, b, c, d, x, y, index, resultValue: Int
		x_diff, y_diff: Float
		(x_ratio, y_ratio) := (((w) as Float)/w2, ((h) as Float)/h2)
		offset := 0
		for (i in startRow .. endRow) {
			for (j in 0 .. w2) {
				(x, y) = ((x_ratio * j), (y_ratio * i))
				(x_diff, y_diff) = ((x_ratio * j) - x, (y_ratio * i) - y)
				for (uvOffset in 0 .. bytesPerPixel) {
					index = (y*w+x) * bytesPerPixel
					a = sourceBuffer[index + uvOffset] & 0xff
					b = sourceBuffer[index + bytesPerPixel + uvOffset] & 0xff
					c = sourceBuffer[index + sourceStride + uvOffset] & 0xff
					d = sourceBuffer[index + sourceStride + bytesPerPixel + uvOffset] & 0xff
					resultValue = (a*(1-x_diff)*(1-y_diff) + b*(x_diff)*(1-y_diff) + c*(y_diff)*(1-x_diff) + d*(x_diff*y_diff)) //as Int
					resultBuffer[offset * bytesPerPixel + uvOffset] = resultValue
				}
				offset += 1
			}
		}
	}
	_blendSquare: static func (sourceBuffer, resultBuffer: Byte*, sourceStride, resultStride, sourceRow, sourceColumn, row, column: Int, weightTopLeft, weightTopRight, weightBottomLeft, weightBottomRight: Float, bytesPerPixel: Int) {
		finalValue: Byte = 0
		for (i in 0 .. bytesPerPixel) {
			finalValue = weightTopLeft > 0.0f ? weightTopLeft * sourceBuffer[sourceColumn * bytesPerPixel + sourceRow * sourceStride + i] : 0
			finalValue += weightTopRight > 0.0f ? weightTopRight * sourceBuffer[(sourceColumn + 1) * bytesPerPixel + sourceRow * sourceStride + i] : 0
			finalValue += weightBottomLeft > 0.0f ? weightBottomLeft * sourceBuffer[sourceColumn * bytesPerPixel + (sourceRow + 1) * sourceStride + i] : 0
			finalValue += weightBottomRight > 0.0f ? weightBottomRight * sourceBuffer[(sourceColumn + 1) * bytesPerPixel + (sourceRow + 1) * sourceStride + i] : 0
			resultBuffer[column * bytesPerPixel + row * resultStride + i] = finalValue
		}
	}
	_resizeBilinearNeon: static func (source, target: RasterPacked, sourceBox, resultBox: IntBox2D, row, maxRow: Int) {
		targetCoordinateSystemXLeftward := target coordinateSystem & CoordinateSystem XLeftward
		targetCoordinateSystemYUpward := target coordinateSystem & CoordinateSystem YUpward
		sourceCoordinateSystemXLeftward := source coordinateSystem & CoordinateSystem XLeftward
		sourceCoordinateSystemYUpward := source coordinateSystem & CoordinateSystem YUpward
		neonOne := vdupq_n_f32(1.0f)
		neonZero := vdupq_n_f32(0.0f)
		neonLength := 4
		weightDown := malloc(Float size * neonLength) as Float*
		sourceRowUp := malloc(Int size * neonLength) as Int*
		indexes := malloc(Int size * neonLength) as Int*
		neonBytesPerPixel := vdupq_n_s32(target bytesPerPixel)
		resultWidth := resultBox size x
		(neonSourceWidth, neonSourceHeight) := (vdupq_n_f32(sourceBox size x as Float), vdupq_n_f32(sourceBox size y as Float))
		(neonSourceStartColumn, neonSourceStartRow) := (vdupq_n_f32(sourceBox leftTop x as Float), vdupq_n_f32(sourceBox leftTop y as Float))
		(neonResultStartColumn, neonResultStartRow) := (vdupq_n_s32(resultBox leftTop x), vdupq_n_s32(resultBox leftTop y))
		(sourceBuffer, resultBuffer) := (source buffer pointer as Byte*, target buffer pointer as Byte*)
		neonRow := vld1q_f32([row, row + 1, row + 2, row + 3] as Float*)
		column := 0
		while (row + neonLength <= maxRow) {
			neonSourceRow := vmulq_f32(neonSourceHeight, neonRow)
			neonSourceRow = div_f32(neonSourceRow, resultBox size y as Float)
			neonSourceRow = vaddq_f32(neonSourceRow, neonSourceStartRow)
			neonSourceRowUp := vcvtq_s32_f32(neonSourceRow)
			neonLogicalSourceRowUp	:= vcltq_f32(vaddq_f32(neonOne, neonSourceRow), neonSourceHeight)
			neonWeightDown := vbslq_f32(neonLogicalSourceRowUp, vsubq_f32(neonSourceRow, vcvtq_f32_s32(neonSourceRowUp)), vdupq_n_f32(0.0f))
			for (lane in 0 .. neonLength) {
				vst1q_s32(sourceRowUp, neonSourceRowUp)
				vst1q_f32(weightDown, neonWeightDown)
				column = 0
				neonColumn := vld1q_f32([0.0f, 1.0f, 2.0f, 3.0f] as Float*)
				while (column + neonLength <= resultWidth) {
					neonSourceColumn := vmulq_f32(neonSourceWidth, neonColumn)
					neonSourceColumn = div_f32(neonSourceColumn, resultWidth as Float)
					neonSourceColumn = vaddq_f32(neonSourceColumn, neonSourceStartColumn)
					neonSourceColumnLeft := vcvtq_s32_f32(neonSourceColumn)
					neonLogicalSourceColumnLeft	:= vcltq_f32(vaddq_f32(neonOne, neonSourceColumn), neonSourceWidth)
					neonWeightRight := vbslq_f32(neonLogicalSourceColumnLeft, vsubq_f32(neonSourceColumn, vcvtq_f32_s32(neonSourceColumnLeft)), vdupq_n_f32(0.0f))
					neonTargetWidthMinusOne := vsubq_s32(vdupq_n_s32(target width), vdupq_n_s32(1))
					neonColumnPlusResultStartColumn := vaddq_s32(vcvtq_s32_f32(neonColumn), neonResultStartColumn)
					neonResultColumnTransformed := (targetCoordinateSystemXLeftward != 0) ? vsubq_s32(neonTargetWidthMinusOne, neonColumnPlusResultStartColumn) : neonColumnPlusResultStartColumn
					neonTargetHeightMinusOne := vsubq_s32(vdupq_n_s32(target height), vdupq_n_s32(1))
					neonRowPlusResultStartRow := vaddq_s32(vdupq_n_s32(row + lane), neonResultStartRow)
					neonResultRowTransformed := (targetCoordinateSystemYUpward != 0) ? vsubq_s32(neonTargetHeightMinusOne, neonRowPlusResultStartRow) : neonRowPlusResultStartRow
					neonSourceWidthMinusOne := vsubq_s32(vdupq_n_s32(source width), vdupq_n_s32(1))
					neonSourceColumnLeftTransformed := (sourceCoordinateSystemXLeftward != 0) ? vsubq_s32(neonSourceWidthMinusOne, neonSourceColumnLeft) : neonSourceColumnLeft
					neonSourceHeightMinusOne := vsubq_s32(vdupq_n_s32(source height), vdupq_n_s32(1))
					neonSourceRowUpTransformed := (sourceCoordinateSystemYUpward != 0) ? vsubq_s32(neonSourceHeightMinusOne, vdupq_n_s32(sourceRowUp[lane])) : vdupq_n_s32(sourceRowUp[lane])
					(neonTopLeft, neonTopRight) := (vmulq_f32(vsubq_f32(neonOne, vdupq_n_f32(weightDown[lane])), vsubq_f32(neonOne, neonWeightRight)), vmulq_f32(vsubq_f32(neonOne, vdupq_n_f32(weightDown[lane])), neonWeightRight))
					(neonBottomLeft, neonBottomRight) := (vmulq_f32(vdupq_n_f32(weightDown[lane]), vsubq_f32(neonOne, neonWeightRight)), vmulq_f32(vdupq_n_f32(weightDown[lane]), neonWeightRight))

					//blend
					neonSCLTmultBPP := vmulq_s32(neonSourceColumnLeftTransformed, neonBytesPerPixel)
					neonSCLTplusOnemultBPP := vmulq_s32(vaddq_s32(neonSourceColumnLeftTransformed, vdupq_n_s32(1)), neonBytesPerPixel)
					neonSRUTmultSS := vmulq_s32(neonSourceRowUpTransformed, vdupq_n_s32(source stride))
					neonSRUTplusOnemultSS := vmulq_s32(vaddq_s32(neonSourceRowUpTransformed, vdupq_n_s32(1)), vdupq_n_s32(source stride))
					for (i in 0 .. target bytesPerPixel) {
						neonBytes := vdupq_n_s32(i)
						vst1q_s32(indexes, vaddq_s32(vaddq_s32(neonSCLTmultBPP, neonSRUTmultSS), neonBytes))
						(indexes[0], indexes[1], indexes[2], indexes[3]) = (sourceBuffer[indexes[0]], sourceBuffer[indexes[1]], sourceBuffer[indexes[2]], sourceBuffer[indexes[3]])
						neonFinalValue := vcvtq_s32_f32(vmulq_f32(neonTopLeft, vcvtq_f32_s32(vld1q_s32(indexes))))
						vst1q_s32(indexes, vaddq_s32(vaddq_s32(neonSCLTplusOnemultBPP, neonSRUTmultSS), neonBytes))
						(indexes[0], indexes[1], indexes[2], indexes[3]) = (sourceBuffer[indexes[0]], sourceBuffer[indexes[1]], sourceBuffer[indexes[2]], sourceBuffer[indexes[3]])
						neonFinalValue = vaddq_s32(neonFinalValue, vcvtq_s32_f32(vmulq_f32(neonTopRight, vcvtq_f32_s32(vld1q_s32(indexes)))))
						vst1q_s32(indexes, vaddq_s32(vaddq_s32(neonSCLTmultBPP, neonSRUTplusOnemultSS), neonBytes))
						(indexes[0], indexes[1], indexes[2], indexes[3]) = (sourceBuffer[indexes[0]], sourceBuffer[indexes[1]], sourceBuffer[indexes[2]], sourceBuffer[indexes[3]])
						neonFinalValue = vaddq_s32(neonFinalValue, vcvtq_s32_f32(vmulq_f32(neonBottomLeft, vcvtq_f32_s32(vld1q_s32(indexes)))))
						vst1q_s32(indexes, vaddq_s32(vaddq_s32(neonSCLTplusOnemultBPP, neonSRUTplusOnemultSS), neonBytes))
						(indexes[0], indexes[1], indexes[2], indexes[3]) = (sourceBuffer[indexes[0]], sourceBuffer[indexes[1]], sourceBuffer[indexes[2]], sourceBuffer[indexes[3]])
						neonFinalValue = vaddq_s32(neonFinalValue, vcvtq_s32_f32(vmulq_f32(neonBottomRight, vcvtq_f32_s32(vld1q_s32(indexes)))))

						neonResultIndex := vaddq_s32(vaddq_s32(vmulq_s32(neonResultColumnTransformed, neonBytesPerPixel), vmulq_s32(neonResultRowTransformed, vdupq_n_s32(target stride))), neonBytes)
						resultBuffer[vgetq_lane_s32(neonResultIndex, 0)] = vgetq_lane_s32(neonFinalValue, 0)
						resultBuffer[vgetq_lane_s32(neonResultIndex, 1)] = vgetq_lane_s32(neonFinalValue, 1)
						resultBuffer[vgetq_lane_s32(neonResultIndex, 2)] = vgetq_lane_s32(neonFinalValue, 2)
						resultBuffer[vgetq_lane_s32(neonResultIndex, 3)] = vgetq_lane_s32(neonFinalValue, 3)
					}
					column += neonLength
					neonColumn = vaddq_f32(neonColumn, vdupq_n_f32(neonLength as Float))
				}
			}
			row += neonLength
			neonRow = vaddq_f32(neonRow, vdupq_n_f32(neonLength as Float))
		}
		if (row < maxRow)
			This _resizeBilinear(source, target, sourceBox, resultBox, row, maxRow, 0, resultWidth)
		if (column < resultWidth)
			This _resizeBilinear(source, target, sourceBox, resultBox, 0, row, column, resultWidth)
		memfree(sourceRowUp)
		memfree(weightDown)
		memfree(indexes)
	}
	/*_blendSquareNeon: static func (sourceBuffer, resultBuffer: Byte*, sourceStride, resultStride, bytesPerPixel: Int, neonSourceRow, neonSourceColumn, neonRow, neonColumn: Int32x4, neonTopLeft, neonTopRight, neonBottomLeft, neonBottomRight: Float32x4) {
		neonLength := 4

		neonBytesPerPixel := vdupq_n_s32(bytesPerPixel)

	}*/

}

RasterPacked: abstract class extends RasterImage {
	_buffer: ByteBuffer
	_stride: Int
	buffer ::= this _buffer
	stride ::= this _stride
	bytesPerPixel: Int { get }
	init: func (=_buffer, size: IntVector2D, =_stride, coordinateSystem := CoordinateSystem Default) {
		super(size, coordinateSystem)
		this _buffer referenceCount increase()
	}
	init: func ~allocateStride (size: IntVector2D, stride: UInt) { this init(ByteBuffer new(stride * size y), size, stride) }
	init: func ~allocate (size: IntVector2D) {
		stride := this bytesPerPixel * size x
		this init(ByteBuffer new(stride * size y), size, stride)
	}
	init: func ~fromOriginal (original: This) {
		super(original)
		this _buffer = original buffer copy()
		this _stride = original stride
	}
	init: func ~fromRasterImage (original: RasterImage) {
		super(original)
		this _stride = this bytesPerPixel * original width
		this _buffer = ByteBuffer new(this stride * original height)
	}
	free: override func {
		if (this _buffer != null)
			this _buffer referenceCount decrease()
		this _buffer = null
		super()
	}
	equals: func (other: Image) -> Bool {
		other instanceOf(This) && this bytesPerPixel == (other as This) bytesPerPixel && this as Image equals(other)
	}
	distance: override func (other: Image) -> Float {
		other instanceOf(This) && this bytesPerPixel == (other as This) bytesPerPixel ? this as Image distance(other) : Float maximumValue
	}
	asRasterPacked: func (other: This) -> This {
		other
	}
	save: override func (filename: String) -> Int {
		file := File new(filename)
		folder := file parent . mkdirs() . free()
		file free()
		StbImage writePng(filename, this size x, this size y, this bytesPerPixel, this buffer pointer, this size x * this bytesPerPixel)
	}
	swapChannels: func (first, second: Int) {
		version(safe)
			raise(first > this bytesPerPixel || second > this bytesPerPixel, "Channel number too large")
		pointer := this buffer pointer
		index := 0
		while (index < this buffer size) {
			value := pointer[index + first]
			pointer[index + first] = pointer[index + second]
			pointer[index + second] = value
			index += this bytesPerPixel
		}
	}
}
