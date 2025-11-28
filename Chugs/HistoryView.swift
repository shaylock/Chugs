//
//  HistoryView.swift
//  Chugs
//

import SwiftUI
import Charts

enum HistoryTimePeriod: String, CaseIterable, Identifiable {
    case daily = "Daily"
    case weekly = "Weekly"

    var id: String { rawValue }
}

struct HistoryView: View {
    @Environment(\.appTheme) private var theme
    @StateObject private var manager = HydrationManager.shared
    @State private var selectedPeriod: HistoryTimePeriod = .daily
    @Environment(\.colorScheme) private var colorScheme
    private var colorSchemeIsDark: Bool { colorScheme == .dark }


    private let litersPerCup: Double = 0.24   // ~240ml

    var body: some View {
        NavigationStack {
            ZStack {
                theme.background
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 16) {
                        timePeriodToggle

                        waterIntakeCard

                        hydrationTrendCard
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                }
            }
            .navigationTitle("Hydration History")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                manager.fetchHydrationHistory()
            }
        }
    }

    // MARK: - Time period toggle

    private var timePeriodToggle: some View {
        Picker("Time Period", selection: $selectedPeriod) {
            ForEach(HistoryTimePeriod.allCases) { period in
                Text(period.rawValue)
                    .tag(period)
            }
        }
        .pickerStyle(.segmented)
    }

    // MARK: - Water Intake Card

    private var waterIntakeCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Water Intake")
                .font(.headline)
                .foregroundColor(theme.label.opacity(0.7))

            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text(intakeTitleValue)
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(theme.label)

                if let change = dayOverDayChangePercent {
                    Text(String(format: "%+0.0f%%", change))
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(change >= 0 ? .green : .red)
                }
            }

            Text(intakeSubtitle)
                .font(.subheadline)
                .foregroundColor(theme.label.opacity(0.5))

            if selectedPeriod == .daily {
                dailyHourlyChart
                    .frame(height: 180)
                    .padding(.top, 8)
            } else {
                weeklyBarsChart
                    .frame(height: 180)
                    .padding(.top, 8)
            }
        }
        .padding(16)
        .background(cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: Color.black.opacity(0.06), radius: 12, x: 0, y: 4)
    }

    private var intakeTitleValue: String {
        switch selectedPeriod {
        case .daily:
            let cups = manager.todayTotalLiters / litersPerCup
            return "\(Int(round(cups))) cups"
        case .weekly:
            let last7 = last7Days()
            let totalLiters = last7.reduce(0.0) { $0 + $1.totalLiters }
            let cups = totalLiters / litersPerCup
            return "\(Int(round(cups))) cups"
        }
    }

    private var intakeSubtitle: String {
        switch selectedPeriod {
        case .daily:
            return "Today"
        case .weekly:
            return "Last 7 days"
        }
    }

    /// Change vs yesterday (for Daily) or vs previous week (for Weekly).
    private var dayOverDayChangePercent: Double? {
        switch selectedPeriod {
        case .daily:
            return changeTodayVsYesterday()
        case .weekly:
            return manager.last7DayChangePercent
        }
    }

    // MARK: Daily: today vs yesterday

    private func changeTodayVsYesterday() -> Double? {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        guard let yesterday = calendar.date(byAdding: .day, value: -1, to: today) else {
            return nil
        }

        let todayTotal = manager.dailyHistory
            .first(where: { calendar.isDate($0.date, inSameDayAs: today) })?
            .totalLiters ?? manager.todayTotalLiters

        let yesterdayTotal = manager.dailyHistory
            .first(where: { calendar.isDate($0.date, inSameDayAs: yesterday) })?
            .totalLiters ?? 0.0

        guard yesterdayTotal > 0 else { return nil }
        return ((todayTotal - yesterdayTotal) / yesterdayTotal) * 100.0
    }

    // MARK: Charts

    private var dailyHourlyChart: some View {
        AnyView(
            Group {
                if manager.todayHourly.allSatisfy({ $0.totalLiters == 0 }) {
                    emptyChartPlaceholder(text: "No data logged yet today.")
                } else {
                    Chart(manager.todayHourly) { bucket in
                        if bucket.totalLiters > 0 {
                            BarMark(
                                x: .value("Hour", hourLabel(bucket.hour)),
                                y: .value("Cups", bucket.totalLiters / litersPerCup)
                            )
                            .cornerRadius(6)
                            .foregroundStyle(theme.accent)
                        }
                    }
                    .chartXAxis {
                        AxisMarks(values: Array(stride(from: 0, through: 23, by: 4))) { value in
                            if let hour = value.as(Int.self) {
                                AxisValueLabel(hourLabel(hour), centered: true)
                            }
                        }
                    }
                    .chartYAxis {
                        AxisMarks(position: .leading)
                    }
                }
            }
        )
    }

    private var weeklyBarsChart: some View {
        let last7 = last7Days()
        if last7.isEmpty {
            return AnyView(emptyChartPlaceholder(text: "No data for last 7 days."))
        }

        let sorted = last7.sorted(by: { $0.date < $1.date })

        return AnyView(
            Chart(sorted) { day in
                BarMark(
                    x: .value("Day", weekdayShort(for: day.date)),
                    y: .value("Cups", day.totalLiters / litersPerCup)
                )
                .cornerRadius(6)
                .foregroundStyle(theme.accent)
            }
            .chartYAxis {
                AxisMarks(position: .leading)
            }
        )
    }

    // MARK: - Hydration Trend Card (7-day line + area)

    private var hydrationTrendCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Hydration Trend")
                .font(.headline)
                .foregroundColor(theme.label.opacity(0.7))

            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text(String(format: "%.0f%%", manager.last7DayCompletionPercent))
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(theme.label)

                if let change = manager.last7DayChangePercent {
                    Text(String(format: "%+0.0f%%", change))
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(change >= 0 ? .green : .red)
                }
            }

            Text("Last 7 days vs previous week")
                .font(.subheadline)
                .foregroundColor(theme.label.opacity(0.5))

            trendChart
                .frame(height: 200)
                .padding(.top, 8)

            weekdayLabelsRow
        }
        .padding(16)
        .background(cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: Color.black.opacity(0.06), radius: 12, x: 0, y: 4)
    }

    private var trendChart: some View {
        let last7 = last7Days()
        if last7.isEmpty || manager.goalLiters <= 0 {
            return AnyView(emptyChartPlaceholder(text: "Not enough data for trend yet."))
        }

        let sorted = last7.sorted(by: { $0.date < $1.date })

        struct TrendPoint: Identifiable {
            let id = UUID()
            let date: Date
            let completion: Double
        }

        let points: [TrendPoint] = sorted.map { day in
            let pct = min(100.0, (day.totalLiters / manager.goalLiters) * 100.0)
            return TrendPoint(date: day.date, completion: pct)
        }

        return AnyView(
            Chart(points) { point in
                AreaMark(
                    x: .value("Day", point.date),
                    y: .value("Completion", point.completion)
                )
                .foregroundStyle(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            theme.accent.opacity(0.3),
                            theme.accent.opacity(0.0)
                        ]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )

                LineMark(
                    x: .value("Day", point.date),
                    y: .value("Completion", point.completion)
                )
                .lineStyle(.init(lineWidth: 3, lineCap: .round))
                .foregroundStyle(theme.accent)
            }
            .chartXAxis {
                AxisMarks(values: sorted.map(\.date)) { value in
                    if let date = value.as(Date.self) {
                        AxisValueLabel(weekdayShort(for: date))
                    }
                }
            }
            .chartYAxis {
                AxisMarks(position: .leading)
            }
        )
    }

    private var weekdayLabelsRow: some View {
        let last7 = last7Days()
        let sorted = last7.sorted(by: { $0.date < $1.date })

        return HStack {
            ForEach(sorted, id: \.date) { day in
                Text(weekdayShort(for: day.date))
                    .font(.caption.weight(.bold))
                    .foregroundColor(theme.label.opacity(0.6))
                    .frame(maxWidth: .infinity)
            }
        }
        .padding(.top, 4)
    }

    // MARK: - Helpers

    private func last7Days() -> [DailyHydration] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        guard let weekStart = calendar.date(byAdding: .day, value: -6, to: today) else {
            return []
        }

        return manager.dailyHistory.filter { day in
            let d = calendar.startOfDay(for: day.date)
            return d >= weekStart && d <= today
        }
    }

    private func hourLabel(_ hour: Int) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "ha"
        var comps = DateComponents()
        comps.hour = hour
        let date = Calendar.current.date(from: comps) ?? Date()
        return formatter.string(from: date).lowercased()   // "8am", "4pm"
    }

    private func weekdayShort(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"  // Mon, Tue, ...
        return formatter.string(from: date)
    }

    private func emptyChartPlaceholder(text: String) -> some View {
        VStack {
            Spacer()
            Text(text)
                .font(.subheadline)
                .foregroundColor(theme.label.opacity(0.5))
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }

    private var cardBackground: some View {
        ZStack {
            theme.background

            // Subtle "wave" style using radial gradients
            RadialGradient(
                gradient: Gradient(colors: [
                    theme.accent.opacity(0.08),
                    .clear
                ]),
                center: .topLeading,
                startRadius: 10,
                endRadius: 220
            )
            RadialGradient(
                gradient: Gradient(colors: [
                    theme.accent.opacity(0.06),
                    .clear
                ]),
                center: .bottomTrailing,
                startRadius: 10,
                endRadius: 220
            )
        }
    }
}

#Preview {
    HistoryView()
        .appTheme(AppTheme(
            label: Color("Label"),
            background: Color("SystemBackground"),
            accent: Color("AccentColor")
        ))
}
