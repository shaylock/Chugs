//
//  UIUtilities.swift
//  Chugs
//
//  Created by Shay Blum on 15/11/2025.
//

import SwiftUI
//import CoreHaptics // optional, for haptics if you want

struct PillSlider: View {
    @Binding var value: Double
    let range: ClosedRange<Double>
    let step: Double
    let thumbSize: CGFloat
    let trackHeight: CGFloat
    let thumbColor: Color        // NEW
    let fillColor: Color         // NEW
    let trackColor: Color
    let showValueLabels: Bool

    init(
        value: Binding<Double>,
        range: ClosedRange<Double> = 1...10,
        step: Double = 1,
        thumbSize: CGFloat = 32,
        trackHeight: CGFloat = 8,
        thumbColor: Color = .blue,      // NEW
        fillColor: Color = .blue,       // NEW
        trackColor: Color = Color.gray.opacity(0.25),
        showValueLabels: Bool = false
    ) {
        self._value = value
        self.range = range
        self.step = step
        self.thumbSize = thumbSize
        self.trackHeight = trackHeight
        self.thumbColor = thumbColor
        self.fillColor = fillColor
        self.trackColor = trackColor
        self.showValueLabels = showValueLabels
    }

    var body: some View {
        VStack(spacing: 6) {
            if showValueLabels {
                HStack {
                    Text("\(Int(range.lowerBound))")
                    Spacer()
                    Text("\(Int(range.upperBound))")
                }
                .font(.caption)
                .foregroundColor(.secondary)
            }

            GeometryReader { proxy in
                let totalWidth = proxy.size.width
                let available = max(totalWidth - thumbSize, 1)
                let percent = normalized(value: value)
                let x = available * CGFloat(percent)

                ZStack(alignment: .leading) {
                    // Track background
                    Capsule()
                        .fill(trackColor)
                        .frame(height: trackHeight)

                    // Filled portion of track
                    Capsule()
                        .fill(fillColor)
                        .frame(width: x + thumbSize / 2, height: trackHeight)

                    // Thumb
                    RoundedRectangle(cornerRadius: thumbSize / 2)
                        .fill(thumbColor)            // ← uses thumbColor
                        .frame(width: thumbSize * 1.3,
                               height: thumbSize * 0.65)
                        .shadow(color: Color.black.opacity(0.15),
                                radius: 2, x: 0, y: 1)
                        .offset(x: x)
                        .gesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged { g in
                                    let locationX = g.location.x - thumbSize / 2
                                    let clamped = min(max(locationX / available, 0), 1)
                                    value = denormalized(percent: Double(clamped))
                                }
                                .onEnded { _ in
                                    value = snapped(value: value)
                                }
                        )
                }
            }
            .frame(height: max(thumbSize, 44))
        }
        .padding(.horizontal, 4)
        .environment(\.layoutDirection, .leftToRight)
        .accessibilityValue(Text("\(Int(value))"))
    }

    // Helper functions stay the same…
    private func normalized(value: Double) -> Double {
        (value - range.lowerBound) / (range.upperBound - range.lowerBound)
    }
    private func denormalized(percent: Double) -> Double {
        snappedToStep(range.lowerBound + percent * (range.upperBound - range.lowerBound))
    }
    private func snapped(value: Double) -> Double {
        snappedToStep(value)
    }
    private func snappedToStep(_ v: Double) -> Double {
        guard step > 0 else { return v }
        let steps = round((v - range.lowerBound) / step)
        return min(max(range.lowerBound + steps * step, range.lowerBound), range.upperBound)
    }
}

// TODO: cleanup: remove duplicate
struct PillSlider2: View {
    @Binding var value: Double
    let range: ClosedRange<Double>
    let step: Double
    let thumbSize: CGFloat
    let trackHeight: CGFloat
    let fillColor: Color
    let trackColor: Color
    let showValueLabels: Bool

    init(value: Binding<Double>,
         range: ClosedRange<Double> = 1...10,
         step: Double = 1,
         thumbSize: CGFloat = 32,
         trackHeight: CGFloat = 8,
         fillColor: Color = Color(#colorLiteral(red: 0.0, green: 0.6, blue: 1.0, alpha: 1.0)),
         trackColor: Color = Color.gray.opacity(0.25),
         showValueLabels: Bool = false)
    {
        self._value = value
        self.range = range
        self.step = step
        self.thumbSize = thumbSize
        self.trackHeight = trackHeight
        self.fillColor = fillColor
        self.trackColor = trackColor
        self.showValueLabels = showValueLabels
    }

    var body: some View {
        VStack(spacing: 6) {
            if showValueLabels {
                HStack {
                    Text("\(Int(range.lowerBound))")
                    Spacer()
                    Text("\(Int(range.upperBound))")
                }
                .font(.caption)
                .foregroundColor(.secondary)
            }

            GeometryReader { proxy in
                let totalWidth = proxy.size.width
                let available = max(totalWidth - thumbSize, 1) // space left for thumb travel
                let percent = normalized(value: value)
                let x = available * CGFloat(percent)

                ZStack(alignment: .leading) {
                    // Track background
                    Capsule()
                        .fill(trackColor)
                        .frame(height: trackHeight)

                    // Filled track up to thumb center
                    Capsule()
                        .fill(fillColor)
                        .frame(width: x + thumbSize / 2, height: trackHeight)

                    // Thumb
                    RoundedRectangle(cornerRadius: thumbSize / 2)
                        .fill(fillColor)
                        .frame(width: thumbSize * 1.3, height: thumbSize * 0.65) // pill-shaped thumb
                        .shadow(color: Color.black.opacity(0.15), radius: 2, x: 0, y: 1)
                        .offset(x: x)
                        .gesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged { g in
                                    let locationX = g.location.x - thumbSize / 2
                                    let clamped = min(max(locationX / available, 0), 1)
                                    let newValue = denormalized(percent: Double(clamped))
                                    self.value = newValue
                                }
                                .onEnded { _ in
                                    // Snap to step
                                    self.value = snapped(value: self.value)
                                }
                        )
                }
                .contentShape(Rectangle()) // make track tappable
                .onTapGesture { location in
                    // Tapping the track moves the thumb
                    // SwiftUI's tap doesn't provide location here — use simultaneous gesture if you need exact point.
                    // Simple behavior: toggle to nearest step based on current percent
                    self.value = snapped(value: self.value)
                }
            }
            .frame(height: max(thumbSize, 44)) // ensure enough vertical space for the thumb
        }
        .padding(.horizontal, 4)
        .accessibilityElement(children: .combine)
        .accessibilityValue(Text("\(Int(value))"))
    }

    // Helpers
    private func normalized(value: Double) -> Double {
        guard range.upperBound > range.lowerBound else { return 0 }
        return (value - range.lowerBound) / (range.upperBound - range.lowerBound)
    }

    private func denormalized(percent: Double) -> Double {
        let raw = range.lowerBound + percent * (range.upperBound - range.lowerBound)
        return snappedToStep(raw)
    }

    private func snapped(value: Double) -> Double {
        return snappedToStep(value)
    }

    private func snappedToStep(_ v: Double) -> Double {
        guard step > 0 else { return min(max(v, range.lowerBound), range.upperBound) }
        let steps = round((v - range.lowerBound) / step)
        let snapped = range.lowerBound + steps * step
        return min(max(snapped, range.lowerBound), range.upperBound)
    }
}

struct PillSlider1: View {
    // 1. A state variable to store the slider's value
    @State private var sliderValue: Double = 0.5
    // 2. Define the desired height for the pill shape
    let sliderHeight: CGFloat = 10

    var body: some View {
        VStack {
            Slider(value: $sliderValue, in: 0...1)
                // 3. Customize the appearance using view modifiers
                .background(Capsule().foregroundColor(Color.gray.opacity(0.3)))
                .clipShape(Capsule())
                .frame(height: sliderHeight)
                // 4. Add padding for a better visual fit
                .padding(.horizontal)

            // Optional: Display the current value
            Text("Value: \(sliderValue, specifier: "%.2f")")
                .padding(.top)
        }
    }
}

// Preview provider for Xcode Canvas
#Preview {
    PillSlider(value: Binding<Double>(get: { 4.0 }, set: { _ in }),
               range: 1...10,
               step: 1,
               thumbSize: 48,              // bigger thumb
               trackHeight: 8,
               thumbColor: Color.green,                      // slider button
               fillColor: Color(#colorLiteral(red: 0.0, green: 0.6, blue: 1.0, alpha: 1.0)),  // filled track
               trackColor: Color.gray.opacity(0.3),
               showValueLabels: false)
    PillSlider1()
}
