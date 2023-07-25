//  Understanding DeadLock and how to solve it
//
//  Created by Prasanna Rao.
//

import Foundation

/*
 Deadlock occurs when two or more threads are blocked indefinitely, waiting for each other to release a resource they need to continue execution.
 This created a circular dependency, where each thread is waiting for the other to release the resource it needs.
 */

func call_DeadLock() {
    var detailLabels = [String]()
    let dispatchGroup = DispatchGroup()

    dispatchGroup.enter() //Main Thread - Synchronous
    print("Enter One")
    sleep(4) // network service
    // New thread on Main thread to execute this block
    DispatchQueue.main.async {  //Wait for Main Thread - Synchronous to finish to execute and Main Thread waits for this tread to finsih, DEAD LOCK
        detailLabels.append("One")
        print("Leave One")
        dispatchGroup.leave()
    }
    
    dispatchGroup.enter() //Main Thread - Synchronous
    print("Enter Two")
    sleep(4) // network service
    DispatchQueue.main.async {   //Wait for Main Thread - Synchronous to finish to execute and Main Thread waits for this tread to finsih, DEAD LOCK
        detailLabels.append("Two")
        print("Leave Two")
        dispatchGroup.leave()
    }
    
    dispatchGroup.enter() //Main Thread - Synchronous
    print("Enter Three")
    sleep(4) // network service
    DispatchQueue.main.async {  //Wait for Main Thread - Synchronous to finish to execute and Main Thread waits for this tread to finsih, DEAD LOCK
        detailLabels.append("Three")
        print("Leave Three")
        dispatchGroup.leave()
    }
    
    dispatchGroup.enter() //Main Thread - Synchronous
    print("Enter Four")
    sleep(4) // network service
    DispatchQueue.main.async {  //Wait for Main Thread - Synchronous to finish to execute and Main Thread waits for this tread to finsih, DEAD LOCK
        detailLabels.append("Four")
        print("Leave Four")
        dispatchGroup.leave()
    }

    dispatchGroup.wait() //Wait on main thread to finish all tasks - Synchronous

    // Waits to execute any code here after all tasks are finished on Main thread
    print("I am here.....END")
}

// call_DeadLock() // This will cread dead lock


// **************************************************************************************************

func call_No_DeadLock() {
    var detailLabels = [String]()
    let dispatchGroup = DispatchGroup()

    dispatchGroup.enter() //Main Thread - Synchronous
    print("Enter One")
    sleep(4) // network service
    DispatchQueue.global().async {  //Executing on global queue Asynchronously and not waiting for Main Thread to finish
        detailLabels.append("One")
        print("Leave One")
        dispatchGroup.leave()
    }
    
    dispatchGroup.enter() //Main Thread - Synchronous
    print("Enter Two")
    sleep(4) // network service
    DispatchQueue.global().async {   //Executing on global queue Asynchronously and not waiting for Main Thread to finish
        detailLabels.append("Two")
        print("Leave Two")
        dispatchGroup.leave()
    }
    
    dispatchGroup.enter() //Main Thread - Synchronous
    print("Enter Three")
    sleep(4) // network service
    DispatchQueue.global().async {  //Executing on global queue Asynchronously and not waiting for Main Thread to finish
        detailLabels.append("Three")
        print("Leave Three")
        dispatchGroup.leave()
    }
    
    dispatchGroup.enter() //Main Thread - Synchronous
    print("Enter Four")
    sleep(4) // network service
    DispatchQueue.global().async {  //Executing on global queue Asynchronously and not waiting for Main Thread to finish
        detailLabels.append("Four")
        print("Leave Four")
        dispatchGroup.leave()
    }

    dispatchGroup.wait() // Wait on main thread to finish all tasks - Synchronous

    // Waits to execute any code here after all tasks are finished on Main thread
    print("I am here.....END")
}

call_No_DeadLock() // This will work
