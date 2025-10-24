//
//  VisionPromise.swift
//  ModuleTest
//
//  Created by Azuby on 30/03/2024.
//

import UIKit
import Vision

class VisionPromise<Value> {

    private enum State<T> {
        case pending
        case resolved(T)
    }

    private var state: State<Value> = .pending
    private var callbacks: [(Value) -> Void] = []

    init(executor: (_ resolve: @escaping (Value) -> Void) -> Void) {
        executor(resolve)
    }

    func then(_ onResolved: @escaping (Value) -> Void) {
        callbacks.append(onResolved)
        triggerCallbacksIfResolved()
    }

    func then<NewValue>(_ onResolved: @escaping (Value) -> VisionPromise<NewValue>) -> VisionPromise<NewValue> {
        return VisionPromise<NewValue> { resolve in
            then { value in
                onResolved(value).then(resolve)
            }
        }
    }

    func then<NewValue>(_ onResolved: @escaping (Value) -> NewValue) -> VisionPromise<NewValue> {
        return then { value in
            return VisionPromise<NewValue> { resolve in
                resolve(onResolved(value))
            }
        }
    }

    private func resolve(value: Value) {
        updateState(to: .resolved(value))
    }

    private func updateState(to newState: State<Value>) {
        guard case .pending = state else { return }
        state = newState
        triggerCallbacksIfResolved()
    }

    private func triggerCallbacksIfResolved() {
        guard case let .resolved(value) = state else { return }
        callbacks.forEach { callback in
            callback(value)
        }
        callbacks.removeAll()
    }
}
