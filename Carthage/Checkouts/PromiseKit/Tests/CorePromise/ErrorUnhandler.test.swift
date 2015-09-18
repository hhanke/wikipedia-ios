import Foundation
import XCTest
import PromiseKit


private enum Error: ErrorType {
    case Dummy
}

class ErrorHandlingTests_Swift: XCTestCase {

    var oldHandler: (ErrorType -> Void)!

    override func setUp() {
        oldHandler = PMKUnhandledErrorHandler
    }
    override func tearDown() {
        PMKUnhandledErrorHandler = oldHandler
    }

    private func twice(@noescape body: (Promise<Int>, XCTestExpectation) -> Void) {
        autoreleasepool {
            let ex = expectationWithDescription("Sealed")
            body(Promise<Int>(error: Error.Dummy), ex)
        }
        waitForExpectationsWithTimeout(1, handler: nil)

        autoreleasepool {
            let ex = expectationWithDescription("Unsealed")
            let p = Promise { fulfill, _ in
                fulfill(1)
            }.then { _ -> Int in
                throw Error.Dummy
            }
            body(p, ex)
        }
        waitForExpectationsWithTimeout(1, handler: nil)
    }

    // handler is called if error is not handled
    func test1() {
        twice { promise, ex in
            PMKUnhandledErrorHandler = { err in
                ex.fulfill()
            }
        }
    }

    // handler is *not* called if error is caught
    func test2() {
        twice { promise, ex in
            PMKUnhandledErrorHandler = { err in
                XCTFail()
            }
            promise.report { error in
                ex.fulfill()
            }
        }
    }

    // handler is *not* called if error is recovered
    func test3() {
        twice { promise, ex in
            PMKUnhandledErrorHandler = { err in
                XCTFail()
            }
            promise.recover { error -> Promise<Int> in
                return Promise(1)
            }.ensure {
                ex.fulfill()
            }
        }
    }

    // handler is *still* called if error is *not* recovered
    func test4() {
        twice { promise, ex in
            PMKUnhandledErrorHandler = { err in
                ex.fulfill()
            }
            promise.recover { error -> Int in
                throw error
            }
        }
    }

    // handler is called *once* if recovery fails with a *different* error
    func test5() {
        twice { promise, ex in
            PMKUnhandledErrorHandler = { err in
                ex.fulfill()
            }
            promise.recover { error -> Promise<Int> in
                firstly { throw Error.Dummy }
            }
        }
    }

    // handler is *not* called if error recovery fails with same error but eventually error is caught
    func test6() {
        twice { promise, ex2 in
            let ex1 = expectationWithDescription("")

            PMKUnhandledErrorHandler = { err in
                XCTFail()
            }
            promise.recover { error -> Int in
                throw error
            }.then { x in
                XCTFail()
            }.ensure {
                ex1.fulfill()
            }.report { err in
                ex2.fulfill()
            }
        }
    }

    func testDoubleRejectDoesNotTriggerUnhandler() {
        enum Error: ErrorType {
            case Test
        }

        PMKUnhandledErrorHandler = { err in
            XCTFail()
        }

        let (p, _, r) = Promise<Void>.pendingPromise()

        let ex1 = expectationWithDescription("")
        let ex2 = expectationWithDescription("")
        let ex3 = expectationWithDescription("")
        let ex4 = expectationWithDescription("")

        after(0.1).then { _ -> Void in r(Error.Test); ex1.fulfill() }
        after(0.15).then { _ -> Void in r(Error.Test); ex2.fulfill() }.ensure { ex3.fulfill() }

        p.report { error in
            ex4.fulfill()
        }

        waitForExpectationsWithTimeout(1, handler: nil)
    }

    func testPassThrough() {
        let ex = expectationWithDescription("")

        PMKUnhandledErrorHandler = { err in
            ex.fulfill()
        }

        enum Error: ErrorType {
            case Test
        }

        Promise<Void> { _, reject in
            after(0.1).then {
                throw Error.Test
            }.report { err in
                reject(err)
            }
        }

        waitForExpectationsWithTimeout(1, handler: nil)
    }

    func testConsumedPromiseStaysConsumedAsAnyPromise() {
        enum Error: ErrorType {
            case Test
        }

        PMKUnhandledErrorHandler = { err in
            XCTFail()
        }

        let ex1 = expectationWithDescription("")

        let p: Promise<Int> = firstly {
            throw Error.Test
        }

        XCTAssertTrue(p.rejected)

        let anyp = AnyPromise(bound: p)

        p.report { err in
            ex1.fulfill()
        }

        waitForExpectationsWithTimeout(1, handler: nil)

        print(anyp)
    }
}


extension NSError {
    @objc class public func pmk_setUnhandledErrorHandler(handler: (NSError) -> Void) {
        PMKUnhandledErrorHandler = { (error: ErrorType) -> Void in
            handler(error as NSError)
        }
    }
}