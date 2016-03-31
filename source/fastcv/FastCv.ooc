version (android) {
include ./inc/fastcv

// TODO: write test for FastCv.ooc
fcvScaleDownNNu8: extern func (src: Byte*, srcWidth, srcHeight, srcStride: UInt, dst: Byte*, dstWidth, dstHeight, dstStride: UInt) -> Int
fcvScaleDownu8: extern func (src: Byte*, srcWidth, srcHeight: UInt, dst: Byte*, dstWidth, dstHeight: UInt)
fcvScaleUpPolyu8: extern func (src: Byte*, srcWidth, srcHeight, srcStride: UInt, dst: Byte*, dstWidth, dstHeight, dstStride: UInt)
fcvSetOperationMode: extern func (Int) -> Int
fcvCleanUp: extern func
}