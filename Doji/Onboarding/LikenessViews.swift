import SwiftUI
import AVFoundation
import UserNotifications

// MARK: - Create your likeness

struct CreateLikenessIntroView: View {
    let onNext: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            ProgressHeader(progress: 0.2, accessory: .help)
            TitleBlock(title: "Create your likeness",
                       subtitle: "Your likeness makes it easy to explore\nnew styles and find clothes you'll love",
                       titleSize: 26)
                .padding(.top, 8)
            AssetImage(name: "likeness_intro", kind: .look)
                .padding(.horizontal, 50)
                .padding(.vertical, 20)
            BottomCTA(title: "Next", action: onNext).padding(.bottom, 16)
        }
        .foregroundStyle(Doji.ink)
    }
}

// MARK: - Take 6 selfies

struct TakeSelfiesView: View {
    let onOpenCamera: () -> Void
    @State private var showTips = false

    var body: some View {
        VStack(spacing: 0) {
            ProgressHeader(progress: 0.4, accessory: .help)
            TitleBlock(title: "Take 6 selfies",
                       subtitle: "Don't worry if they're not perfect,\nwe'll make you look good",
                       titleSize: 26)
                .padding(.top, 8)
            GeometryReader { geo in
                let w = geo.size.width, h = geo.size.height
                ZStack {
                    AssetImage(name: "selfies_model", kind: .look)
                        .frame(width: w * 0.55, height: h * 0.95)
                    // Six face bubbles orbiting the model, as in the reference.
                    ForEach(0..<6, id: \.self) { i in
                        let left = i % 2 == 0
                        let row = CGFloat(i / 2)
                        Avatar(name: "selfie_example_\(i + 1)", size: 58)
                            .overlay(Circle().stroke(.white, lineWidth: 2))
                            .shadow(color: .black.opacity(0.1), radius: 6, y: 2)
                            .position(x: left ? w * 0.17 : w * 0.83,
                                      y: h * (0.15 + row * 0.32) + (left ? 0 : 14))
                    }
                }
            }
            .padding(.vertical, 12)
            BottomCTA(title: "Next") { showTips = true }.padding(.bottom, 16)
        }
        .foregroundStyle(Doji.ink)
        .sheet(isPresented: $showTips) {
            SelfieTipsSheet {
                showTips = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) { onOpenCamera() }
            }
            .presentationDetents([.height(520)])
            .presentationDragIndicator(.visible)
            .presentationCornerRadius(28)
        }
    }
}

/// "For best results" tips. The reference shows three pages; the middle tip was not captured,
/// so the two available tips are recreated.
struct SelfieTipsSheet: View {
    let onOpenCamera: () -> Void
    @State private var page = 0

    private let tips: [(title: String, bad: String, good: String)] = [
        ("Use bright, even lighting", "tip_lighting_bad", "tip_lighting_good"),
        ("Remove glasses and headphones", "tip_glasses_bad", "tip_glasses_good"),
    ]

    var body: some View {
        VStack(spacing: 0) {
            Text("For best results").font(.doji(16)).foregroundStyle(Doji.secondary).padding(.top, 30)
            TabView(selection: $page) {
                ForEach(tips.indices, id: \.self) { i in
                    VStack(spacing: 22) {
                        Text(tips[i].title).font(.doji(23))
                        HStack(spacing: 14) {
                            TipCard(image: tips[i].bad, isGood: false)
                            TipCard(image: tips[i].good, isGood: true)
                        }
                        .padding(.horizontal, 16)
                    }
                    .tag(i)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .padding(.top, 8)

            DashPageIndicator(count: tips.count, index: page).padding(.vertical, 18)

            BottomCTA(title: page == tips.count - 1 ? "Open Camera" : "Next") {
                if page < tips.count - 1 { withAnimation { page += 1 } } else { onOpenCamera() }
            }
            .padding(.bottom, 12)
        }
        .foregroundStyle(Doji.ink)
    }
}

private struct TipCard: View {
    let image: String
    let isGood: Bool

    var body: some View {
        let color = isGood ? Doji.checkGreen : Doji.rejectRed
        AssetImage(name: image, kind: .face, contentMode: .fill)
            .frame(maxWidth: .infinity)
            .frame(height: 170)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(RoundedRectangle(cornerRadius: 16).strokeBorder(color, lineWidth: 3))
            .overlay(alignment: .bottom) {
                Image(systemName: isGood ? "checkmark" : "xmark")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(width: 30, height: 30)
                    .background(color, in: Circle())
                    .offset(y: 15)
            }
            .padding(.bottom, 15)
    }
}

// MARK: - Selfie camera

/// Dark capture screen ("Look straight ahead", lighting indicator, n/6 counter).
/// Shows the live front camera when available; the simulator has no camera and stays black.
struct SelfieCameraView: View {
    let onDone: () -> Void
    @State private var camera = CameraSession()
    @State private var taken = 0
    @State private var flash = false

    /// Only the first pose prompt was captured in the reference; it is reused for every shot.
    private let prompt = "Look straight ahead"
    private let total = 6

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            CameraPreview(session: camera.session).ignoresSafeArea()
            Color.white.opacity(flash ? 0.8 : 0).ignoresSafeArea()

            VStack(spacing: 0) {
                ZStack {
                    LightingPill()
                    HStack {
                        BackButton(color: .white)
                        Spacer()
                        Text("\(min(taken + 1, total))/\(total)")
                            .font(.doji(16))
                            .foregroundStyle(.white)
                            .padding(.trailing, 12)
                    }
                    .padding(.horizontal, 6)
                }
                .frame(height: 50)

                Text(prompt)
                    .font(.doji(28))
                    .foregroundStyle(.white.opacity(0.92))
                    .padding(.top, 6)

                Spacer()

                Button(action: capture) {
                    ZStack {
                        Circle().strokeBorder(.white.opacity(0.85), lineWidth: 3).frame(width: 78, height: 78)
                        Circle().fill(Color(white: 0.45)).frame(width: 64, height: 64)
                    }
                }
                .buttonStyle(.plain)
                .padding(.bottom, 30)
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .onAppear { camera.start() }
        .onDisappear { camera.stop() }
    }

    private func capture() {
        guard taken < total else { return }
        withAnimation(.easeOut(duration: 0.08)) { flash = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
            withAnimation(.easeIn(duration: 0.2)) { flash = false }
        }
        taken += 1
        if taken >= total {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { onDone() }
        }
    }
}

private struct LightingPill: View {
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: "sun.max").font(.system(size: 14, weight: .light))
            Text("Good").font(.doji(16))
        }
        .foregroundStyle(.white)
        .frame(width: 100, height: 34)
        .background(alignment: .leading) {
            Capsule().fill(Doji.goodLight).frame(width: 62)
        }
        .clipShape(Capsule())
        .overlay(Capsule().strokeBorder(.white.opacity(0.35), lineWidth: 1))
    }
}

final class CameraSession {
    let session = AVCaptureSession()
    private let queue = DispatchQueue(label: "doji.camera")
    private var configured = false

    func start() {
        AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
            guard granted, let self else { return }
            self.queue.async {
                if !self.configured {
                    guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front),
                          let input = try? AVCaptureDeviceInput(device: device),
                          self.session.canAddInput(input) else { return }
                    self.session.beginConfiguration()
                    self.session.addInput(input)
                    self.session.commitConfiguration()
                    self.configured = true
                }
                if !self.session.isRunning { self.session.startRunning() }
            }
        }
    }

    func stop() {
        queue.async { [session] in if session.isRunning { session.stopRunning() } }
    }
}

struct CameraPreview: UIViewRepresentable {
    let session: AVCaptureSession

    final class PreviewView: UIView {
        override class var layerClass: AnyClass { AVCaptureVideoPreviewLayer.self }
        var previewLayer: AVCaptureVideoPreviewLayer { layer as! AVCaptureVideoPreviewLayer }
    }

    func makeUIView(context: Context) -> PreviewView {
        let view = PreviewView()
        view.backgroundColor = .black
        view.previewLayer.session = session
        view.previewLayer.videoGravity = .resizeAspectFill
        return view
    }

    func updateUIView(_ uiView: PreviewView, context: Context) {}
}

// MARK: - Notifications prompt

struct LikenessNotificationsView: View {
    let onNext: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            ProgressHeader(progress: 0.7, accessory: .skip(onNext))
            // The six selfies and two full-length photos that feed the likeness.
            VStack(spacing: 14) {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 14), count: 3), spacing: 14) {
                    ForEach(0..<6, id: \.self) { _ in Circle().fill(Doji.ink).aspectRatio(1, contentMode: .fit) }
                }
                HStack(spacing: 14) {
                    ForEach(0..<2, id: \.self) { _ in RoundedRectangle(cornerRadius: 18).fill(Doji.ink) }
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 14)

            Text("Turn on notifications to know\nwhen your likeness is ready")
                .font(.doji(21))
                .multilineTextAlignment(.center)
                .padding(.vertical, 28)

            BottomCTA(title: "Enable Notifications") {
                Task {
                    _ = try? await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound])
                    await MainActor.run { onNext() }
                }
            }
            .padding(.bottom, 16)
        }
        .foregroundStyle(Doji.ink)
    }
}
