// FileStreamer.swift
//
// Copyright © 2018-2023 Vassilis Panagiotopoulos. All rights reserved.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy of
// this software and associated documentation files (the "Software"), to deal in the
// Software without restriction, including without limitation the rights to use, copy,
// modify, merge, publish, distribute, sublicense, and/or sell copies of the Software,
// and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all copies
// or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
// INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FIESS FOR A PARTICULAR
// PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE
// FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
// ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

import Foundation

typealias ChunkType = (Data?) -> Void

internal class FileStreamer {
    var nextChunkClosure: ChunkType?
    var bufferSize: Int = 1024
    var fileSize: Int = -1
    var sizeRead: Int = 0
    var bytesRead: Int = 0
    var fileHandle: FileHandle?
    var url: URL

    lazy var buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: bufferSize)

    init(url: URL, bufferSize: Int) {
        self.url = url
        self.bufferSize = bufferSize
        self.fileSize = MultipartFormDataHelpers.fileSize(withURL: url)
        self.fileHandle = FileHandle(forReadingAtPath: url.path)
    }

    func readNextChunk(seekToOffset offset: Int = 0, nextChunkClosure: ChunkType? = nil) throws {
        if let fileHandle = fileHandle {
            autoreleasepool {
                try? fileHandle.seek(toOffset: UInt64(offset))
                self.sizeRead = offset + self.bufferSize
                let data = fileHandle.readData(ofLength: self.bufferSize)
                    nextChunkClosure?(data)
            }
        }
    }
}
