import SwiftUI

struct GroceryListView: View {
    @EnvironmentObject private var groceryListViewModel: GroceryListViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 18) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Weekly grocery list")
                            .font(.title3.weight(.bold))
                            .foregroundStyle(Theme.cocoa)
                        Text("Generated from the current 7-day plan with simple ingredient totals and estimated Canadian pricing.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        Label(groceryListViewModel.totalCost.asCurrencyCAD, systemImage: "cart.fill")
                            .font(.headline)
                            .foregroundStyle(Theme.rose)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .bubuCard()

                    ForEach(FoodCategory.allCases) { category in
                        let items = groceryListViewModel.items.filter { $0.category == category }
                        if !items.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                Text(category.rawValue)
                                    .font(.headline)
                                    .foregroundStyle(Theme.cocoa)

                                ForEach(items) { item in
                                    HStack(alignment: .top) {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(item.name)
                                                .font(.subheadline.weight(.semibold))
                                                .foregroundStyle(Theme.cocoa)
                                            Text(item.quantityText)
                                                .font(.footnote)
                                                .foregroundStyle(.secondary)
                                        }
                                        Spacer()
                                        Text(item.estimatedPriceCAD.asCurrencyCAD)
                                            .font(.footnote.weight(.semibold))
                                            .foregroundStyle(Theme.rose)
                                    }
                                    if item.id != items.last?.id {
                                        Divider()
                                    }
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .bubuCard()
                        }
                    }
                }
                .padding()
            }
            .background(Theme.cream.ignoresSafeArea())
            .navigationTitle("Groceries")
        }
    }
}

#Preview {
    GroceryListView()
        .environmentObject(GroceryListViewModel())
}
