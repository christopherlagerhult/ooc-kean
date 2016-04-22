version (android) {
include ./inc/fastcv

OperationMode: enum {
	FASTCV_OP_LOW_POWER //The QDSP implementation will be used unless the QDSP speed is 3 times slower than CPU speed.
	FASTCV_OP_PERFORMANCE //The fastest implementation will be used.
	FASTCV_OP_CPU_OFFLOAD //The QDSP implementation will be used when it’s available, otherwise it will find for GPU and CPU implementation.
	FASTCV_OP_CPU_PERFORMANCE //The CPU fastest implementation will be used.
	FASTCV_OP_RESERVED //Values >= 0x80000000 are reserved
}

// TODO: write test for FastCv.ooc
fcvScaleDownNNu8: extern func (src: Byte*, srcWidth, srcHeight, srcStride: UInt, dst: Byte*, dstWidth, dstHeight, dstStride: UInt) -> Int
fcvScaleDownu8: extern func (src: Byte*, srcWidth, srcHeight: UInt, dst: Byte*, dstWidth, dstHeight: UInt)
fcvScaleUpPolyu8: extern func (src: Byte*, srcWidth, srcHeight, srcStride: UInt, dst: Byte*, dstWidth, dstHeight, dstStride: UInt)
fcvScaleu8_v2: extern func (src: Byte*, srcWidth, srcHeight, srcStride: UInt, dst: Byte*, dstWidth, dstHeight, dstStride: UInt, interpolation, borderType: Int, borderValue: Byte)
fcvSetOperationMode: extern func (OperationMode) -> Int
fcvCleanUp: extern func
}