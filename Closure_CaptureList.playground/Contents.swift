import Foundation

class Person {
    var name = "Rambo"
}

func closureForCaptureList() {
    var val = 100 //Value Type
    var p = Person() //Reference Type
    
    let closureWithoutCaptureList = { // No captured list in this closure. Everytime invoked, then only it try to fetch what's available as it is not capturing anything within
        print("Closure without Capture list, val = \(val), Name = \(p.name)")
    }
    
    closureWithoutCaptureList() // val = 100, p.name = Rambo
    
    val = 200
    closureWithoutCaptureList() // val = 200, p.name = Rambo
    
    val = 300
    p.name = "Godambi"
    closureWithoutCaptureList() // val = 300, p.name = Godambi
    
    
    // Capture List
    
    val = 400
    let closureWithCaptureList = { [val, p] in // At this instance, it has captured value type val = 400 and reference type p, but not values of p which is p.name = Godambi within
        print("Closure2 val = \(val), Name = \(p.name)")
    }

    // val = 400, p.name = Godambi
    closureWithCaptureList()
    
    val = 500
    p.name = "Badami"
    // val = 400, p.name = Badami
    // Even though new value of val (value type) = 500 now, it's previous value is captured within the closure so there will be no change
    // p is reference type, so closure has captured only p reference value but not p contents, so you can see the new name
    closureWithCaptureList()
    
    val = 600
    p = Person() // A new reference is created and assigned to p, But the capture list will have the old reference value only. Any changes to p now, will be done in a different memory location and not in the location of old p reference. So instead of p.name = "Drakshi" which is in the new memeory location it prints old ref value "Badami"
    p.name = "Drakshi"
    // val = 400, p.name = Badami
    closureWithCaptureList()
    
}

closureForCaptureList()
