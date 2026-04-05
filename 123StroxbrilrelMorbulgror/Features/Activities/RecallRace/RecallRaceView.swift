import SwiftUI

struct RecallRaceView: View {
    @StateObject private var viewModel: RecallRaceViewModel
    let onComplete: (RawActivityOutcome) -> Void

    init(difficulty: ReferenceDifficulty, level: ReferenceLevelIndex, onComplete: @escaping (RawActivityOutcome) -> Void) {
        _viewModel = StateObject(wrappedValue: RecallRaceViewModel(difficulty: difficulty, level: level))
        self.onComplete = onComplete
    }

    var body: some View {
        ZStack {
            ReferenceScreenBackground()
                .ignoresSafeArea()
            VStack(spacing: 0) {
                header
                List {
                    ForEach(viewModel.passages) { passage in
                        Section {
                            VStack(alignment: .leading, spacing: 10) {
                                ForEach(Array(passage.segments.enumerated()), id: \.offset) { _, segment in
                                    switch segment {
                                    case .text(let value):
                                        Text(value)
                                            .foregroundStyle(Color.appTextPrimary)
                                            .fixedSize(horizontal: false, vertical: true)
                                    case .blank(let blank):
                                        VStack(alignment: .leading, spacing: 6) {
                                            ReferenceAnswerField(
                                                placeholder: "Type the missing term",
                                                text: binding(for: blank.id),
                                                keyboard: .default
                                            )

                                            if let hint = blank.hint {
                                                Text("Hint: \(hint)")
                                                    .font(.footnote)
                                                    .foregroundStyle(Color.appTextSecondary)
                                            }

                                            if !blank.decoys.isEmpty {
                                                Text("Similar-sounding options: \(blank.decoys.joined(separator: ", "))")
                                                    .font(.footnote)
                                                    .foregroundStyle(Color.appTextSecondary)
                                                    .fixedSize(horizontal: false, vertical: true)
                                            }
                                        }
                                    }
                                }
                            }
                            .padding(.vertical, 6)
                        } header: {
                            Text(passage.title)
                                .foregroundStyle(Color.appTextPrimary)
                        }
                        .listRowBackground(Color.appSurface)
                    }
                }
                .listStyle(.insetGrouped)
                .scrollContentBackground(.hidden)

                VStack(spacing: 12) {
                    ReferencePrimaryButton(title: "Submit Answers", action: {
                        viewModel.submit()
                    })
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                    LinearGradient(
                        colors: [Color.appBackground.opacity(0.98), Color.appBackground.opacity(0.88), Color.appPrimary.opacity(0.06)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .shadow(color: Color.black.opacity(0.2), radius: 12, y: -4)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { viewModel.start() }
        .onDisappear { viewModel.stop() }
        .onChange(of: viewModel.outcome) { newValue in
            guard let newValue else { return }
            onComplete(newValue)
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Reference Recall Race")
                .font(.title2.bold())
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color.appTextPrimary, Color.appAccent.opacity(0.85)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .shadow(color: Color.appPrimary.opacity(0.18), radius: 6, y: 3)
            HStack {
                Label(timeString, systemImage: "timer")
                    .foregroundStyle(Color.appAccent)
                Spacer()
                Text("Attempts: \(viewModel.submitAttempts)")
                    .foregroundStyle(Color.appTextSecondary)
            }
            ReferenceProgressTrack(value: progressValue)
        }
        .padding(.horizontal, 16)
        .padding(.top, 12)
        .padding(.bottom, 6)
    }

    private var progressValue: Double {
        let initial = max(viewModel.initialTimeTotal, 1)
        return min(1, max(0, viewModel.secondsRemaining / initial))
    }

    private var timeString: String {
        let s = max(0, viewModel.secondsRemaining)
        return String(format: "%.1fs left", s)
    }

    private func binding(for id: UUID) -> Binding<String> {
        Binding(
            get: { viewModel.answers[id] ?? "" },
            set: { viewModel.answers[id] = $0 }
        )
    }
}
