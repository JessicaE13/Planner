import SwiftUI

struct EditRoutineNavigationView: View {
    @Binding var routine: Routine
    @State private var routines: [Routine] = []
    @State private var routineIndex: Int = 0
    @Environment(\.dismiss) private var dismiss
    
    init(routine: Binding<Routine>) {
        self._routine = routine
    }
    
    var body: some View {
        CreateRoutineView(
            routines: $routines,
            editingRoutine: routine,
            editingIndex: routineIndex
        )
        .onAppear {
            routines = [routine]
            routineIndex = 0
        }
        .onChange(of: routines) { _, newRoutines in
            // Update the original routine binding immediately when routines array changes
            if routineIndex < newRoutines.count {
                routine = newRoutines[routineIndex]
            }
        }
        .onDisappear {
            // Ensure the routine is updated when view disappears as a fallback
            if routines.indices.contains(routineIndex) {
                routine = routines[routineIndex]
            }
        }
    }
}