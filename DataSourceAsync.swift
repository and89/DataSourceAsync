import Foundation

/// Интерфейс подписчиков
protocol DataSourceObserver {
    func didChangeState(state: DataSource.State?)
}

final class DataSource {
    private let queue = DispatchQueue(
        label: "com.DataSource",
        qos: .userInteractive,
        attributes: [.concurrent])
    
    /// Описывает текущее состояние
    struct State {
        var title: String
    }
    
    private var state: State?
    
    /// Описывает новое состояние
    struct StateUpdate {
        var newState: State?
    }
    
    private var observers = [DataSourceObserver]()
    
    /// Добавление подписчика
    func addObserver(observer: DataSourceObserver) {
        self.change { currentState in
            self.observers.append(observer)
            return nil
        }
    }
    
    ///
    func change(_ change: @escaping (State?) -> (StateUpdate?)) {
        let workItem = DispatchWorkItem(qos: .default, flags: .barrier) {
            guard let updatedState = change(self.state) else {
                return
            }
            self.state = updatedState.newState
            self.observers.forEach { $0.didChangeState(state: self.state) }
        }
        queue.async(execute: workItem)
    }
    
    func read(read: @escaping (DataSource) -> ()) {
        queue.async {
            read(self)
        }
    }
}
