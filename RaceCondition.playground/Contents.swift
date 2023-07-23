import Foundation

/*
 A race condition happens when two or more threads access a shared data and change it's value at the same time. Or, a race condition occurs when two threads use the same variable at a given time.
 
 A race condition occurs when the behavior of an application depends on the relative timing of events, such as the order in which threads are scheduled to run. This can lead to unpredictable results and hard-to-reproduce bugs.
 
 Best Practices for Avoiding Deadlocks/Race Conditions
    1. Instead of locks, use DispatchQueue, NSOperationQueue, or DispatchGroup
    2. Avoid nested locks
    3. For thead safety use DispatchQueue.sync
 */

class Counter {
    private var value = 0
    
    func increment() {
        value += 1
    }
    
    func getValue() -> Int {
        return value
    }
}

func showRaceCondition() {
    let counter = Counter()
    let group = DispatchGroup()
    
    for _ in 0..<1000 {
        group.enter() // Main Thread
        
        // Different global async thread on Main thread. No control over this. Back to Main thread only when its finished and handler returned to Main thread. There is no order of execution and completion
        DispatchQueue.global().async {
            counter.increment()
            group.leave()
        }
    }
    
    group.notify(queue: .main) {
        print("Counter value: \(counter.getValue())") // Unpredictable value
    }
}

// Unpredictable value due to Race condition
showRaceCondition()
showRaceCondition()
showRaceCondition()
showRaceCondition()
showRaceCondition()
showRaceCondition()
showRaceCondition()


func solvedRaceCondition() {
    let counter = Counter()
    let group = DispatchGroup()
    let serialDispatchQueue = DispatchQueue(label: "my.serial.lock.queue")
    
    for _ in 0..<1000 {
        group.enter() // Main Thread
        
        // Synchronous execution on Main Thread. Once this is finished then only next execution starts.
        serialDispatchQueue.sync {
            counter.increment()
            group.leave()
        }
    }
    
    group.notify(queue: .main) {
        print("Counter value: \(counter.getValue())") // Predictable value
    }
}

// Predictable value solving Race condition
solvedRaceCondition()
solvedRaceCondition()
solvedRaceCondition()
solvedRaceCondition()
solvedRaceCondition()
solvedRaceCondition()
solvedRaceCondition()


