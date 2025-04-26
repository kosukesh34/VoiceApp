//
//  Recording.swift    .swift
//  VoiceApp
//
//  Created by Kosuke Shigematsu on 4/26/25.
//

import Foundation

struct Recording: Identifiable, Codable {
    let id: UUID
    var name: String
    let fileURL: URL
    var date: Date
    var startTime: TimeInterval?
    var endTime: TimeInterval?
}
