// We need to import the CSS so that webpack will load it.
// The MiniCssExtractPlugin is used to separate it out into
// its own CSS file.
import "../css/app.scss";

// webpack automatically bundles all modules in your
// entry points. Those entry points can be configured
// in "webpack.config.js".
//
// Import deps with the dep name or local files with a relative path, for example:
//
import { Socket } from "phoenix";
import socket, { guess_join, guess_push, guess_reset } from "./socket";
import "phoenix_html";
import React, { useState, useEffect } from "react";
import ReactDOM from "react-dom";
import GameOver from "./components/GameOver";
import AttemptLogs from "./components/AttemptLogs";
import ErrorMessage from "./components/ErrorMessage";

function App() {
  const [uiState, setUiState] = useState({
    attempt: "",
  });
  const [state, setState] = useState({
    guesses: {},
    gameState: "IN_PROGRESS",
    errorMessage: null,
  });

  let { attempt } = uiState;
  let { guesses, gameState, errorMessage } = state;

  function handleInput() {
    try {
      guess_push(attempt);
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

  // reset the states, effectively starting a new game.
  function reset() {
    guess_reset();
    setUiState({
      attempt: "",
    });
  }

  // handle enter to "guess" in input.
  // https://github.com/NatTuck/scratch-2021-01/blob/bea430447baec22eb1a5e41d4d1fcce0191b36a3/4550/0202/hangman/src/App.js#L58
  function keyPress(ev) {
    if (ev.key === "Enter") {
      handleInput();
    }
  }

  useEffect(() => {
    document.title = "Bulls and Cows";
    guess_join(setState);
  }, []);

  return (
    <div className="container">
      <div className="row">
        <h1>Bulls and Cows</h1>
      </div>
      <ErrorMessage error={errorMessage} />
      <div className="row box flex">
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
          onClick={() => handleInput()}
        >
          Guess
        </button>
        <button className="button button-outline" onClick={() => reset()}>
          Reset
        </button>
      </div>
      <div className="row">
        <AttemptLogs guesses={guesses} />
      </div>
      <div className="row">
        <GameOver gameState={gameState} />
      </div>
      <a
        href="https://en.wikipedia.org/wiki/Bulls_and_Cows"
        rel="noreferrer"
        target="_blank"
      >
        Bulls and Cows (Wikipedia)
      </a>
      <br />
      <a href="http://danyun.me">danyun.me</a>
    </div>
  );
}

ReactDOM.render(
  <React.StrictMode>
    <App />
  </React.StrictMode>,
  document.getElementById("root")
);
