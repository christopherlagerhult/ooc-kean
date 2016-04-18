version (android) {
include ./inc/fastcv

// TODO: write test for FastCv.ooc
fcvScaleDownNNu8: extern func (src: Byte*, srcWidth, srcHeight, srcStride: UInt, dst: Byte*, dstWidth, dstHeight, dstStride: UInt) -> Int
fcvScaleDownu8: extern func (src: Byte*, srcWidth, srcHeight: UInt, dst: Byte*, dstWidth, dstHeight: UInt)
fcvScaleUpPolyu8: extern func (src: Byte*, srcWidth, srcHeight, srcStride: UInt, dst: Byte*, dstWidth, dstHeight, dstStride: UInt)
fcvScaleu8_v2: extern func (src: Byte*, srcWidth, srcHeight, srcStride: UInt, dst: Byte*, dstWidth, dstHeight, dstStride: UInt, interpolation, borderType: Int, borderValue: Byte)
fcvSetOperationMode: extern func (Int) -> Int
fcvCleanUp: extern func
}