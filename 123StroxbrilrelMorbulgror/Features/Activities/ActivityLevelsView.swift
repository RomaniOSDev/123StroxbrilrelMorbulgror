import SwiftUI

struct ActivityLevelsView: View {
    @EnvironmentObject private var progress: ReferenceProgressStore
    let activity: ReferenceActivity

    var body: some View {
        ZStack {
            ReferenceScreenBackground()
                .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    headerBlock

                    VStack(spacing: 0) {
                        ForEach(ReferenceDifficulty.allCases) { difficulty in
                            DifficultyTrackCard(
                                activity: activity,
                                difficulty: difficulty,
                                progress: progress
                            )
                        }
                    }
                }
                .padding(.horizontal, 18)
                .padding(.vertical, 20)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }

    private var headerBlock: some View {
        VStack(alignment: .leading, spacing: 14) {
            ActivityLevelsHeroIllustration(kind: activity)
                .frame(height: 112)
                .frame(maxWidth: .infinity)

            Text(activity.titleKey)
                .font(.title2.bold())
                .foregroundStyle(Color.appTextPrimary)
                .lineLimit(2)
                .minimumScaleFactor(0.85)

            Text(activity.detail)
                .font(.subheadline)
                .foregroundStyle(Color.appTextSecondary)
                .fixedSize(horizontal: false, vertical: true)

            Text("Choose a track, then open a stage along the route.")
                .font(.footnote.weight(.medium))
                .foregroundStyle(Color.appAccent)
                .padding(.top, 4)
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: ReferenceElevation.panelCorner, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [ReferenceElevation.surfaceGradientTop, ReferenceElevation.surfaceGradientBottom],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: ReferenceElevation.panelCorner, style: .continuous)
                .stroke(
                    LinearGradient(
                        colors: [Color.white.opacity(0.12), Color.appAccent.opacity(0.25)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
        .referenceFloatingShadow(cornerRadius: ReferenceElevation.panelCorner)
    }
}

// MARK: - Difficulty card + level route

private struct DifficultyTrackCard: View {
    let activity: ReferenceActivity
    let difficulty: ReferenceDifficulty
    let progress: ReferenceProgressStore

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 14) {
                DifficultyGlyph(difficulty: difficulty)
                    .frame(width: 48, height: 48)

                VStack(alignment: .leading, spacing: 4) {
                    Text(difficulty.title)
                        .font(.headline)
                        .foregroundStyle(Color.appTextPrimary)
                    Text(trackSubtitle)
                        .font(.caption)
                        .foregroundStyle(Color.appTextSecondary)
                }

                Spacer(minLength: 8)
            }
            .padding(16)

            LevelRouteStrip(activity: activity, difficulty: difficulty, progress: progress)
                .padding(.horizontal, 12)
                .padding(.bottom, 16)
        }
        .background(
            RoundedRectangle(cornerRadius: ReferenceElevation.cardCorner, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [difficultySurfaceOpacity, difficultySurfaceOpacity.opacity(0.92)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: ReferenceElevation.cardCorner, style: .continuous)
                .stroke(
                    LinearGradient(
                        colors: [Color.appAccent.opacity(0.35), Color.appPrimary.opacity(0.12)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
        .referenceFloatingShadow(cornerRadius: ReferenceElevation.cardCorner)
        .padding(.bottom, 12)
    }

    private var trackSubtitle: String {
        switch difficulty {
        case .easy: return "Relaxed pacing and clearer cues."
        case .normal: return "Balanced pace and fewer hints."
        case .hard: return "Tight timers and dense prompts."
        }
    }

    private var difficultySurfaceOpacity: Color {
        switch difficulty {
        case .easy: return Color.appSurface.opacity(0.95)
        case .normal: return Color.appSurface
        case .hard: return Color.appSurface.opacity(1.0)
        }
    }
}

private struct LevelRouteStrip: View {
    let activity: ReferenceActivity
    let difficulty: ReferenceDifficulty
    let progress: ReferenceProgressStore

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            ZStack(alignment: .center) {
                RouteConnectorLine()
                    .stroke(Color.appAccent.opacity(0.35), style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round, dash: [6, 5]))
                    .frame(height: 36)
                    .padding(.horizontal, 24)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(ReferenceLevelIndex.allCases) { level in
                            let unlocked = progress.isLevelUnlocked(activity: activity, difficulty: difficulty, level: level)
                            let stars = progress.stars(for: activity, difficulty: difficulty, level: level)

                            NavigationLink {
                                ActivityPlayFlowView(activity: activity, difficulty: difficulty, level: level)
                            } label: {
                                LevelNodeView(
                                    index: level.rawValue + 1,
                                    unlocked: unlocked,
                                    stars: stars
                                )
                            }
                            .disabled(!unlocked)
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal, 4)
                }
            }

            Text("Stages unlock in order. Earn at least one star to open the next.")
                .font(.caption2)
                .foregroundStyle(Color.appTextSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

/// Subtle wave behind level chips.
private struct RouteConnectorLine: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        let midY = rect.midY
        p.move(to: CGPoint(x: rect.minX, y: midY))
        p.addCurve(
            to: CGPoint(x: rect.maxX, y: midY),
            control1: CGPoint(x: rect.width * 0.35, y: midY - 14),
            control2: CGPoint(x: rect.width * 0.65, y: midY + 14)
        )
        return p
    }
}

private struct LevelNodeView: View {
    let index: Int
    let unlocked: Bool
    let stars: Int

    var body: some View {
        VStack(spacing: 6) {
            ZStack {
                Circle()
                    .fill(
                        unlocked
                            ? LinearGradient(
                                colors: [Color.appPrimary.opacity(0.38), Color.appPrimary.opacity(0.18)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                            : LinearGradient(
                                colors: [Color.appBackground.opacity(0.55), Color.appBackground.opacity(0.4)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                    )
                    .frame(width: 56, height: 56)
                    .overlay(
                        Circle()
                            .stroke(
                                LinearGradient(
                                    colors: unlocked
                                        ? [Color.appAccent, Color.appPrimary.opacity(0.6)]
                                        : [Color.appTextSecondary.opacity(0.35), Color.appTextSecondary.opacity(0.2)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: unlocked ? 2 : 1
                            )
                    )
                    .shadow(color: unlocked ? Color.appAccent.opacity(0.35) : .clear, radius: unlocked ? 8 : 0, y: 4)

                if unlocked {
                    Text("\(index)")
                        .font(.system(.title3, design: .rounded).weight(.bold))
                        .foregroundStyle(Color.appTextPrimary)
                } else {
                    Image(systemName: "lock.fill")
                        .font(.body.weight(.semibold))
                        .foregroundStyle(Color.appTextSecondary)
                }
            }

            HStack(spacing: 2) {
                ForEach(0..<3, id: \.self) { i in
                    Image(systemName: i < stars ? "star.fill" : "star")
                        .font(.system(size: 9))
                        .foregroundStyle(i < stars ? Color.appAccent : Color.appTextSecondary.opacity(0.3))
                }
            }
            .frame(height: 12)

            Text("Stage \(index)")
                .font(.caption2.weight(.medium))
                .foregroundStyle(unlocked ? Color.appTextSecondary : Color.appTextSecondary.opacity(0.6))
        }
        .frame(minWidth: 64)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Stage \(index), \(unlocked ? "unlocked" : "locked"), \(stars) stars")
    }
}

// MARK: - Hero + difficulty glyphs

private struct ActivityLevelsHeroIllustration: View {
    let kind: ReferenceActivity

    var body: some View {
        Canvas { context, size in
            let w = size.width
            let h = size.height
            switch kind {
            case .quickFacts:
                drawMatchCards(&context, w: w, h: h)
            case .recallRace:
                drawLinesAndGap(&context, w: w, h: h)
            case .dataDecode:
                drawBars(&context, w: w, h: h)
            }
        }
    }

    private func drawMatchCards(_ context: inout GraphicsContext, w: CGFloat, h: CGFloat) {
        let cardW = w * 0.22
        let cardH = h * 0.55
        for i in 0..<3 {
            let x = w * 0.12 + CGFloat(i) * (cardW + 10)
            let r = CGRect(x: x, y: h * 0.22, width: cardW, height: cardH)
            var path = Path(roundedRect: r, cornerRadius: 8)
            context.fill(path, with: .color(Color.appPrimary.opacity(0.35)))
            context.stroke(path, with: .color(Color.appAccent.opacity(0.6)), lineWidth: 1.5)
        }
        var arc = Path()
        arc.move(to: CGPoint(x: w * 0.2, y: h * 0.12))
        arc.addQuadCurve(to: CGPoint(x: w * 0.8, y: h * 0.1), control: CGPoint(x: w * 0.5, y: h * 0.02))
        context.stroke(arc, with: .color(Color.appAccent.opacity(0.45)), style: StrokeStyle(lineWidth: 2, lineCap: .round))
    }

    private func drawLinesAndGap(_ context: inout GraphicsContext, w: CGFloat, h: CGFloat) {
        var line = Path()
        line.move(to: CGPoint(x: w * 0.08, y: h * 0.5))
        line.addLine(to: CGPoint(x: w * 0.42, y: h * 0.5))
        context.stroke(line, with: .color(Color.appTextPrimary.opacity(0.5)), lineWidth: 3)
        let gap = CGRect(x: w * 0.44, y: h * 0.38, width: w * 0.14, height: h * 0.26)
        let gapRounded = Path(roundedRect: gap, cornerRadius: 6)
        context.fill(gapRounded, with: .color(Color.appAccent.opacity(0.25)))
        context.stroke(gapRounded, with: .color(Color.appAccent), lineWidth: 2)
        var line2 = Path()
        line2.move(to: CGPoint(x: w * 0.6, y: h * 0.5))
        line2.addLine(to: CGPoint(x: w * 0.92, y: h * 0.5))
        context.stroke(line2, with: .color(Color.appTextPrimary.opacity(0.5)), lineWidth: 3)
    }

    private func drawBars(_ context: inout GraphicsContext, w: CGFloat, h: CGFloat) {
        let vals: [CGFloat] = [0.35, 0.55, 0.28, 0.7, 0.42]
        let barW = w * 0.12
        for (i, v) in vals.enumerated() {
            let x = w * 0.1 + CGFloat(i) * (barW + 8)
            let barH = h * 0.65 * v
            let r = CGRect(x: x, y: h * 0.78 - barH, width: barW, height: barH)
            context.fill(Path(roundedRect: r, cornerRadius: 4), with: .color(Color.appAccent.opacity(0.75)))
        }
        var base = Path()
        base.move(to: CGPoint(x: w * 0.06, y: h * 0.78))
        base.addLine(to: CGPoint(x: w * 0.94, y: h * 0.78))
        context.stroke(base, with: .color(Color.appTextSecondary.opacity(0.4)), lineWidth: 1)
    }
}

private struct DifficultyGlyph: View {
    let difficulty: ReferenceDifficulty

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(gradient)
            Text(letter)
                .font(.system(size: 22, weight: .heavy, design: .rounded))
                .foregroundStyle(Color.appTextPrimary)
        }
        .shadow(color: Color.appPrimary.opacity(0.35), radius: 8, y: 4)
    }

    private var letter: String {
        switch difficulty {
        case .easy: return "E"
        case .normal: return "N"
        case .hard: return "H"
        }
    }

    private var gradient: LinearGradient {
        switch difficulty {
        case .easy:
            return LinearGradient(colors: [Color.appPrimary.opacity(0.45), Color.appAccent.opacity(0.35)], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .normal:
            return LinearGradient(colors: [Color.appAccent.opacity(0.5), Color.appPrimary.opacity(0.4)], startPoint: .leading, endPoint: .trailing)
        case .hard:
            return LinearGradient(colors: [Color.appSurface, Color.appPrimary.opacity(0.55)], startPoint: .top, endPoint: .bottom)
        }
    }
}
