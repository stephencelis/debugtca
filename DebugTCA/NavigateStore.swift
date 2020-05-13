//
//  NavigateStore.swift
//  DebugTCA
//
//  Created by MD AL MAMUN on 2020-05-13.
//  Copyright © 2020 MD AL MAMUN. All rights reserved.
//

import Foundation
import ComposableArchitecture


// Enable this and it will work!!!

//  public subscript<Value>(ifLet2 keyPath: WritableKeyPath<Wrapped, Value>) -> Value? {
//    get {
//        self.map { $0[keyPath: keyPath] }
//    }
//    set {
//      guard let newValue = newValue else { return }
//      self?[keyPath: keyPath] = newValue
//    }
//  }
//}





struct CounterState: Equatable {
  var count = 0
}

enum CounterAction: Equatable {
  case decrementButtonTapped
  case incrementButtonTapped
}

struct CounterEnvironment {}

let counterReducer = Reducer<CounterState, CounterAction, CounterEnvironment> { state, action, _ in
  switch action {
  case .decrementButtonTapped:
    state.count -= 1
    return .none
  case .incrementButtonTapped:
    state.count += 1
    return .none
  }
}


struct LazyListNavigationState: Equatable {
  var rows: IdentifiedArrayOf<Row> = []
  var selection: Identified<Row.ID, CounterState>?

  struct Row: Equatable, Identifiable {
    var count: Int
    let id: UUID
    var isActivityIndicatorVisible = false
  }
}

enum LazyListNavigationAction: Equatable {
  case counter(CounterAction)
  case setNavigation(selection: UUID?)
  case setNavigationSelectionDelayCompleted(UUID)
}

struct LazyListNavigationEnvironment {
  var mainQueue: AnySchedulerOf<DispatchQueue>
}

let lazyListNavigationReducer = Reducer<
  LazyListNavigationState, LazyListNavigationAction, LazyListNavigationEnvironment
>.combine(
  Reducer { state, action, environment in

    .none
  },
  counterReducer.optional.pullback(
    state: \.selection[ifLet: \.value],
    action: /LazyListNavigationAction.counter,
    environment: { _ in CounterEnvironment() }
  )
)
