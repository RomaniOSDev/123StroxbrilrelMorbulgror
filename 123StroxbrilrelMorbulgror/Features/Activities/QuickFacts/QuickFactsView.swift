import SwiftUI

struct QuickFactsView: View {
    @StateObject private var viewModel: QuickFactsViewModel
    @State private var selectedFactId: UUID?

    let onComplete: (RawActivityOutcome) -> Void

    init(difficulty: ReferenceDifficulty, level: ReferenceLevelIndex, onComplete: @escaping (RawActivityOutcome) -> Void) {
        _viewModel = StateObject(wrappedValue: QuickFactsViewModel(difficulty: difficulty, level: level))
        self.onComplete = onComplete
    }

    private let topicColumns = [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)]

    var body: some View {
        ZStack {
            ReferenceScreenBackground()
                .ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    header
                    instructionLine
                    topicsSection
                    factsSection
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 18)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.start()
        }
        .onDisappear {
            viewModel.stop()
        }
        .onChange(of: viewModel.outcome) { newValue in
            guard let newValue else { return }
            onComplete(newValue)
        }
        .onChange(of: viewModel.floatingFacts.count) { _ in
            if let selected = selectedFactId,
               !viewModel.floatingFacts.contains(where: { $0.id == selected }) {
                selectedFactId = nil
            }
        }
    }

    private var instructionLine: some View {
        Text("Tap a fact card, then tap the matching topic. Tap the same card again to deselect.")
            .font(.subheadline)
            .foregroundStyle(Color.appTextSecondary)
            .fixedSize(horizontal: false, vertical: true)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Quick Facts Challenge")
                .font(.title2.bold())
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color.appTextPrimary, Color.appAccent.opacity(0.85)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .shadow(color: Color.appPrimary.opacity(0.2), radius: 6, y: 3)
            HStack {
                Label(timeString, systemImage: "timer")
                    .foregroundStyle(Color.appAccent)
                Spacer()
                Text("Mistakes: \(viewModel.wrongAttempts)")
                    .foregroundStyle(Color.appTextSecondary)
            }
            ReferenceProgressTrack(value: progressValue)
        }
    }

    private var progressValue: Double {
        let initial = max(viewModel.initialTimeTotal, 1)
        return min(1, max(0, viewModel.secondsRemaining / initial))
    }

    private var timeString: String {
        let s = max(0, viewModel.secondsRemaining)
        if s >= 100 {
            return String(format: "%.0fs left", s)
        }
        return String(format: "%.1fs left", s)
    }

    private var topicsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Topic bins")
                .font(.headline)
                .foregroundStyle(Color.appTextPrimary)

            LazyVGrid(columns: topicColumns, spacing: 12) {
                ForEach(viewModel.topics) { topic in
                    Button {
                        guard let fid = selectedFactId else { return }
                        viewModel.handleDrop(factId: fid, on: topic.id)
                        if !viewModel.floatingFacts.contains(where: { $0.id == fid }) {
                            selectedFactId = nil
                        }
                    } label: {
                        VStack(spacing: 8) {
                            Text(topic.title)
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(Color.appTextPrimary)
                                .multilineTextAlignment(.center)
                                .minimumScaleFactor(0.7)
                                .lineLimit(2)
                                .padding(.horizontal, 6)
                            Text(selectedFactId == nil ? "Tap after selecting a fact" : "Place match here")
                                .font(.caption2)
                                .foregroundStyle(Color.appTextSecondary)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(minHeight: DesignConstants.minTap * 1.6)
                        .padding(8)
                        .background(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(
                                    LinearGradient(
                                        colors: [Color.appSurface.opacity(0.98), Color.appSurface.opacity(0.78)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .stroke(
                                    LinearGradient(
                                        colors: (selectedFactId != nil)
                                            ? [Color.appPrimary, Color.appAccent.opacity(0.7)]
                                            : [Color.appAccent.opacity(0.4), Color.appPrimary.opacity(0.15)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: (selectedFactId != nil) ? 2 : 1
                                )
                        )
                        .referenceFloatingShadow(cornerRadius: 12)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .disabled(selectedFactId == nil)
                }
            }
        }
    }

    private var factsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Fact cards")
                .font(.headline)
                .foregroundStyle(Color.appTextPrimary)

            ForEach(viewModel.floatingFacts) { fact in
                let isSelected = selectedFactId == fact.id
                Button {
                    if selectedFactId == fact.id {
                        selectedFactId = nil
                    } else {
                        selectedFactId = fact.id
                    }
                } label: {
                    Text(fact.text)
                        .font(.subheadline)
                        .foregroundStyle(Color.appTextPrimary)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(12)
                        .background(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(
                                    LinearGradient(
                                        colors: [Color.appBackground.opacity(0.98), Color.appBackground.opacity(0.82)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .stroke(
                                    LinearGradient(
                                        colors: isSelected
                                            ? [Color.appAccent, Color.appPrimary.opacity(0.7)]
                                            : [Color.appPrimary.opacity(0.55), Color.appAccent.opacity(0.25)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: isSelected ? 3 : 1
                                )
                        )
                        .shadow(color: isSelected ? Color.appAccent.opacity(0.35) : Color.black.opacity(0.12), radius: isSelected ? 10 : 4, y: isSelected ? 5 : 2)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
        }
    }
}
