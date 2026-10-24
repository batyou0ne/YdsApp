import Foundation

/// 3 Boyutlu Kelime ve Edat Tekrar Algoritması (EvaluateVocab3DMasteryUseCase)
/// KURAL: `Vocab3DCard` üç boyutta da (`meaning`, `preposition`, `synonym`) ayrı ayrı doğru cevaplanmadıkça
/// `isFullyLearned` kesinlikle `true` olmaz! Hata yapılan boyut sıfırlanır ve kelime kuyrukta öne çekilir.
public struct EvaluateVocab3DMasteryUseCase: Sendable {
    public init() {}

    public struct EvaluationOutput: Equatable, Sendable {
        public let updatedCard: Vocab3DCard
        public let isDimensionJustMastered: Bool
        public let isCardNowFullyLearned: Bool
        public let scoreDeltaEarned: Double
        public let feedbackMessageTr: String

        public init(
            updatedCard: Vocab3DCard,
            isDimensionJustMastered: Bool,
            isCardNowFullyLearned: Bool,
            scoreDeltaEarned: Double,
            feedbackMessageTr: String
        ) {
            self.updatedCard = updatedCard
            self.isDimensionJustMastered = isDimensionJustMastered
            self.isCardNowFullyLearned = isCardNowFullyLearned
            self.scoreDeltaEarned = scoreDeltaEarned
            self.feedbackMessageTr = feedbackMessageTr
        }
    }

    /// Kullanıcının ilgili boyuttaki (Anlam / Edat / YDS İkizi) cevabını değerlendirir.
    public func evaluateAnswer(
        card: Vocab3DCard,
        dimension: VocabQuizDimension,
        isCorrect: Bool,
        now: Date = Date()
    ) -> EvaluationOutput {
        let current = card.masteryProgress

        var meaningMastered = current.isMeaningMastered
        var prepositionMastered = current.isPrepositionMastered
        var synonymMastered = current.isSynonymMastered

        switch dimension {
        case .meaning:
            meaningMastered = isCorrect
        case .preposition:
            prepositionMastered = isCorrect
        case .synonym:
            synonymMastered = isCorrect
        }

        let newConsecutive = isCorrect ? (current.consecutiveCorrectCount + 1) : 0
        let masteredCount = [meaningMastered, prepositionMastered, synonymMastered].filter { $0 }.count
        let fullyLearned = meaningMastered && prepositionMastered && synonymMastered

        let nextReviewDate: Date
        if !isCorrect {
            // Hata yapıldığında ilgili boyut sıfırlanır ve kelime Spaced Repetition kuyruğunda en öne çekilir!
            nextReviewDate = now
        } else if fullyLearned {
            // 3 boyut da tamamlandıysa 4 gün sonraya planla
            nextReviewDate = now.addingTimeInterval(4 * 24 * 3600)
        } else if masteredCount == 2 {
            // 2 boyut tamamlandıysa 24 saat sonraya planla
            nextReviewDate = now.addingTimeInterval(24 * 3600)
        } else {
            // 1 boyut tamamlandıysa 6 saat sonraya planla
            nextReviewDate = now.addingTimeInterval(6 * 3600)
        }

        let updatedProgress = VocabMasteryProgress(
            isMeaningMastered: meaningMastered,
            isPrepositionMastered: prepositionMastered,
            isSynonymMastered: synonymMastered,
            nextReviewAt: nextReviewDate,
            consecutiveCorrectCount: newConsecutive
        )

        let updatedCard = Vocab3DCard(
            id: card.id,
            headword: card.headword,
            partOfSpeech: card.partOfSpeech,
            track: card.track,
            academicMeaningTr: card.academicMeaningTr,
            mandatoryPreposition: card.mandatoryPreposition,
            ydsTwins: card.ydsTwins,
            meaningDistractorsTr: card.meaningDistractorsTr,
            prepositionDistractors: card.prepositionDistractors,
            twinDistractors: card.twinDistractors,
            examExampleSentenceEn: card.examExampleSentenceEn,
            examExampleSentenceTr: card.examExampleSentenceTr,
            examTipTr: card.examTipTr,
            masteryProgress: updatedProgress
        )

        let scoreDelta: Double
        let feedback: String
        if isCorrect {
            if fullyLearned {
                scoreDelta = 0.15
                feedback = "Tebrikler! '\(card.formattedWithPreposition)' kelimesinin 3 boyutunu da (Anlam + Edat + YDS İkizi) ustalıkla tamamladın (+0.15 puan)!"
            } else {
                scoreDelta = 0.05
                feedback = "\(dimension.titleTr) doğrulandı (\(masteredCount)/3 boyut). Tam ustalık için kalan boyutları tamamla (+0.05 puan)."
            }
        } else {
            scoreDelta = 0.0
            feedback = "Dikkat! \(dimension.titleTr) boyutunda hata yaptığın için bu boyut sıfırlandı ve '\(card.formattedWithPreposition)' tekrar kuyruğunun en önüne çekildi."
        }

        return EvaluationOutput(
            updatedCard: updatedCard,
            isDimensionJustMastered: isCorrect,
            isCardNowFullyLearned: fullyLearned,
            scoreDeltaEarned: scoreDelta,
            feedbackMessageTr: feedback
        )
    }

    /// Kelime kartlarını Spaced Repetition önceliğine göre sıralar (önce tekrar zamanı gelen ve eksik boyutu olanlar).
    public func prioritizeReviewQueue(
        cards: [Vocab3DCard],
        for track: AcademicTrack,
        now: Date = Date()
    ) -> [Vocab3DCard] {
        let filtered: [Vocab3DCard]
        if track == .generalAcademic {
            filtered = cards
        } else {
            let matching = cards.filter { $0.track == track }
            filtered = matching.isEmpty ? cards : matching
        }

        return filtered.sorted { lhs, rhs in
            if lhs.isFullyLearned != rhs.isFullyLearned {
                return !lhs.isFullyLearned && rhs.isFullyLearned
            }
            if lhs.masteryProgress.nextReviewAt != rhs.masteryProgress.nextReviewAt {
                return lhs.masteryProgress.nextReviewAt < rhs.masteryProgress.nextReviewAt
            }
            return lhs.masteryProgress.masteredDimensionCount < rhs.masteryProgress.masteredDimensionCount
        }
    }
}
