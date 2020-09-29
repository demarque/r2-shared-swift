//
//  File.swift
//  r2-shared-swift
//
//  Created by Mickaël Menu on 13/07/2020.
//
//  Copyright 2020 Readium Foundation. All rights reserved.
//  Use of this source code is governed by a BSD-style license which is detailed
//  in the LICENSE file present in the project repository where this source code is maintained.
//

import Foundation

/// Represents a path on the file system.
///
/// Used to cache the `Format` to avoid computing it at different locations.
public final class File: Loggable {
    
    /// File URL on the file system.
    public let url: URL
    
    /// Remote source URL from which this file was downloaded, if relevant.
    public let sourceURL: URL?
    
    /// Last path component, or filename.
    public var name: String { url.lastPathComponent }
    
    /// Indicates whether the path points to a directory.
    ///
    /// This can be used to open exploded publication archives.
    /// *Warning*: This should not be called from the UI thread.
    public lazy var isDirectory: Bool = {
        warnIfMainThread()
        return (try? url.resourceValues(forKeys: [.isDirectoryKey]))?.isDirectory == true
    }()

    private let mediaTypeHint: String?
    private let knownFormat: Format?
    
    /// Creates a `File` from a file `url`.
    ///
    /// If the file was downloaded from a remote source, set it with `sourceURL` to give more
    /// context.
    ///
    /// Providing a known `mediaType` or `format` will improve performances when sniffing the
    /// file format.
    public init(url: URL, sourceURL: URL? = nil, mediaType: String? = nil, format: Format? = nil) {
        self.url = url
        self.sourceURL = sourceURL
        self.mediaTypeHint = mediaType
        self.knownFormat = format
    }
    
    /// Sniffed format of this file.
    ///
    /// *Warning*: This should not be called from the UI thread.
    public lazy var format: Format? = {
        warnIfMainThread()
        if let format = knownFormat {
            return format
        } else {
            return Format.of(url, mediaType: mediaTypeHint)
        }
    }()

}
