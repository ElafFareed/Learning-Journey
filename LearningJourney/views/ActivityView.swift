
import SwiftUI
import Combine

struct ActivityView: View {

    @StateObject private var viewModel: ActivityViewModel

    @Environment(\.scenePhase) private var scenePhase

    var onCalendar: () -> Void = {}
    var onEditGoal: () -> Void = {}
    var onSetGoal: () -> Void = {}

    init(
        goal: LearningGoal,
        onCalendar: @escaping () -> Void = {},
        onEditGoal: @escaping () -> Void = {},
        onSetGoal: @escaping () -> Void = {}
    ) {
        _viewModel = StateObject(
            wrappedValue: ActivityViewModel(goal: goal)
        )

        self.onCalendar = onCalendar
        self.onEditGoal = onEditGoal
        self.onSetGoal = onSetGoal
    }

    var body: some View {

        GeometryReader { geometry in

            ScrollView {

                VStack(spacing: 0) {

                    // MARK: - Header

                    HStack(alignment: .top, spacing: 0) {

                        JourneyToolbarTitle(
                            title: "Activity",
                            subtitle: viewModel.today.formatted(
                                .dateTime
                                    .weekday(.wide)
                                    .day()
                                    .month(.wide)
                            ),
                            subtitleFont: .system(
                                size: 17,
                                weight: .regular
                            )
                        )

                        Spacer(minLength: 8)

                        HStack(spacing: 12) {

                            Button(action: onCalendar) {
                                JourneyCircleIconButton(
                                    symbol: "calendar"
                                )
                            }

                            Button(action: onEditGoal) {
                                JourneyCircleIconButton(
                                    symbol: "square.and.pencil"
                                )
                            }
                        }
                        .buttonStyle(.plain)
                    }
                    .frame(height: 73, alignment: .top)
                    .padding(.top, 12)

                    // MARK: - Weekly Calendar

                    JourneyWeekRow(
                        days: viewModel.weekDayNumbers,
                        styles: viewModel.weekDayStyles
                    )
                    .padding(.top, 12)

                    // MARK: - Statistics

                    HStack(spacing: 12) {

                        JourneyStatsCard(
                            title: "Learned",
                            count: viewModel.learnedDays,
                            symbol: "flame.fill",
                            color: JourneyColor.orange
                        )

                        JourneyStatsCard(
                            title: "Frozen",
                            count: viewModel.frozenDays,
                            symbol: "snowflake",
                            color: JourneyColor.cyan
                        )
                    }
                    .padding(.top, 12)

                    Spacer(minLength: 36)

                    // MARK: - Daily Action

                    if viewModel.goalIsActive {

                        Button {
                            viewModel.logLearningToday()
                        } label: {

                            JourneyLearningButton(
                                isLogged: viewModel.todayStatus == .learned,
                                isEnabled: viewModel.todayStatus != .learned
                            )                        }
                        .buttonStyle(.plain)
                        .disabled(!viewModel.canLogToday)
                        .frame(maxWidth: .infinity)

                    
                    
                    } else {

                        VStack(spacing: 90) {

                            JourneyGoalResult(
                                isCompleted: viewModel.learnedDays
                                    + viewModel.frozenDays >= requiredDays
                            )

                            Button(action: onSetGoal) {

                                Label("Set a goal", systemImage: "scope")
                                    .font(JourneyFont.buttonLabel)
                                    .foregroundStyle(JourneyColor.text)
                                    .frame(height: 50)
                                    .padding(.horizontal, 18)
                                    .background(
                                        JourneyColor.orange,
                                        in: Capsule()
                                    )
                            }
                            .buttonStyle(.plain)
                        }
                        .frame(maxWidth: .infinity)
                    }



                    Spacer(minLength: 36)

                    // MARK: - Freeze Action

                    if viewModel.goalIsActive {

                        VStack(spacing: 16) {

                            Button {
                                viewModel.freezeToday()
                            } label: {

                                JourneyFreezeButton(
                                    isFrozen: viewModel.todayStatus == .frozen,
                                    isEnabled: viewModel.todayStatus != .frozen
                                        && viewModel.frozenDays < viewModel.freezeLimit
                                )                            }
                            .buttonStyle(.plain)
                            .disabled(!viewModel.canFreezeToday)

                            Text(
                                "\(viewModel.frozenDays) out of \(viewModel.freezeLimit) Freezes used"
                            )
                            .font(
                                .system(
                                    size: 14,
                                    weight: .regular
                                )
                            )
                            .foregroundStyle(
                                JourneyColor.secondaryText
                            )
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 28)
                .frame(
                    minHeight: geometry.size.height,
                    alignment: .top
                )
                .frame(maxWidth: .infinity)
            }
            .scrollIndicators(.hidden)
        }
        .background(JourneyColor.background)
        .navigationBarBackButtonHidden()
        .onAppear {
            viewModel.refreshDay()
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                viewModel.refreshDay()
            }
        }
        .onReceive(
            Timer.publish(
                every: 60,
                on: .main,
                in: .common
            ).autoconnect()
        ) { _ in
            viewModel.refreshDay()
        }
    }

    // MARK: - Required Days

    private var requiredDays: Int {

        let calendar = Calendar.current

        let start = calendar.startOfDay(
            for: viewModel.goal.createdAt
        )

        return calendar.dateComponents(
            [.day],
            from: start,
            to: viewModel.goalEndDate
        ).day ?? 0
    }
}
