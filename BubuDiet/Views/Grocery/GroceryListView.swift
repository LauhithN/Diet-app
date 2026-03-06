import SwiftUI

struct GroceryListView: View {
    var showsNavigationShell = true

    var body: some View {
        Group {
            if showsNavigationShell {
                NavigationStack {
                    GroceryListContent()
                        .navigationTitle("Groceries")
                        .navigationBarTitleDisplayMode(.large)
                }
            } else {
                GroceryListContent()
            }
        }
        .bubuScreenBackground()
    }
}

struct GroceryListContent: View {
    @EnvironmentObject private var groceryListViewModel: GroceryListViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: Theme.Spacing.lg) {
                BubuSectionHeader(
                    eyebrow: "Shopping flow",
                    title: "Weekly grocery list",
                    subtitle: "Generated directly from the current meal plan so the list stays grounded in what you actually intend to cook."
                )

                headerCard

                ForEach(groceryListViewModel.groupedItems, id: \.0.id) { category, items in
                    VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                        Text(category.rawValue)
                            .font(Theme.Typography.section)
                            .foregroundStyle(Theme.Palette.cocoa)

                        ForEach(items) { item in
                            HStack(alignment: .top, spacing: Theme.Spacing.sm) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(item.name)
                                        .font(Theme.Typography.bodyStrong)
                                        .foregroundStyle(Theme.Palette.cocoa)
                                    Text(item.quantityText)
                                        .font(Theme.Typography.footnote)
                                        .foregroundStyle(Theme.Palette.mist)
                                }

                                Spacer()

                                Text(item.estimatedPriceCAD.asCurrencyCAD)
                                    .font(Theme.Typography.bodyStrong)
                                    .foregroundStyle(Theme.Palette.rose)
                            }
                            .padding(.vertical, 4)

                            if item.id != items.last?.id {
                                Divider()
                                    .overlay(Theme.Palette.border)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .bubuCard(tint: Theme.Palette.surface)
                }
            }
            .padding(.horizontal, Theme.Spacing.md)
            .padding(.vertical, Theme.Spacing.lg)
        }
    }

    private var headerCard: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            Text("One tidy list for the full week, with cost visibility built in so the routine stays sustainable.")
                .font(Theme.Typography.body)
                .foregroundStyle(Theme.Palette.mist)

            HStack(spacing: Theme.Spacing.xs) {
                BubuMetricPill(title: "Estimated total", value: groceryListViewModel.totalCost.asCurrencyCAD, icon: "cart.fill")
                BubuMetricPill(title: "Items", value: "\(groceryListViewModel.items.count)", icon: "list.bullet.rectangle.fill", accent: Theme.Palette.sage)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .bubuCard(tint: Theme.Palette.surfaceRaised)
    }
}

#Preview {
    GroceryListView()
        .environmentObject(GroceryListViewModel())
}
