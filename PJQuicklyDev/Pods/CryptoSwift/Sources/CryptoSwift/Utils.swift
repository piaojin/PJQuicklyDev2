//
//  CryptoSwift
//
//  Copyright (C) 2014-2017 Marcin Krzyżanowski <marcin@krzyzanowskim.com>
//  This software is provided 'as-is', without any express or implied warranty.
//
//  In no event will the authors be held liable for any damages arising from the use of this software.
//
//  Permission is granted to anyone to use this software for any purpose,including commercial applications, and to alter it and redistribute it freely, subject to the following restrictions:
//
//  - The origin of this software must not be misrepresented; you must not claim that you wrote the original software. If you use this software in a product, an acknowledgment in the product documentation is required.
//  - Altered source versions must be plainly marked as such, and must not be misrepresented as being the original software.
//  - This notice may not be removed or altered from any source or binary distribution.
//

@_transparent
func rotateLeft(_ value: UInt8, by: UInt8) -> UInt8 {
    ((value << by) & 0xFF) | (value >> (8 - by))
}

@_transparent
func rotateLeft(_ value: UInt16, by: UInt16) -> UInt16 {
    ((value << by) & 0xFFFF) | (value >> (16 - by))
}

@_transparent
func rotateLeft(_ value: UInt32, by: UInt32) -> UInt32 {
    ((value << by) & 0xFFFF_FFFF) | (value >> (32 - by))
}

@_transparent
func rotateLeft(_ value: UInt64, by: UInt64) -> UInt64 {
    (value << by) | (value >> (64 - by))
}

@_transparent
func rotateRight(_ value: UInt16, by: UInt16) -> UInt16 {
    (value >> by) | (value << (16 - by))
}

@_transparent
func rotateRight(_ value: UInt32, by: UInt32) -> UInt32 {
    (value >> by) | (value << (32 - by))
}

@_transparent
func rotateRight(_ value: UInt64, by: UInt64) -> UInt64 {
    ((value >> by) | (value << (64 - by)))
}

@_transparent
func reversed(_ uint8: UInt8) -> UInt8 {
    var v = uint8
    v = (v & 0xF0) >> 4 | (v & 0x0F) << 4
    v = (v & 0xCC) >> 2 | (v & 0x33) << 2
    v = (v & 0xAA) >> 1 | (v & 0x55) << 1
    return v
}

@_transparent
func reversed(_ uint32: UInt32) -> UInt32 {
    var v = uint32
    v = ((v >> 1) & 0x5555_5555) | ((v & 0x5555_5555) << 1)
    v = ((v >> 2) & 0x3333_3333) | ((v & 0x3333_3333) << 2)
    v = ((v >> 4) & 0x0F0F_0F0F) | ((v & 0x0F0F_0F0F) << 4)
    v = ((v >> 8) & 0x00FF_00FF) | ((v & 0x00FF_00FF) << 8)
    v = ((v >> 16) & 0xFFFF) | ((v & 0xFFFF) << 16)
    return v
}

func xor<T, V>(_ left: T, _ right: V) -> ArraySlice<UInt8> where T: RandomAccessCollection, V: RandomAccessCollection, T.Element == UInt8, T.Index == Int, V.Element == UInt8, V.Index == Int {
    return xor(left, right).slice
}

func xor<T, V>(_ left: T, _ right: V) -> [UInt8] where T: RandomAccessCollection, V: RandomAccessCollection, T.Element == UInt8, T.Index == Int, V.Element == UInt8, V.Index == Int {
    let length = Swift.min(left.count, right.count)

    let buf = UnsafeMutablePointer<UInt8>.allocate(capacity: length)
    buf.initialize(repeating: 0, count: length)
    defer {
        buf.deinitialize(count: length)
        buf.deallocate()
    }

    // xor
    for i in 0 ..< length {
        buf[i] = left[left.startIndex.advanced(by: i)] ^ right[right.startIndex.advanced(by: i)]
    }

    return Array(UnsafeBufferPointer(start: buf, count: length))
}

/**
 ISO/IEC 9797-1 Padding method 2.
 Add a single bit with value 1 to the end of the data.
 If necessary add bits with value 0 to the end of the data until the padded data is a multiple of blockSize.
 - parameters:
 - blockSize: Padding size in bytes.
 - allowance: Excluded trailing number of bytes.
 */
@inline(__always)
func bitPadding(to data: inout [UInt8], blockSize: Int, allowance: Int = 0) {
    let msgLength = data.count
    // Step 1. Append Padding Bits
    // append one bit (UInt8 with one bit) to message
    data.append(0x80)

    // Step 2. append "0" bit until message length in bits ≡ 448 (mod 512)
    let max = blockSize - allowance // 448, 986
    if msgLength % blockSize < max { // 448
        data += [UInt8](repeating: 0, count: max - 1 - (msgLength % blockSize))
    } else {
        data += [UInt8](repeating: 0, count: blockSize + max - 1 - (msgLength % blockSize))
    }
}
