import SwiftUI

/// Window thumbnail — bare screenshot + bottom label + red ✕ on hover.
/// Hover state is owned by the parent so `Cmd+W` can close the focused window.
struct MCWindowThumbnail: View {
    let window: WindowInfo
    let isHovered: Bool
    let onSelect: () -> Void
    let onClose: () -> Void
    let onHoverChange: (Bool) -> Void

    var body: some View {
        ZStack(alignment: .topLeading) {

            // ── Screenshot ────────────────────────────────────────────────
            screenshotView
                .overlay(alignment: .bottom) { bottomLabel }
                .clipShape(RoundedRectangle(cornerRadius: 10))
                // White border appears on hover — exactly like Mission Control
                .overlay {
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(.white.opacity(isHovered ? 0.9 : 0), lineWidth: 3)
                }
                .shadow(color: .black.opacity(0.55), radius: 14, y: 6)
                .scaleEffect(isHovered ? 1.025 : 1.0)
                .contentShape(Rectangle())
                .onTapGesture { onSelect() }
                .onHover { onHoverChange($0) }

            // ── Red ✕ — top-left corner, Mission Control Plus style ───────
            if isHovered {
                Button(action: onClose) {
                    Circle()
                        .fill(Color(nsColor: .systemRed))
                        .frame(width: 22, height: 22)
                        .overlay {
                            Image(systemName: "xmark")
                                .font(.system(size: 9, weight: .heavy))
                                .foregroundStyle(.white)
                        }
                        .shadow(color: .black.opacity(0.4), radius: 3, y: 1)
                }
                .buttonStyle(.plain)
                .offset(x: -8, y: -8)
                .transition(.scale(scale: 0.3).combined(with: .opacity))
            }
        }
        // Fill the rectangle the layout allocates for this cell
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .animation(.spring(response: 0.16, dampingFraction: 0.7), value: isHovered)
    }

    // MARK: - Screenshot

    @ViewBuilder
    private var screenshotView: some View {
        if let thumb = window.thumbnail {
            Image(nsImage: thumb)
                .resizable()
                .scaledToFill()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .clipped()
        } else {
            Rectangle()
                .fill(Color.white.opacity(0.07))
                .overlay {
                    if let icon = window.appIcon {
                        Image(nsImage: icon).resizable().frame(width: 52, height: 52)
                    }
                }
        }
    }

    // MARK: - Bottom label (gradient + app name, like Mission Control)

    private var bottomLabel: some View {
        ZStack(alignment: .bottomLeading) {
            LinearGradient(
                colors: [.clear, .black.opacity(0.72)],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 54)

            HStack(spacing: 5) {
                if let icon = window.appIcon {
                    Image(nsImage: icon).resizable().frame(width: 15, height: 15)
                }
                Text(window.title.isEmpty ? window.appName : window.title)
                    .font(.system(size: 11.5, weight: .medium))
                    .foregroundStyle(.white)
                    .shadow(color: .black, radius: 2)
                    .lineLimit(1)
            }
            .padding(.horizontal, 9)
            .padding(.bottom, 8)
        }
    }
}
