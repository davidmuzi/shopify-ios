//
//  LoginController.swift
//  Shopify App
//
//  Created by David Muzi on 2019-02-01.
//  Copyright © 2019 Muzi. All rights reserved.
//

import Foundation
import AuthenticationServices

class LoginController {
	var auth: ASWebAuthenticationSession!

	func login(callback: @escaping (String) -> Void) {

		auth = ASWebAuthenticationSession(url: loginURL(), callbackURLScheme: "shop://auth") { (url, error) in
			guard let url = url else { return }
			let comp = URLComponents(url: url, resolvingAgainstBaseURL: false)!
			self.fetchToken(queryItems: comp.queryItems!, callback: callback)
		}
		auth.start()
	}
	
	private func fetchToken(queryItems: [URLQueryItem], callback: @escaping (String) -> Void) {
		let url = URL(string: "\(ProcessInfo.processInfo.serverURL)/app/fetch_token")!
		var comps = URLComponents(url: url, resolvingAgainstBaseURL: false)!
		comps.queryItems = queryItems
		let request = URLRequest(url: comps.url!)
		
		URLSession.shared.dataTask(with: request) { (data, response, error) in
			guard let data = data else { return }
			guard let token = String(data: data, encoding: .utf8) else { return }
			callback(token)
		}.resume()
	}
	
	private func loginURL() -> URL {
		let shop = ProcessInfo.processInfo.shopDomain
		let scope = ["read_products", "read_orders"]
		let clientID = ProcessInfo.processInfo.clientID
		let callbackURL = "\(ProcessInfo.processInfo.serverURL)/app/redirect"
		
		return URL(string: "https://\(shop)/admin/oauth/authorize?" +
			"client_id=\(clientID)&" +
			"scope=\(scope.joined(separator: ","))&" +
			"redirect_uri=\(callbackURL)")!
	}
}

extension ProcessInfo {
	var shopDomain: String { return environment["SHOP"]! }
	var clientID: String { return environment["CLIENT_ID"]! }
	var serverURL: String { return environment["SERVER"]! }
}
