import Foundation

@MainActor
final class ExerciseViewModel: ObservableObject {
    @Published var tasks: [ExerciseTask]

    private let storage: StorageService

    init(storage: StorageService = .shared) {
        self.storage = storage
        self.tasks = storage.loadExerciseTasks()
    }

    func toggle(taskID: UUID) {
        guard let index = tasks.firstIndex(where: { $0.id == taskID }) else { return }
        tasks[index].isCompleted.toggle()
        storage.save(exerciseTasks: tasks)
    }
}
