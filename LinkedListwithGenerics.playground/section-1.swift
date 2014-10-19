// Playground - noun: a place where people can play

import UIKit

var str = "What's up, playground?"


struct Stack <T> {
    
    private var items = [T]()
    
    mutating func push(item : T) {
        self.items.append(item)
    }
    
    mutating func pop() -> T {
        var itemToPop = self.items.last
        self.items.removeLast()
        return itemToPop!
    }
}

var newStack = Stack<String>()

newStack.push("Matthew")
newStack.push("Johnny Manziel")
newStack.pop() // returns the item that was popped (item at the end)

// make sure only Matthew is in items array
newStack.items


class Node <T> {
    var value: T?
    var next: Node?
}

class LinkedList <T> {
    var head: Node <T>?
    
    func insert(value: T) {
        
        // 0th case if list is empty
        if self.head == nil {
            var node = Node<T>()
            node.value = value
            node.next = nil
            head = node
            return
        }
        
        // walk the list
        if self.head != nil {
            var currentNode = self.head
            while currentNode?.next != nil {
                currentNode = currentNode?.next
            }
        }
    }
    
    func remove() {
        
        // walk the list but at the end, remove the value of the currentNode
        if self.head != nil {
            var currentNode = self.head
            while currentNode?.next != nil {
                currentNode = currentNode?.next
            }
            
            currentNode?.value = nil
        }
    }
}