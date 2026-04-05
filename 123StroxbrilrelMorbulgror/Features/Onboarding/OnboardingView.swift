import SwiftUI

struct OnboardingView: View {
    let onFinish: () -> Void

    @State private var page = 0
    @State private var animateIllustration = false

    private let pages: [(eyebrow: String, title: String, subtitle: String)] = [
        (
            "Hands-on",
            "Learn by Doing",
            "Short challenges mirror how you scan, compare, and verify information in real tasks."
        ),
        (
            "Your pace",
            "Climb the Levels",
            "Choose a comfortable pace, then advance as tasks grow richer and faster."
        ),
        (
            "Progress",
            "Track Bright Wins",
            "Earn up to three stars per level for accuracy and speed—keep improving your streak."
        )
    ]

    var body: some View {
        ZStack {
            ReferenceScreenBackground()
                .ignoresSafeArea()

            VStack(spacing: 0) {
                TabView(selection: $page) {
                    OnboardingPage(
                        eyebrow: pages[0].eyebrow,
                        title: pages[0].title,
                        subtitle: pages[0].subtitle,
                        pageIndex: 0,
                        illustration: { BookSparkIllustration(progress: animateIllustration && page == 0) }
                    )
                    .tag(0)

                    OnboardingPage(
                        eyebrow: pages[1].eyebrow,
                        title: pages[1].title,
                        subtitle: pages[1].subtitle,
                        pageIndex: 1,
                        illustration: { StepsIllustration(progress: animateIllustration && page == 1) }
                    )
                    .tag(1)

                    OnboardingPage(
                        eyebrow: pages[2].eyebrow,
                        title: pages[2].title,
                        subtitle: pages[2].subtitle,
                        pageIndex: 2,
                        illustration: { StarsRibbonIllustration(progress: animateIllustration && page == 2) }
                    )
                    .tag(2)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))

                VStack(spacing: 16) {
                    OnboardingPageIndicator(current: page, total: pages.count)

                    if page < 2 {
                        ReferencePrimaryButton(title: "Continue", systemImage: "arrow.right.circle.fill") {
                            withAnimation(DesignConstants.easeInOut) {
                                page += 1
                            }
                        }
                    } else {
                        ReferencePrimaryButton(title: "Get Started", systemImage: "sparkles") {
                            onFinish()
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 32)
                .padding(.top, 8)
                .background(
                    LinearGradient(
                        colors: [Color.appBackground.opacity(0.35), Color.appBackground.opacity(0.92)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .ignoresSafeArea(edges: .bottom)
                )
            }
        }
        .onAppear {
            withAnimation(DesignConstants.spring.delay(0.05)) {
                animateIllustration = true
            }
        }
        .onChange(of: page) { _ in
            animateIllustration = false
            withAnimation(DesignConstants.spring.delay(0.05)) {
                animateIllustration = true
            }
        }
    }
}

// MARK: - Page layout

private struct OnboardingPage<Illustration: View>: View {
    let eyebrow: String
    let title: String
    let subtitle: String
    let pageIndex: Int
    @ViewBuilder let illustration: () -> Illustration

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                ReferenceSurfaceCard(accent: .leading) {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Step \(pageIndex + 1) of 3")
                                .font(.caption.weight(.semibold))
                                .tracking(0.8)
                                .foregroundStyle(Color.appAccent)
                            Spacer()
                            Image(systemName: "book.pages.fill")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(Color.appPrimary.opacity(0.85))
                        }

                        illustration()
                            .frame(height: 200)
                            .frame(maxWidth: .infinity)
                    }
                }

                VStack(alignment: .leading, spacing: 14) {
                    Text(eyebrow.uppercased())
                        .font(.caption.weight(.semibold))
                        .tracking(1.15)
                        .foregroundStyle(Color.appAccent)

                    Text(title)
                        .font(.title.bold())
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color.appTextPrimary, Color.appTextPrimary.opacity(0.9), Color.appAccent.opacity(0.8)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .shadow(color: Color.appPrimary.opacity(0.22), radius: 8, y: 4)
                        .fixedSize(horizontal: false, vertical: true)

                    ReferenceSectionDivider()

                    Text(subtitle)
                        .font(.body)
                        .foregroundStyle(Color.appTextSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                        .lineSpacing(3)
                }
                .padding(.horizontal, 2)
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .padding(.bottom, 12)
        }
    }
}

// MARK: - Page dots

private struct OnboardingPageIndicator: View {
    let current: Int
    let total: Int

    var body: some View {
        HStack(spacing: 10) {
            ForEach(0..<total, id: \.self) { index in
                Group {
                    if index == current {
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [Color.appAccent, Color.appPrimary.opacity(0.85)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: 28, height: 8)
                            .shadow(color: Color.appAccent.opacity(0.45), radius: 6, y: 2)
                    } else {
                        Capsule()
                            .fill(Color.appTextSecondary.opacity(0.22))
                            .frame(width: 8, height: 8)
                    }
                }
                .animation(DesignConstants.spring, value: current)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Page \(current + 1) of \(total)")
    }
}

// MARK: - Illustrations

private struct BookSparkIllustration: View {
    let progress: Bool

    var body: some View {
        ZStack {
            Canvas { context, size in
                let w = size.width
                let h = size.height
                var book = Path()
                book.move(to: CGPoint(x: w * 0.25, y: h * 0.72))
                book.addLine(to: CGPoint(x: w * 0.25, y: h * 0.32))
                book.addQuadCurve(to: CGPoint(x: w * 0.52, y: h * 0.28), control: CGPoint(x: w * 0.38, y: h * 0.22))
                book.addLine(to: CGPoint(x: w * 0.78, y: h * 0.34))
                book.addLine(to: CGPoint(x: w * 0.78, y: h * 0.74))
                book.addQuadCurve(to: CGPoint(x: w * 0.52, y: h * 0.8), control: CGPoint(x: w * 0.66, y: h * 0.86))
                book.closeSubpath()

                context.fill(
                    book,
                    with: .linearGradient(
                        Gradient(colors: [Color.appSurface, Color.appPrimary.opacity(0.45), Color.appSurface.opacity(0.9)]),
                        startPoint: CGPoint(x: w * 0.25, y: h * 0.3),
                        endPoint: CGPoint(x: w * 0.78, y: h * 0.75)
                    )
                )
                context.stroke(book, with: .color(Color.appAccent.opacity(0.35)), lineWidth: 1.2)

                var spine = Path()
                spine.move(to: CGPoint(x: w * 0.52, y: h * 0.28))
                spine.addLine(to: CGPoint(x: w * 0.52, y: h * 0.8))
                context.stroke(spine, with: .color(Color.appAccent.opacity(0.65)), lineWidth: 2)
            }

            SparkBurst(progress: progress)
                .offset(y: -30)
        }
    }
}

private struct SparkBurst: View {
    let progress: Bool

    var body: some View {
        Canvas { context, size in
            let c = CGPoint(x: size.width * 0.52, y: size.height * 0.42)
            for i in 0..<8 {
                let t = CGFloat(i) / 8 * .pi * 2
                let len: CGFloat = progress ? 46 : 10
                var p = Path()
                p.move(to: c)
                p.addLine(to: CGPoint(x: c.x + cos(t) * len, y: c.y + sin(t) * len))
                context.stroke(
                    p,
                    with: .linearGradient(
                        Gradient(colors: [Color.appAccent, Color.appPrimary.opacity(0.7)]),
                        startPoint: c,
                        endPoint: CGPoint(x: c.x + cos(t) * len, y: c.y + sin(t) * len)
                    ),
                    lineWidth: 2.2
                )
            }
        }
        .animation(DesignConstants.spring, value: progress)
    }
}

private struct StepsIllustration: View {
    let progress: Bool

    var body: some View {
        Canvas { context, size in
            let w = size.width
            let h = size.height
            let heights: [CGFloat] = [0.55, 0.42, 0.62]
            for (i, hi) in heights.enumerated() {
                let x = w * (0.22 + CGFloat(i) * 0.26)
                let barHeight = h * hi * (progress ? 1 : 0.2)
                let rect = CGRect(x: x, y: h * 0.78 - barHeight, width: w * 0.16, height: barHeight)
                let rpath = Path(roundedRect: rect, cornerRadius: 8)
                let top = i == 2 ? Color.appAccent : Color.appPrimary.opacity(0.85)
                let bottom = i == 2 ? Color.appPrimary.opacity(0.55) : Color.appSurface.opacity(0.95)
                context.fill(
                    rpath,
                    with: .linearGradient(
                        Gradient(colors: [top, bottom]),
                        startPoint: CGPoint(x: rect.midX, y: rect.minY),
                        endPoint: CGPoint(x: rect.midX, y: rect.maxY)
                    )
                )
                context.stroke(rpath, with: .color(Color.appAccent.opacity(0.4)), lineWidth: 1)
            }

            var line = Path()
            line.move(to: CGPoint(x: w * 0.18, y: h * 0.24))
            line.addQuadCurve(to: CGPoint(x: w * 0.82, y: h * 0.2), control: CGPoint(x: w * 0.5, y: h * 0.08))
            context.stroke(
                line,
                with: .linearGradient(
                    Gradient(colors: [Color.appAccent.opacity(0.9), Color.appPrimary.opacity(0.35)]),
                    startPoint: CGPoint(x: w * 0.18, y: h * 0.22),
                    endPoint: CGPoint(x: w * 0.82, y: h * 0.2)
                ),
                style: StrokeStyle(lineWidth: 3, lineCap: .round)
            )
        }
        .animation(DesignConstants.spring, value: progress)
    }
}

private struct StarsRibbonIllustration: View {
    let progress: Bool

    var body: some View {
        ZStack {
            Canvas { context, size in
                let w = size.width
                let h = size.height
                var ribbon = Path()
                ribbon.move(to: CGPoint(x: w * 0.1, y: h * 0.55))
                ribbon.addCurve(
                    to: CGPoint(x: w * 0.9, y: h * 0.45),
                    control1: CGPoint(x: w * 0.35, y: h * 0.25),
                    control2: CGPoint(x: w * 0.65, y: h * 0.78)
                )
                context.stroke(
                    ribbon,
                    with: .linearGradient(
                        Gradient(colors: [Color.appAccent.opacity(0.95), Color.appPrimary.opacity(0.5)]),
                        startPoint: CGPoint(x: w * 0.1, y: h * 0.55),
                        endPoint: CGPoint(x: w * 0.9, y: h * 0.45)
                    ),
                    style: StrokeStyle(lineWidth: 4, lineCap: .round)
                )
            }

            HStack(spacing: 36) {
                ForEach(0..<3, id: \.self) { index in
                    StarShape()
                        .fill(
                            LinearGradient(
                                colors: [Color.appAccent, Color.appPrimary, Color.appAccent.opacity(0.85)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 26 + CGFloat(index) * 4, height: 26 + CGFloat(index) * 4)
                        .shadow(color: Color.appAccent.opacity(0.55), radius: progress ? 12 : 4)
                        .shadow(color: Color.appPrimary.opacity(0.35), radius: progress ? 6 : 2)
                        .offset(y: progress ? CGFloat(index) * -3 : 14)
                }
            }
            .offset(y: -10)
        }
        .animation(DesignConstants.spring, value: progress)
    }
}

private struct StarShape: Shape {
    func path(in rect: CGRect) -> Path {
        let c = CGPoint(x: rect.midX, y: rect.midY)
        let r = min(rect.width, rect.height) / 2
        var path = Path()
        for i in 0..<5 {
            let angle = CGFloat(i) * .pi * 2 / 5 - .pi / 2
            let p = CGPoint(x: c.x + cos(angle) * r, y: c.y + sin(angle) * r)
            if i == 0 { path.move(to: p) } else { path.addLine(to: p) }
            let innerAngle = angle + .pi / 5
            let ip = CGPoint(x: c.x + cos(innerAngle) * (r * 0.45), y: c.y + sin(innerAngle) * (r * 0.45))
            path.addLine(to: ip)
        }
        path.closeSubpath()
        return path
    }
}
