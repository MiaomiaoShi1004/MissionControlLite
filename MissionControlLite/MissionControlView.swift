import SwiftUI

// MARK: - Justified Row Layout

private struct ImageAspectRatioKey: LayoutValueKey {
    static let defaultValue: CGFloat = 16.0 / 9.0
}

extension View {
    fileprivate func mcAspectRatio(_ ratio: CGFloat) -> some View {
        layoutValue(key: ImageAspectRatioKey.self, value: max(ratio, 0.1))
    }
}

private struct MCJustifiedLayout: Layout {
    var hSpacing: CGFloat = 12
    var vSpacing: CGFloat = 12

    struct Cache {
        var rows: [[Int]] = []
        var rowHeights: [CGFloat] = []
        var itemWidths: [[CGFloat]] = []
        var totalHeight: CGFloat = 0
    }

    func makeCache(subviews: Subviews) -> Cache { Cache() }

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout Cache) -> CGSize {
        let w = proposal.width ?? 800
        build(subviews: subviews, width: w, cache: &cache)
        return CGSize(width: w, height: cache.totalHeight)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize,
                       subviews: Subviews, cache: inout Cache) {
        build(subviews: subviews, width: bounds.width, cache: &cache)
        var y = bounds.minY
        for (ri, row) in cache.rows.enumerated() {
            var x = bounds.minX
            for (ci, si) in row.enumerated() {
                subviews[si].place(
                    at: CGPoint(x: x, y: y),
                    proposal: ProposedViewSize(width: cache.itemWidths[ri][ci],
                                              height: cache.rowHeights[ri])
                )
                x += cache.itemWidths[ri][ci] + hSpacing
            }
            y += cache.rowHeights[ri] + vSpacing
        }
    }

    private func build(subviews: Subviews, width: CGFloat, cache: inout Cache) {
        guard !subviews.isEmpty else { cache = Cache(); return }

        let targetH: CGFloat = 220
        let ars = subviews.map { $0[ImageAspectRatioKey.self] }

        var rows: [[Int]] = []
        var cur: [Int] = []
        for i in 0..<subviews.count {
            cur.append(i)
            let rowW = cur.map { ars[$0] }.reduce(0, +) * targetH
                     + CGFloat(cur.count - 1) * hSpacing
            if rowW > width, cur.count > 1 {
                rows.append(Array(cur.dropLast()))
                cur = [i]
            }
        }
        if !cur.isEmpty { rows.append(cur) }

        var rowHeights: [CGFloat] = []
        var itemWidths:  [[CGFloat]] = []
        for row in rows {
            let sumAR   = row.map { ars[$0] }.reduce(0, +)
            let spacing = CGFloat(row.count - 1) * hSpacing
            let h       = min((width - spacing) / sumAR, targetH * 1.6)
            rowHeights.append(h)
            itemWidths.append(row.map { ars[$0] * h })
        }

        let total = rowHeights.reduce(0, +) + CGFloat(max(0, rows.count - 1)) * vSpacing
        cache = Cache(rows: rows, rowHeights: rowHeights,
                      itemWidths: itemWidths, totalHeight: total)
    }
}

// MARK: - Main View

struct MissionControlView: View {
    var windowManager: WindowManager
    let onDismiss: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.80)
                .ignoresSafeArea()

            if windowManager.isLoading {
                ProgressView().tint(.white).scaleEffect(1.4)
            } else if windowManager.windows.isEmpty {
                emptyState
            } else {
                windowCanvas
            }
        }
        // Tap anywhere on the ZStack that isn't a thumbnail → dismiss
        .contentShape(Rectangle())
        .onTapGesture { onDismiss() }
        .task { await windowManager.refresh() }
    }

    // MARK: - Sub-views

    private var emptyState: some View {
        VStack(spacing: 14) {
            Image(systemName: "square.dashed")
                .font(.system(size: 52))
                .foregroundStyle(.white.opacity(0.35))
            Text("No open windows")
                .font(.title3)
                .foregroundStyle(.white.opacity(0.55))
        }
    }

    private var windowCanvas: some View {
        ScrollView {
            MCJustifiedLayout(hSpacing: 12, vSpacing: 12) {
                ForEach(windowManager.windows) { window in
                    MCWindowThumbnail(
                        window: window,
                        isHovered: windowManager.hoveredWindowID == window.id,
                        onSelect: {
                            windowManager.focusWindow(window)
                            onDismiss()
                        },
                        onClose: {
                            windowManager.closeWindow(window)
                        },
                        onHoverChange: { hovered in
                            windowManager.hoveredWindowID = hovered ? window.id : nil
                        }
                    )
                    .mcAspectRatio(
                        window.frame.height > 0
                            ? window.frame.width / window.frame.height
                            : 16.0 / 9.0
                    )
                }
            }
            .padding(.horizontal, 44)
            .padding(.vertical, 60)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
    }
}
