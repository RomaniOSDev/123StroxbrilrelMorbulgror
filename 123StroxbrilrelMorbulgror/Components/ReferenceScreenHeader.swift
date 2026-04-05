import SwiftUI

/// Page title block with optional eyebrow and decorative rule.
struct ReferenceScreenHeader: View {
    let eyebrow: String?
    let title: String
    let subtitle: String?

    init(eyebrow: String? = nil, title: String, subtitle: String? = nil) {
        self.eyebrow = eyebrow
        self.title = title
        self.subtitle = subtitle
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            ReferenceHeaderRule()
                .frame(maxWidth: .infinity)
                .frame(height: 4)
                .padding(.bottom, 2)

            if let eyebrow, !eyebrow.isEmpty {
                Text(eyebrow.uppercased())
                    .font(.caption.weight(.semibold))
                    .tracking(1.2)
                    .foregroundStyle(Color.appAccent)
            }

            Text(title)
                .font(.largeTitle.bold())
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color.appTextPrimary, Color.appTextPrimary.opacity(0.92), Color.appAccent.opacity(0.75)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .shadow(color: Color.appPrimary.opacity(0.25), radius: 8, y: 4)
                .fixedSize(horizontal: false, vertical: true)

            if let subtitle, !subtitle.isEmpty {
                Text(subtitle)
                    .font(.body)
                    .foregroundStyle(Color.appTextSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

private struct ReferenceHeaderRule: View {
    var body: some View {
        GeometryReader { geo in
            Canvas { context, size in
                let w = size.width
                var line = Path()
                line.move(to: .zero)
                line.addLine(to: CGPoint(x: w * 0.42, y: 0))
                context.stroke(
                    line,
                    with: .linearGradient(
                        Gradient(colors: [Color.appAccent, Color.appPrimary.opacity(0.3)]),
                        startPoint: CGPoint(x: 0, y: size.height * 0.5),
                        endPoint: CGPoint(x: w * 0.42, y: size.height * 0.5)
                    ),
                    style: StrokeStyle(lineWidth: 4, lineCap: .round)
                )
            }
        }
        .frame(height: 4)
    }
}
