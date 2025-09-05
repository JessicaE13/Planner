import SwiftUI

struct EditRoutineNavigationView: View {
    @Binding var routine: Routine
    @Environment(\.dismiss) private var dismiss
    
    init(routine: Binding<Routine>) {
        self._routine = routine
    }
    
    var body: some View {
        CreateRoutineView(
            editingRoutine: routine,
            editingIndex: 0
        )
        .onDisappear {
            // The routine will be updated through the data manager
        }
    }
}
