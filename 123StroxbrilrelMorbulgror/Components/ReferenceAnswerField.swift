import SwiftUI

struct ReferenceAnswerField: View {
    let placeholder: String
    @Binding var text: String
    var keyboard: UIKeyboardType = .default

    var body: some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [Color.appBackground.opacity(0.98), Color.appBackground.opacity(0.88)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .stroke(
                            LinearGradient(
                                colors: [Color.appAccent.opacity(0.55), Color.appPrimary.opacity(0.35)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1.5
                        )
                )
                .shadow(color: Color.black.opacity(0.25), radius: 1, y: 1)
                .shadow(color: Color.appPrimary.opacity(0.12), radius: 6, y: 3)

            TextField("", text: $text, prompt: promptText)
                .textFieldStyle(.plain)
                .padding(10)
                .foregroundStyle(Color.appTextPrimary)
                .tint(Color.appAccent)
                .keyboardType(keyboard)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
        }
        .frame(minHeight: 40)
    }

    private var promptText: Text {
        Text(placeholder)
            .foregroundColor(Color.appTextSecondary)
    }
}
