//
//  Student.swift
//  CHEN
//
//  Created by Sean on 8/3/25.
//
//

import Foundation
import SwiftData


@Model class Student {
    var batch: Int16
    var cardID: String?
    var uuid: UUID
    var indexNumber: String
    var name: String
    
    var _session: Session.RawValue
    var session: Session {
        get { .init(rawValue: _session)! }
        set { _session = newValue.rawValue }
    }
    
    var _studentType: StudentType.RawValue = "Student"
    
    var studentType: StudentType {
        get { .init(rawValue: _studentType)! }
        set { _studentType = newValue.rawValue }
    }
    var streak: Int16? = 0
    @Relationship(deleteRule: .cascade, inverse: \Attendance.person) var attendances: [Attendance]
    public init(id: UUID, indexNumber: String, name: String, session: Session, batch: Int16, studentType: StudentType = .student) {
        self.uuid = id
        self.indexNumber = indexNumber
        self.name = name
        self._session = session.rawValue
        self.batch = batch
        self.attendances = []
        self.studentType = studentType
    }
    
}

enum Session: String, Codable {
    // string conversion for purpose of easy backporting of types
    case AM = "AM"
    case PM = "PM"
    // Special case to describe both sessions
    case fullDay = "fullDay"
}

enum StudentType: String, Codable {
    case student = "Student"
    case alumni = "Alumni"
    
}
