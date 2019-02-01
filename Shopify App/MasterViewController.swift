//
//  MasterViewController.swift
//  Shopify App
//
//  Created by David Muzi on 2019-01-25.
//  Copyright © 2019 Muzi. All rights reserved.
//

import UIKit

class MasterViewController: UITableViewController {
	var products = [Product]()
	let loginController = LoginController()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		let loginButton = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(login))
		navigationItem.rightBarButtonItem = loginButton
	}

	@objc
	func login(_ sender: Any) {
		loginController.login { (token) in
			self.fetchProducts(token: token)
		}
	}

	private func fetchProducts(token: String) {
		let session = ShopifyAPI.URLSession(token: token, domain: ProcessInfo.processInfo.shopDomain)

		session.get(resource: Products.self) { result in
			
			self.products = result!.products
			
			DispatchQueue.main.async {
				self.tableView.reloadData()
			}
		}
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return products.count
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

		cell.textLabel!.text = products[indexPath.row].title
		return cell
	}
}
