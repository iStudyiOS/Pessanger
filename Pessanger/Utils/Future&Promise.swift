
import Foundation

/// Source code from : https://www.swiftbysundell.com/articles/under-the-hood-of-futures-and-promises-in-swift
class Future<Value> {
		typealias Result = Swift.Result<Value, Error>
		
		var result: Result? {
				didSet { result.map(report) }
		}
		private var callbacks = [(Result) -> Void]()
		
		func observe(using callback: @escaping (Result) -> Void) {
				if let result = result {
						return callback(result)
				}
				callbacks.append(callback)
		}
		private func report(result: Result) {
				callbacks.forEach { $0(result) }
				callbacks = []
		}
		
		func chained<T>(using closure: @escaping (Value) throws -> Promise<T>) -> Promise<T> {
				let promise = Promise<T>()
				
				observe { result in
						switch result {
						case .success(let value):
								do {
										let future = try closure(value)
										
										future.observe { result in
												switch result{
												case .success(let value):
														promise.resolve(with: value)
												case .failure(let error):
														promise.reject(with: error)
												}
										}
								}catch {
										promise.reject(with: error)
								}
						case .failure(let error):
								promise.reject(with: error)
						}
				}
				return promise
		}
		func transFormed<T> (with closure: @escaping (Value) throws -> T) -> Promise<T> {
				chained { value in
						try Promise(value: closure(value))
				}
		}
}


class Promise<Value>: Future<Value> {
		init(value: Value? = nil) {
				super.init()
				result = value.map(Result.success)
		}
		func resolve(with value: Value) {
				result = .success(value)
		}
		func reject(with error: Error) {
				result = .failure(error)
		}
	static func rejected(with error: Error) -> Promise<Value> {
		let promise = Promise<Value>()
		promise.reject(with: error)
		return promise
	}
	/**
			Make compouned promise
			- parameters:
				- first: Promise for no value
				- second: Promise for no value
			- returns:
					Promise wit no value will be resolve only when both promise is resolved
	*/
	static func dual(first: Promise<Void>, second: Promise<Void>) -> Promise<Void> {
		let dual = Promise<Void>()
		first.observe { result in
			if case .success = result {
				if case .success = second.result ,
					 dual.result == nil{
					dual.resolve(with: ())
				}
				else if case .failure(let error) = second.result {
					dual.reject(with: error)
				}
			}
		}
		second.observe { result in
			if case .success = result {
				if case .success = first.result ,
					 dual.result == nil{
					dual.resolve(with: ())
				}
			}
			else if case .failure(let error) = first.result {
				dual.reject(with: error)
			}
		}
		return dual
	}
}
