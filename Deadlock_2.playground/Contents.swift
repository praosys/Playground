import Foundation

/*
 Here two threads are trying to obtain two locks. Thread 1 acquires lock1, sleeps for 1 second, and then tries to acquire lock2. Meanwhile, Thread 2 acquires lock2, sleeps for 1 second, and then tries to acquire lock1. This results in a deadlock, as both threads are waiting for the other to release the lock it needs.
 
 Best Practices for Avoiding Deadlocks/Race Conditions
    1. Instead of locks, use DispatchQueue, NSOperationQueue, or DispatchGroup
    2. Avoid nested locks
    3. For thead safety use DispatchQueue.sync
 */

let lock1 = NSLock()
let lock2 = NSLock()

func showDeadLock() {
    
    // This is Thread 1
    DispatchQueue.global().async {
        print("1.Lock1 locked")
        lock1.lock()
        sleep(1)
        print("1.Lock2 locked")
        lock2.lock()
        
        print("Thread 1")
        
        print("1.Lock2 unlock")
        lock2.unlock()
        print("1.Lock1 unlock")
        lock1.unlock()
    }
    
    // This is Thread 2
    DispatchQueue.global().async {
        print("2.Lock2 locked")
        lock2.lock()
        sleep(1)
        print("2.Lock1 locked")
        lock1.lock()
        
        print("Thread 2")
        
        print("2.Lock1 unlock")
        lock1.unlock()
        print("2.Lock2 unlock")
        lock2.unlock()
    }
}

showDeadLock()
