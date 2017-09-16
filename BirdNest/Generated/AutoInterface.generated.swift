// Generated using Sourcery 0.8.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

import Foundation
import ReactiveSwift
import Result


// MARK: TwitterAuthorizationType

public protocol TwitterAuthorizationType {
	func requestToken() -> SignalProducer<TokenResponse, TwitterAuthorizationError>
	func requestAccessToken(token: String, verifier: String) -> SignalProducer<AccessTokenResponse, TwitterAuthorizationError>
}

extension TwitterAuthorization: TwitterAuthorizationType {}

struct MockTwitterAuthorizationType {


	let requestTokenReturnValue : Result<TokenResponse, TwitterAuthorizationError>

	func requestToken() -> SignalProducer<TokenResponse, TwitterAuthorizationError> {
		return SignalProducer(result: requestTokenReturnValue )
	}


	let requestAccessTokenReturnValue : Result<AccessTokenResponse, TwitterAuthorizationError>

	func requestAccessToken(token: String, verifier: String) -> SignalProducer<AccessTokenResponse, TwitterAuthorizationError> {
		return SignalProducer(result: requestAccessTokenReturnValue )
	}

}
