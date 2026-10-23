import SwiftUI

/// View displaying previously analyzed transcripts with search and delete capabilities.
struct ConcallHistoryView: View {
    @ObservedObject var viewModel: ConcallViewModel
    @ObservedObject var resilienceViewModel: ResilienceViewModel
    @State private var filterQuery: String = ""
    
    var filteredList: [ConcallAnalysis] {
        if filterQuery.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return viewModel.savedAnalyses
        }
        return viewModel.savedAnalyses.filter {
            $0.metadata.companyName.localizedCaseInsensitiveContains(filterQuery) ||
            $0.metadata.ticker.localizedCaseInsensitiveContains(filterQuery)
        }
    }
    
    var body: some View {
        NavigationStack {
            List {
                if filteredList.isEmpty {
                    VStack(spacing: 8) {
                        Image(systemName: "doc.text.magnifyingglass")
                            .font(.largeTitle)
                            .foregroundStyle(Color.secondary)
                        Text("No Concall Analyses Found")
                            .font(.system(size: 16, weight: .semibold))
                        Text("Upload or paste an earnings call transcript to generate your first business intelligence report.")
                            .font(.system(size: 13))
                            .foregroundStyle(Color.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 30)
                    .listRowBackground(Color.clear)
                } else {
                    ForEach(filteredList) { item in
                        NavigationLink {
                            ConcallDetailView(
                                analysis: item,
                                resilienceViewModel: resilienceViewModel
                            )
                        } label: {
                            VStack(alignment: .leading, spacing: 6) {
                                HStack {
                                    Text(item.metadata.companyName)
                                        .font(.system(size: 15, weight: .bold, design: .rounded))
                                    Spacer()
                                    Text("\(item.metadata.quarter) \(item.metadata.fiscalYear)")
                                        .font(.system(size: 11, weight: .semibold, design: .monospaced))
                                        .padding(.horizontal, 6)
                                        .padding(.vertical, 2)
                                        .background(LOSTheme.primary.opacity(0.12))
                                        .foregroundStyle(LOSTheme.primary)
                                        .clipShape(Capsule())
                                }
                                
                                Text(item.executiveSummary)
                                    .font(.system(size: 12))
                                    .foregroundStyle(Color.secondary)
                                    .lineLimit(2)
                                
                                HStack(spacing: 12) {
                                    HStack(spacing: 4) {
                                        Image(systemName: "exclamationmark.triangle.fill")
                                            .font(.system(size: 10))
                                            .foregroundStyle(LOSTheme.criticalRed)
                                        Text("\(item.risks.count) Risks")
                                            .font(.system(size: 11, weight: .medium))
                                            .foregroundStyle(Color.secondary)
                                    }
                                    
                                    HStack(spacing: 4) {
                                        Image(systemName: "arrow.up.right.circle.fill")
                                            .font(.system(size: 10))
                                            .foregroundStyle(LOSTheme.safeGreen)
                                        Text("\(item.positives.count) Positives")
                                            .font(.system(size: 11, weight: .medium))
                                            .foregroundStyle(Color.secondary)
                                    }
                                    
                                    Spacer()
                                    
                                    Text(item.metadata.ticker)
                                        .font(.system(size: 11, weight: .bold, design: .monospaced))
                                        .foregroundStyle(Color.secondary)
                                }
                                .padding(.top, 2)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                    .onDelete { indexSet in
                        for index in indexSet {
                            let item = filteredList[index]
                            viewModel.deleteAnalysis(id: item.id)
                        }
                    }
                }
            }
            .searchable(text: $filterQuery, prompt: "Search company or ticker")
            .navigationTitle("Concall History")
        }
    }
}
