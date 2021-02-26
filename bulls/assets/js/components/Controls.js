import React, { useState } from "react";

function Controls({guess, reset, pass, gameState, userName}) {
    const [uiState, setUiState] = useState({
        attempt: "",
      });
    
    let { attempt } = uiState;

  function handleInput() {
    try {
      guess(attempt, userName);
      setUiState({
        attempt: "",
      });
    } catch (error) {
      // clear input for invalid inputs as well
      setUiState({ attempt: "" });
    }
  }

  // update attempt as input changes.
  function handleInputChange(e) {
    setUiState({ attempt: e.target.value });
  }

   // handle enter to "guess" in input.
  // https://github.com/NatTuck/scratch-2021-01/blob/bea430447baec22eb1a5e41d4d1fcce0191b36a3/4550/0202/hangman/src/App.js#L58
  function keyPress(ev) {
    if (ev.key === "Enter") {
      handleInput();
    }
  }

  function pass() {
    guess("PASS", userName);
    setUiState({
      attempt: "",
    });
  }

  return (<div className="row box flex">
  <input
    id="numberInput"
    type="number"
    onKeyPress={keyPress}
    onChange={handleInputChange}
    value={attempt}
    disabled={gameState !== "IN_PROGRESS" ? "disabled" : ""}
    placeholder="1234"
  ></input>
  <button
    disabled={gameState !== "IN_PROGRESS" ? "disabled" : ""}
    onClick={() => handleInput()}>
    Guess
  </button>
  <button className="button button-outline" onClick={() => reset()}>
    Reset
  </button>
  <button className="button button-outline" onClick={() => pass()}>
    Pass
  </button>
  
</div>);
}

export default Controls;
