import SwiftUI

/// Small bespoke icon per activity (SwiftUI shapes only).
struct ReferenceActivityGlyph: View {
    let activity: ReferenceActivity
    var size: CGFloat = 44

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: size * 0.22, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [Color.appPrimary.opacity(0.5), Color.appAccent.opacity(0.35)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            Group {
                switch activity {
                case .quickFacts:
                    Canvas { ctx, s in
                        let w = s.width
                        let h = s.height
                        var a = Path()
                        a.move(to: CGPoint(x: w * 0.28, y: h * 0.72))
                        a.addLine(to: CGPoint(x: w * 0.28, y: h * 0.32))
                        a.addQuadCurve(to: CGPoint(x: w * 0.55, y: h * 0.28), control: CGPoint(x: w * 0.4, y: h * 0.22))
                        a.addLine(to: CGPoint(x: w * 0.72, y: h * 0.36))
                        a.addLine(to: CGPoint(x: w * 0.72, y: h * 0.74))
                        ctx.stroke(a, with: .color(Color.appTextPrimary.opacity(0.9)), lineWidth: 1.8)
                    }
                case .recallRace:
                    Canvas { ctx, s in
                        let w = s.width
                        let h = s.height
                        var line = Path()
                        line.move(to: CGPoint(x: w * 0.2, y: h * 0.52))
                        line.addLine(to: CGPoint(x: w * 0.8, y: h * 0.52))
                        ctx.stroke(line, with: .color(Color.appTextPrimary.opacity(0.9)), lineWidth: 2)
                        let gap = CGRect(x: w * 0.42, y: h * 0.38, width: w * 0.16, height: h * 0.28)
                        ctx.stroke(Path(roundedRect: gap, cornerRadius: 3), with: .color(Color.appAccent), lineWidth: 1.5)
                    }
                case .dataDecode:
                    Canvas { ctx, s in
                        let w = s.width
                        let h = s.height
                        let vals: [CGFloat] = [0.4, 0.65, 0.35, 0.8, 0.5]
                        let bw = w * 0.1
                        for (i, v) in vals.enumerated() {
                            let x = w * 0.15 + CGFloat(i) * (bw + 4)
                            let bh = h * 0.5 * v
                            let r = CGRect(x: x, y: h * 0.72 - bh, width: bw, height: bh)
                            ctx.fill(Path(roundedRect: r, cornerRadius: 2), with: .color(Color.appTextPrimary.opacity(0.92)))
                        }
                    }
                }
            }
            .frame(width: size * 0.62, height: size * 0.62)
        }
        .frame(width: size, height: size)
        .overlay(
            RoundedRectangle(cornerRadius: size * 0.22, style: .continuous)
                .stroke(Color.appTextPrimary.opacity(0.2), lineWidth: 1)
        )
        .shadow(color: Color.appPrimary.opacity(0.28), radius: 8, y: 4)
    }
}
