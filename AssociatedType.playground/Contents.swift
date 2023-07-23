import UIKit

protocol ShoppingCartable {
    associatedtype ProductType
    var products: [ProductType] { get set}
    mutating func addToCart(_ product: ProductType)
    mutating func removeFromCart(_ product: ProductType)
    func totalProducts() -> Int
}
extension ShoppingCartable {
    mutating func addToCart(_ product: ProductType) {
        products.append(product)
    }
    mutating func removeFromCart(_ product: ProductType) {
        fatalError("Need to implement at stuct level and call there not here!!")
    }
    func totalProducts() -> Int {
        return products.count
    }
}
struct Food {
    let name: String
    let price: Double
}
struct Shape {
    let name: String
    let side: Int
    let verticies: Int
}
struct FoodStore: ShoppingCartable {
    var products: [Food] = []
    mutating func removeFromCart(_ product: Food) {
        products.removeAll(where: {$0.name == product.name})
    }
}

var store = FoodStore()
let milk = Food(name: "Milk", price: 5.0)
store.addToCart(milk)

struct ShapedItem: ShoppingCartable {
    var products: [Shape] = []
    
    mutating func removeFromCart(_ product: Shape) {
        products.removeAll(where: {$0.name == product.name && $0.side == product.side})
    }
}

var shapeItem = ShapedItem()
let round = Shape(name: "Round", side: 1, verticies: 1)
shapeItem.addToCart(round)
let circle = Shape(name: "Circle", side: 1, verticies: 1)
shapeItem.addToCart(circle)
let line = Shape(name: "line", side: 1, verticies: 2)
shapeItem.addToCart(line)

debugPrint(shapeItem.products)
debugPrint(shapeItem.totalProducts())

shapeItem.removeFromCart(circle)
debugPrint(shapeItem.products)
debugPrint(shapeItem.totalProducts())
