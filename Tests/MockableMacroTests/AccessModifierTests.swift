//
//  AccessModifierTests.swift
//
//
//  Created by Nayanda Haberty on 29/5/24.
//

import MacroTesting
import XCTest
import SwiftSyntax
@testable import Mockable

final class AccessModifierTests: MockableMacroTestCase {
    func test_public_modifier() {
        assertMacro {
            """
            @Mockable
            public protocol Test {
                init(id: String)
                var foo: Int { get }
                func bar(number: Int) -> Int
            }
            """
        } expansion: {
            """
            public protocol Test {
                init(id: String)
                var foo: Int { get }
                func bar(number: Int) -> Int
            }

            #if MOCKING
            public final class MockTest: Test, Mockable.MockableService {
                public typealias Mocker = Mockable.Mocker<MockTest>
                private let mocker = Mocker()
                @available(*, deprecated, message: "Use given(_ service:) of Mockable instead. ")
                public func given() -> ReturnBuilder {
                    .init(mocker: mocker)
                }
                @available(*, deprecated, message: "Use when(_ service:) of Mockable instead. ")
                public func when() -> ActionBuilder {
                    .init(mocker: mocker)
                }
                @available(*, deprecated, message: "Use verify(_ service:) of MockableTest instead. ")
                public func verify(with assertion: @escaping Mockable.MockableAssertion) -> VerifyBuilder {
                    .init(mocker: mocker, assertion: assertion)
                }
                public func reset(_ scopes: Set<Mockable.MockerScope> = .all) {
                    mocker.reset(scopes: scopes)
                }
                public init(policy: Mockable.MockerPolicy? = nil) {
                    if let policy {
                        mocker.policy = policy
                    }
                }
                public init(id: String) {
                }
                public func bar(number: Int) -> Int {
                    let member: Member = .m2_bar(number: .value(number))
                    return mocker.mock(member) { producer in
                        let producer = try cast(producer) as (Int) -> Int
                        return producer(number)
                    }
                }
                public var foo: Int {
                    get {
                        let member: Member = .m1_foo
                        return mocker.mock(member) { producer in
                            let producer = try cast(producer) as () -> Int
                            return producer()
                        }
                    }
                }
                public enum Member: Mockable.Matchable, Mockable.CaseIdentifiable {
                    case m1_foo
                    case m2_bar(number: Parameter<Int>)
                    public func match(_ other: Member) -> Bool {
                        switch (self, other) {
                        case (.m1_foo, .m1_foo):
                            return true
                        case (.m2_bar(number: let leftNumber), .m2_bar(number: let rightNumber)):
                            return leftNumber.match(rightNumber)
                        default:
                            return false
                        }
                    }
                }
                public struct ReturnBuilder: Mockable.EffectBuilder {
                    private let mocker: Mocker
                    public init(mocker: Mocker) {
                        self.mocker = mocker
                    }
                    public var foo: Mockable.FunctionReturnBuilder<MockTest, ReturnBuilder, Int, () -> Int> {
                        .init(mocker, kind: .m1_foo)
                    }
                    public func bar(number: Parameter<Int>) -> Mockable.FunctionReturnBuilder<MockTest, ReturnBuilder, Int, (Int) -> Int> {
                        .init(mocker, kind: .m2_bar(number: number))
                    }
                }
                public struct ActionBuilder: Mockable.EffectBuilder {
                    private let mocker: Mocker
                    public init(mocker: Mocker) {
                        self.mocker = mocker
                    }
                    public var foo: Mockable.FunctionActionBuilder<MockTest, ActionBuilder> {
                        .init(mocker, kind: .m1_foo)
                    }
                    public func bar(number: Parameter<Int>) -> Mockable.FunctionActionBuilder<MockTest, ActionBuilder> {
                        .init(mocker, kind: .m2_bar(number: number))
                    }
                }
                public struct VerifyBuilder: Mockable.AssertionBuilder {
                    private let mocker: Mocker
                    private let assertion: Mockable.MockableAssertion
                    public init(mocker: Mocker, assertion: @escaping Mockable.MockableAssertion) {
                        self.mocker = mocker
                        self.assertion = assertion
                    }
                    public var foo: Mockable.FunctionVerifyBuilder<MockTest, VerifyBuilder> {
                        .init(mocker, kind: .m1_foo, assertion: assertion)
                    }
                    public func bar(number: Parameter<Int>) -> Mockable.FunctionVerifyBuilder<MockTest, VerifyBuilder> {
                        .init(mocker, kind: .m2_bar(number: number), assertion: assertion)
                    }
                }
            }
            #endif
            """
        }
    }

    func test_private_access_modifier() {
        assertMacro {
          """
          @Mockable
          private protocol Test {
              var foo: Int { get }
              func bar(number: Int) -> Int
          }
          """
        } expansion: {
            """
            private protocol Test {
                var foo: Int { get }
                func bar(number: Int) -> Int
            }

            #if MOCKING
            private final class MockTest: Test, Mockable.MockableService {
                typealias Mocker = Mockable.Mocker<MockTest>
                private let mocker = Mocker()
                @available(*, deprecated, message: "Use given(_ service:) of Mockable instead. ")
                func given() -> ReturnBuilder {
                    .init(mocker: mocker)
                }
                @available(*, deprecated, message: "Use when(_ service:) of Mockable instead. ")
                func when() -> ActionBuilder {
                    .init(mocker: mocker)
                }
                @available(*, deprecated, message: "Use verify(_ service:) of MockableTest instead. ")
                func verify(with assertion: @escaping Mockable.MockableAssertion) -> VerifyBuilder {
                    .init(mocker: mocker, assertion: assertion)
                }
                func reset(_ scopes: Set<Mockable.MockerScope> = .all) {
                    mocker.reset(scopes: scopes)
                }
                init(policy: Mockable.MockerPolicy? = nil) {
                    if let policy {
                        mocker.policy = policy
                    }
                }
                func bar(number: Int) -> Int {
                    let member: Member = .m2_bar(number: .value(number))
                    return mocker.mock(member) { producer in
                        let producer = try cast(producer) as (Int) -> Int
                        return producer(number)
                    }
                }
                var foo: Int {
                    get {
                        let member: Member = .m1_foo
                        return mocker.mock(member) { producer in
                            let producer = try cast(producer) as () -> Int
                            return producer()
                        }
                    }
                }
                enum Member: Mockable.Matchable, Mockable.CaseIdentifiable {
                    case m1_foo
                    case m2_bar(number: Parameter<Int>)
                    func match(_ other: Member) -> Bool {
                        switch (self, other) {
                        case (.m1_foo, .m1_foo):
                            return true
                        case (.m2_bar(number: let leftNumber), .m2_bar(number: let rightNumber)):
                            return leftNumber.match(rightNumber)
                        default:
                            return false
                        }
                    }
                }
                struct ReturnBuilder: Mockable.EffectBuilder {
                    private let mocker: Mocker
                    init(mocker: Mocker) {
                        self.mocker = mocker
                    }
                    var foo: Mockable.FunctionReturnBuilder<MockTest, ReturnBuilder, Int, () -> Int> {
                        .init(mocker, kind: .m1_foo)
                    }
                    func bar(number: Parameter<Int>) -> Mockable.FunctionReturnBuilder<MockTest, ReturnBuilder, Int, (Int) -> Int> {
                        .init(mocker, kind: .m2_bar(number: number))
                    }
                }
                struct ActionBuilder: Mockable.EffectBuilder {
                    private let mocker: Mocker
                    init(mocker: Mocker) {
                        self.mocker = mocker
                    }
                    var foo: Mockable.FunctionActionBuilder<MockTest, ActionBuilder> {
                        .init(mocker, kind: .m1_foo)
                    }
                    func bar(number: Parameter<Int>) -> Mockable.FunctionActionBuilder<MockTest, ActionBuilder> {
                        .init(mocker, kind: .m2_bar(number: number))
                    }
                }
                struct VerifyBuilder: Mockable.AssertionBuilder {
                    private let mocker: Mocker
                    private let assertion: Mockable.MockableAssertion
                    init(mocker: Mocker, assertion: @escaping Mockable.MockableAssertion) {
                        self.mocker = mocker
                        self.assertion = assertion
                    }
                    var foo: Mockable.FunctionVerifyBuilder<MockTest, VerifyBuilder> {
                        .init(mocker, kind: .m1_foo, assertion: assertion)
                    }
                    func bar(number: Parameter<Int>) -> Mockable.FunctionVerifyBuilder<MockTest, VerifyBuilder> {
                        .init(mocker, kind: .m2_bar(number: number), assertion: assertion)
                    }
                }
            }
            #endif
            """
        }
    }

    func test_mutating_modifier_filtered() {
        assertMacro {
            """
            @Mockable
            public protocol Test {
                mutating nonisolated func foo()
            }
            """
        } expansion: {
            """
            public protocol Test {
                mutating nonisolated func foo()
            }

            #if MOCKING
            public final class MockTest: Test, Mockable.MockableService {
                public typealias Mocker = Mockable.Mocker<MockTest>
                private let mocker = Mocker()
                @available(*, deprecated, message: "Use given(_ service:) of Mockable instead. ")
                public func given() -> ReturnBuilder {
                    .init(mocker: mocker)
                }
                @available(*, deprecated, message: "Use when(_ service:) of Mockable instead. ")
                public func when() -> ActionBuilder {
                    .init(mocker: mocker)
                }
                @available(*, deprecated, message: "Use verify(_ service:) of MockableTest instead. ")
                public func verify(with assertion: @escaping Mockable.MockableAssertion) -> VerifyBuilder {
                    .init(mocker: mocker, assertion: assertion)
                }
                public func reset(_ scopes: Set<Mockable.MockerScope> = .all) {
                    mocker.reset(scopes: scopes)
                }
                public init(policy: Mockable.MockerPolicy? = nil) {
                    if let policy {
                        mocker.policy = policy
                    }
                }
                public nonisolated func foo() {
                    let member: Member = .m1_foo
                    mocker.mock(member) { producer in
                        let producer = try cast(producer) as () -> Void
                        return producer()
                    }
                }
                public enum Member: Mockable.Matchable, Mockable.CaseIdentifiable {
                    case m1_foo
                    public func match(_ other: Member) -> Bool {
                        switch (self, other) {
                        case (.m1_foo, .m1_foo):
                            return true
                        }
                    }
                }
                public struct ReturnBuilder: Mockable.EffectBuilder {
                    private let mocker: Mocker
                    public init(mocker: Mocker) {
                        self.mocker = mocker
                    }
                    public func foo() -> Mockable.FunctionReturnBuilder<MockTest, ReturnBuilder, Void, () -> Void> {
                        .init(mocker, kind: .m1_foo)
                    }
                }
                public struct ActionBuilder: Mockable.EffectBuilder {
                    private let mocker: Mocker
                    public init(mocker: Mocker) {
                        self.mocker = mocker
                    }
                    public func foo() -> Mockable.FunctionActionBuilder<MockTest, ActionBuilder> {
                        .init(mocker, kind: .m1_foo)
                    }
                }
                public struct VerifyBuilder: Mockable.AssertionBuilder {
                    private let mocker: Mocker
                    private let assertion: Mockable.MockableAssertion
                    public init(mocker: Mocker, assertion: @escaping Mockable.MockableAssertion) {
                        self.mocker = mocker
                        self.assertion = assertion
                    }
                    public func foo() -> Mockable.FunctionVerifyBuilder<MockTest, VerifyBuilder> {
                        .init(mocker, kind: .m1_foo, assertion: assertion)
                    }
                }
            }
            #endif
            """
        }
    }
}
