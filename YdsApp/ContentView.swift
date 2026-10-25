//
//  ContentView.swift
//  YdsApp
//
//  Created by Batuhan Keskin on 24.10.2026.
//

import Combine
import SwiftUI

/// Ana Kabuk Durumu (RootContainerContract - Immutable ViewState)
public struct RootContainerViewState: Equatable, Sendable {
    public let hasCompletedOnboarding: Bool
    public let selectedTab: AppMainTab
    public let isCheckingInitialProfile: Bool

    public init(
        hasCompletedOnboarding: Bool = false,
        selectedTab: AppMainTab = .dashboard,
        isCheckingInitialProfile: Bool = true
    ) {
        self.hasCompletedOnboarding = hasCompletedOnboarding
        self.selectedTab = selectedTab
        self.isCheckingInitialProfile = isCheckingInitialProfile
    }
}

/// Ana Kabuk Kullanıcı Niyetleri (UDF UiEvent)
public enum RootContainerUiEvent: Sendable {
    case onAppear
    case selectTab(AppMainTab)
    case onboardingCompleted
    case onboardingResetRequested
}

@MainActor
public final class RootContainerViewModel: ObservableObject {
    @Published public private(set) var state: RootContainerViewState

    private let userStudyRepository: any UserStudyRepository

    public init(
        container: AppDependencyContainer,
        initialState: RootContainerViewState = RootContainerViewState()
    ) {
        self.state = initialState
        self.userStudyRepository = container.userStudyRepository
    }

    public func onEvent(_ event: RootContainerUiEvent) {
        switch event {
        case .onAppear:
            Task {
                let profile = await userStudyRepository.getUserProfile()
                state = RootContainerViewState(
                    hasCompletedOnboarding: profile.hasCompletedOnboarding,
                    selectedTab: state.selectedTab,
                    isCheckingInitialProfile: false
                )
            }

        case .selectTab(let tab):
            state = RootContainerViewState(
                hasCompletedOnboarding: state.hasCompletedOnboarding,
                selectedTab: tab,
                isCheckingInitialProfile: state.isCheckingInitialProfile
            )

        case .onboardingCompleted:
            state = RootContainerViewState(
                hasCompletedOnboarding: true,
                selectedTab: .dashboard,
                isCheckingInitialProfile: false
            )

        case .onboardingResetRequested:
            state = RootContainerViewState(
                hasCompletedOnboarding: false,
                selectedTab: .dashboard,
                isCheckingInitialProfile: false
            )
        }
    }
}

/// Uygulama Ana Kabuğu: Onboarding <-> 5 Sekmeli Ana TabView Geçişi ve Reçete Yönlendirmesi
public struct RootContainerView: View {
    @StateObject private var rootViewModel: RootContainerViewModel
    @StateObject private var onboardingViewModel: OnboardingViewModel
    @StateObject private var dashboardViewModel: DashboardViewModel
    @StateObject private var sentenceXRayViewModel: SentenceXRayViewModel
    @StateObject private var vocab3DViewModel: Vocab3DViewModel
    @StateObject private var microSprintViewModel: MicroSprintViewModel
    @StateObject private var mistakeVaultViewModel: MistakeVaultViewModel

    public init(container: AppDependencyContainer = AppDependencyContainer()) {
        let rootVM = RootContainerViewModel(container: container)
        _rootViewModel = StateObject(wrappedValue: rootVM)
        _onboardingViewModel = StateObject(
            wrappedValue: OnboardingViewModel(container: container)
        )
        _dashboardViewModel = StateObject(
            wrappedValue: DashboardViewModel(container: container)
        )
        _sentenceXRayViewModel = StateObject(
            wrappedValue: SentenceXRayViewModel(container: container)
        )
        _vocab3DViewModel = StateObject(
            wrappedValue: Vocab3DViewModel(container: container)
        )
        _microSprintViewModel = StateObject(
            wrappedValue: MicroSprintViewModel(container: container)
        )
        _mistakeVaultViewModel = StateObject(
            wrappedValue: MistakeVaultViewModel(container: container)
        )
    }

    public var body: some View {
        let rootState = rootViewModel.state

        Group {
            if rootState.hasCompletedOnboarding {
                mainFiveTabShell(rootState: rootState)
            } else {
                OnboardingScreen(viewModel: onboardingViewModel)
            }
        }
        .preferredColorScheme(.dark)
        .onAppear {
            rootViewModel.onEvent(.onAppear)
        }
        .onChange(of: onboardingViewModel.state.isCompleted) { _, isCompleted in
            if isCompleted {
                rootViewModel.onEvent(.onboardingCompleted)
                dashboardViewModel.onEvent(.onAppear)
            }
        }
        .onChange(of: dashboardViewModel.state.profile.hasCompletedOnboarding) { _, completed in
            if !completed && !rootState.isCheckingInitialProfile {
                rootViewModel.onEvent(.onboardingResetRequested)
            }
        }
        .onChange(of: dashboardViewModel.state.requestedNavigationTab) { _, targetTab in
            guard let targetTab else { return }
            rootViewModel.onEvent(.selectTab(targetTab))
            dashboardViewModel.onEvent(.clearNavigationRequest)
        }
    }

    private func mainFiveTabShell(rootState: RootContainerViewState) -> some View {
        TabView(
            selection: Binding(
                get: { rootState.selectedTab },
                set: { newTab in
                    rootViewModel.onEvent(.selectTab(newTab))
                }
            )
        ) {
            DashboardScreen(viewModel: dashboardViewModel)
                .tabItem {
                    Label(AppMainTab.dashboard.titleTr, systemImage: AppMainTab.dashboard.iconSystemName)
                }
                .tag(AppMainTab.dashboard)

            SentenceXRayScreen(viewModel: sentenceXRayViewModel)
                .tabItem {
                    Label(AppMainTab.sentenceXRay.titleTr, systemImage: AppMainTab.sentenceXRay.iconSystemName)
                }
                .tag(AppMainTab.sentenceXRay)

            Vocab3DScreen(viewModel: vocab3DViewModel)
                .tabItem {
                    Label(AppMainTab.vocab3D.titleTr, systemImage: AppMainTab.vocab3D.iconSystemName)
                }
                .tag(AppMainTab.vocab3D)

            MicroSprintScreen(viewModel: microSprintViewModel)
                .tabItem {
                    Label(AppMainTab.microSprint.titleTr, systemImage: AppMainTab.microSprint.iconSystemName)
                }
                .tag(AppMainTab.microSprint)

            MistakeVaultScreen(viewModel: mistakeVaultViewModel)
                .tabItem {
                    Label(AppMainTab.mistakeVault.titleTr, systemImage: AppMainTab.mistakeVault.iconSystemName)
                }
                .tag(AppMainTab.mistakeVault)
        }
        .tint(AppTheme.emeraldSuccess)
    }
}

public struct ContentView: View {
    private let container: AppDependencyContainer

    public init(container: AppDependencyContainer = AppDependencyContainer()) {
        self.container = container
    }

    public var body: some View {
        RootContainerView(container: container)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
