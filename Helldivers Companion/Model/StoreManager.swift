//
//  StoreManager.swift
//  Helldivers Companion
//
//  Created by James Poole on 28/03/2024.
//

import Foundation
import StoreKit

class StoreManager: ObservableObject {
    @Published var products: [Product] = []
    
    @Published var showTips = false
    
    // to hold state of whether the tip sheet has automatically displayed during this session, if so dont do it again
    @Published var tipShownInSession = false

    
    let productOrder = ["small_tip", "medium_tip", "large_tip"]
    
    init() {
        loadProducts()
    }
    
    func loadProducts() {
        Task {
            do {
                let foundProducts = try await Product.products(for: productOrder)
                let sortedProducts = productOrder.compactMap { id in foundProducts.first(where: { $0.id == id }) }
                DispatchQueue.main.async {
                    self.products = sortedProducts
                }
            } catch {
                print("Error loading products: \(error)")
            }
        }
    }
    
    func purchaseProduct(_ product: Product) {
        Task {
            do {
                let result = try await product.purchase()
                switch result {
                case let .success(.verified(transaction)):
                    // success!
                    await transaction.finish()
                case .success(.unverified(_, _)):
                    break
                case .pending:
                    break
                case .userCancelled:
                    break
                @unknown default:
                    break
                }
            } catch {
                print("Purchase failed: \(error)")
            }
        }
    }
}

