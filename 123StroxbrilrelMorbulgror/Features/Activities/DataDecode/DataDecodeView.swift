import Charts
import SwiftUI

struct DataDecodeView: View {
    @StateObject private var viewModel: DataDecodeViewModel
    let onComplete: (RawActivityOutcome) -> Void

    init(difficulty: ReferenceDifficulty, level: ReferenceLevelIndex, onComplete: @escaping (RawActivityOutcome) -> Void) {
        _viewModel = StateObject(wrappedValue: DataDecodeViewModel(difficulty: difficulty, level: level))
        self.onComplete = onComplete
    }

    var body: some View {
        ZStack {
            ReferenceScreenBackground()
                .ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    header

                    chartBlock
                        .frame(height: 240)
                        .padding(.vertical, 6)

                    if !viewModel.showAxisLabels {
                        Text("Axis labels are hidden—compare bar heights carefully.")
                            .font(.footnote)
                            .foregroundStyle(Color.appTextSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    questionsBlock
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 18)
                .padding(.bottom, 88)
            }
        }
        .safeAreaInset(edge: .bottom) {
            ReferencePrimaryButton(title: primaryButtonTitle, action: {
                viewModel.submitPhase()
            })
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                LinearGradient(
                    colors: [Color.appBackground.opacity(0.92), Color.appBackground.opacity(0.98), Color.appPrimary.opacity(0.08)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .shadow(color: Color.black.opacity(0.18), radius: 14, y: -6)
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
            Text("Data Decode")
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
                Text("Step \(viewModel.phase + 1) of \(max(1, stepCount))")
                    .foregroundStyle(Color.appTextSecondary)
            }
            ReferenceProgressTrack(value: progressValue)
        }
    }

    private var stepCount: Int {
        switch viewModel.difficulty {
        case .easy, .normal: return 2
        case .hard: return 1
        }
    }

    private var progressValue: Double {
        let initial = max(viewModel.initialTimeTotal, 1)
        return min(1, max(0, viewModel.secondsRemaining / initial))
    }

    private var timeString: String {
        let s = max(0, viewModel.secondsRemaining)
        return String(format: "%.1fs left", s)
    }

    private var primaryButtonTitle: String {
        if viewModel.phase == stepCount - 1 {
            return "Verify"
        }
        return "Continue"
    }

    private var chartBlock: some View {
        Chart(viewModel.items) { item in
            BarMark(
                x: .value("Label", item.label),
                y: .value("Value", item.value)
            )
            .foregroundStyle(
                LinearGradient(
                    colors: [Color.appPrimary.opacity(0.75), Color.appAccent, Color.appAccent.opacity(0.9)],
                    startPoint: .bottom,
                    endPoint: .top
                )
            )
        }
        .chartXAxis(viewModel.showAxisLabels ? .automatic : .hidden)
        .chartYAxis(viewModel.showAxisLabels ? .automatic : .hidden)
        .padding(8)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [Color.appSurface.opacity(0.98), Color.appSurface.opacity(0.82)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(
                            LinearGradient(
                                colors: [Color.appAccent.opacity(0.35), Color.appPrimary.opacity(0.15)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
        )
        .referenceFloatingShadow(cornerRadius: 16)
    }

    @ViewBuilder
    private var questionsBlock: some View {
        switch viewModel.difficulty {
        case .easy:
            easyQuestions
        case .normal:
            normalQuestions
        case .hard:
            hardQuestions
        }
    }

    private var easyQuestions: some View {
        VStack(alignment: .leading, spacing: 16) {
            if viewModel.phase == 0 {
                Text("Feb is higher than Jan.")
                    .foregroundStyle(Color.appTextPrimary)
                Toggle(isOn: binding(for: 0)) {
                    Text("Statement is true")
                        .foregroundStyle(Color.appTextPrimary)
                }
                .tint(Color.appPrimary)
                .frame(minHeight: DesignConstants.minTap)
            } else {
                Text("What is the value shown for Apr?")
                    .foregroundStyle(Color.appTextPrimary)
                ReferenceAnswerField(
                    placeholder: "Type a number",
                    text: bindingString(for: 1),
                    keyboard: .numberPad
                )
                .frame(minHeight: DesignConstants.minTap)
            }
        }
    }

    private var normalQuestions: some View {
        VStack(alignment: .leading, spacing: 16) {
            if viewModel.phase == 0 {
                Text("Mar is higher than Apr.")
                    .foregroundStyle(Color.appTextPrimary)
                Toggle(isOn: binding(for: 0)) {
                    Text("Statement is true")
                        .foregroundStyle(Color.appTextPrimary)
                }
                .tint(Color.appPrimary)
                .frame(minHeight: DesignConstants.minTap)
            } else {
                Text("What is the difference between the highest and lowest values?")
                    .foregroundStyle(Color.appTextPrimary)
                ReferenceAnswerField(
                    placeholder: "Type a whole number",
                    text: bindingString(for: 1),
                    keyboard: .numberPad
                )
                .frame(minHeight: DesignConstants.minTap)
            }
        }
    }

    private var hardQuestions: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Compute the sum of the first and last values along the horizontal axis.")
                .foregroundStyle(Color.appTextPrimary)
                .fixedSize(horizontal: false, vertical: true)
            ReferenceAnswerField(
                placeholder: "Type the sum",
                text: bindingString(for: 0),
                keyboard: .decimalPad
            )
            .frame(minHeight: DesignConstants.minTap)
        }
    }

    private func binding(for index: Int) -> Binding<Bool> {
        Binding(
            get: { viewModel.toggleAnswers[index] ?? false },
            set: { viewModel.setToggleAnswer(index: index, value: $0) }
        )
    }

    private func bindingString(for index: Int) -> Binding<String> {
        Binding(
            get: { viewModel.numericAnswers[index] ?? "" },
            set: { viewModel.setNumericAnswer(index: index, value: $0) }
        )
    }
}
