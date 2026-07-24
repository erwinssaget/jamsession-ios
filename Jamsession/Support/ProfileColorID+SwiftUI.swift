import SwiftUI

extension ProfileColorID {
    var color: Color {
        switch self {
        case .purple:
            .purple
        case .blue:
            .blue
        case .green:
            .green
        case .orange:
            .orange
        }
    }
}
