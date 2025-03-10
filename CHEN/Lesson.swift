//
//  Lesson.swift
//  CHEN
//
//  Created by Sean on 8/3/25.
//
//

import Foundation
import SwiftData


@Model class Lesson {
    var date: Date
    var uuid: UUID
    var lessonLabel: String
    var name: String
    
    var _session: Session.RawValue
    
    var session: Session {
        get { Session(rawValue: _session)! }
        set { _session = newValue.rawValue }
    }
    @Relationship(deleteRule: .cascade, inverse: \Attendance.forLesson) var attendances: [Attendance]
    public init(date: Date, uuid: UUID, lessonLabel: String, name: String, session: Session) {
        self.date = date
        self.uuid = uuid
        self.lessonLabel = lessonLabel
        self.name = name
        self._session = session.rawValue
        self.attendances = []
    }
}

enum LessonSession: String {
    case AM = "AM"
    case PM = "PM"
    case fullDay = "fd"
}
