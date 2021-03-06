//
//  PromptRevealLetter.swift
//  FourPicturesGuessWord
//
//  Created by Roman Temchenko on 2017-01-31.
//  Copyright © 2017 Temkos. All rights reserved.
//

import Foundation

class PromptRevealLetter {
    
    var getGame: GetGame!
    var saveGame: SaveGame!
    
    struct Result {
        
        var revealedInputLetter: GameLevelEntity.InputLetter
        var affectedInputLetter: GameLevelEntity.InputLetter?
        var revealedLetter: GameLevelEntity.Letter
        var affectedLetter: GameLevelEntity.Letter?
        
    }
    
    func reveal() -> Result {
        let game = self.getGame.get()
        let level = game.currentLevel!
        
        let nextUnrevealedIndex = self.findNextUnrevealedLetterIndex(in: level)
        let nextUnrevealedInputLetter = level.inputLetters[nextUnrevealedIndex]
        let oldTakenLetter = level.letter(for: nextUnrevealedInputLetter)
        let revealedLetter = self.findSuitableLetter(in: level, inputLetterIndex: nextUnrevealedIndex)
        let oldTakenInputLetter = self.findAffectedInputLetter(in: level, revealedLetter: revealedLetter)
        oldTakenInputLetter?.letterIndex = nil
        
        let letterIndex = level.index(of: revealedLetter)
        nextUnrevealedInputLetter.letterIndex = letterIndex
        nextUnrevealedInputLetter.isRevealed = true
        revealedLetter.isSelected = true
        
        self.saveGame.save(game)
        
        return Result(revealedInputLetter: nextUnrevealedInputLetter,
                      affectedInputLetter: oldTakenInputLetter,
                      revealedLetter: revealedLetter,
                      affectedLetter: oldTakenLetter)
    }
    
    fileprivate func findNextUnrevealedLetterIndex(in level: GameLevelEntity) -> Int {
        let nextUnrevealedIndex = level.inputLetters.index(where: { $0.isRevealed == false })!
        return nextUnrevealedIndex
    }
    
    fileprivate func findSuitableLetter(in level: GameLevelEntity, inputLetterIndex: Int) -> GameLevelEntity.Letter {
        let solutionWord = level.solutionWord!
        let character = solutionWord.characters[inputLetterIndex]
        var availableLetters = level.availableLetters!
        var indicesToRemove = IndexSet()
        level.inputLetters.filter({ $0.isRevealed }).forEach({ indicesToRemove.insert($0.letterIndex!) })
        availableLetters.remove(at: indicesToRemove)
        let letter = availableLetters.first(where: { $0.character == character })!
        return letter
    }
    
    fileprivate func findAffectedInputLetter(in level: GameLevelEntity, revealedLetter: GameLevelEntity.Letter) -> GameLevelEntity.InputLetter? {
        let letterIndex = level.index(of: revealedLetter)
        let takenInputLetter = level.inputLetters.first(where: { $0.letterIndex == letterIndex })
        return takenInputLetter
    }
    
}
