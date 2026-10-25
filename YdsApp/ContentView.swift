//
//  ContentView.swift
//  YdsApp
//
//  Glow Nature Tasarım Sistemi ve YDS/YÖKDİL Çalışma Platformu Ana Kabuğu
//

import Combine
import SwiftUI

public struct QuizResultData: Identifiable, Sendable {
    public let id = UUID()
    public let correctCount: Int
    public let wrongCount: Int
    public let totalCount: Int
}

public struct GlowAppShellView: View {
    @State private var selectedTab: GlowNavTab = .home
    @State private var selectedLesson: LessonItem? = nil
    @State private var activeQuizQuestions: [GlowMockData.MockQuizQuestion]? = nil
    @State private var activeQuizResult: QuizResultData? = nil

    public init() {}

    public var body: some View {
        ZStack(alignment: .bottom) {
            // Ana Sekmeler
            Group {
                switch selectedTab {
                case .home:
                    GlowHomeScreen(
                        lessons: GlowMockData.lessons,
                        onSelectLesson: { lesson in
                            selectedLesson = lesson
                        },
                        onStartPractice: {
                            activeQuizQuestions = GlowMockData.practiceQuestions
                        }
                    )

                case .lessons:
                    GlowLessonsListScreen(
                        lessons: GlowMockData.lessons,
                        onSelectLesson: { lesson in
                            selectedLesson = lesson
                        }
                    )

                case .practice:
                    PracticeQuizScreen(
                        questions: GlowMockData.practiceQuestions,
                        onFinishQuiz: { correct, wrong, total in
                            activeQuizResult = QuizResultData(
                                correctCount: correct,
                                wrongCount: wrong,
                                totalCount: total
                            )
                        }
                    )

                case .vocabulary:
                    WordNotebookScreen(words: GlowMockData.academicWords)

                case .profile:
                    UserProfileScreen()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            // Yüzer Alt Navigasyon (Yalnızca tam ekran quizde değilken göster)
            if activeQuizQuestions == nil && selectedLesson == nil {
                FloatingBottomNav(selectedTab: $selectedTab)
            }
        }
        .preferredColorScheme(.light)
        .sheet(item: $selectedLesson) { lesson in
            NavigationStack {
                LessonDetailScreen(
                    lesson: lesson,
                    onStartPractice: { item, difficulty, count in
                        selectedLesson = nil
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            activeQuizQuestions = Array(GlowMockData.practiceQuestions.prefix(count))
                        }
                    }
                )
            }
        }
        .fullScreenCover(item: Binding<QuizQuestionsWrapper?>(
            get: {
                if let q = activeQuizQuestions {
                    return QuizQuestionsWrapper(questions: q)
                }
                return nil
            },
            set: { wrapper in
                activeQuizQuestions = wrapper?.questions
            }
        )) { wrapper in
            NavigationStack {
                PracticeQuizScreen(
                    questions: wrapper.questions,
                    onFinishQuiz: { correct, wrong, total in
                        activeQuizQuestions = nil
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            activeQuizResult = QuizResultData(
                                correctCount: correct,
                                wrongCount: wrong,
                                totalCount: total
                            )
                        }
                    }
                )
            }
        }
        .fullScreenCover(item: $activeQuizResult) { result in
            NavigationStack {
                QuizResultScreen(
                    correctCount: result.correctCount,
                    wrongCount: result.wrongCount,
                    totalCount: result.totalCount,
                    onReviewMistakes: {
                        activeQuizResult = nil
                        activeQuizQuestions = GlowMockData.practiceQuestions.filter { $0.id == "q_1" || $0.id == "q_2" }
                    },
                    onRetry: {
                        activeQuizResult = nil
                        activeQuizQuestions = GlowMockData.practiceQuestions
                    },
                    onGoHome: {
                        activeQuizResult = nil
                        selectedTab = .home
                    }
                )
            }
        }
    }
}

public struct QuizQuestionsWrapper: Identifiable {
    public let id = UUID()
    public let questions: [GlowMockData.MockQuizQuestion]
}

public struct ContentView: View {
    public let container: AppDependencyContainer

    public init(container: AppDependencyContainer = AppDependencyContainer()) {
        self.container = container
    }

    public var body: some View {
        GlowAppShellView()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
