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
import socket, {
  guess_join,
  guess_push,
  guess_reset,
  ch_login,
  join_game_channel,
  ch_change_player_type,
  ch_ready,
} from "./socket";
import "phoenix_html";
import React, { useState, useEffect } from "react";
import ReactDOM from "react-dom";
import GameOver from "./components/GameOver";
import AttemptLogs from "./components/AttemptLogs";
import ErrorMessage from "./components/ErrorMessage";
import Login from "./components/Login";
import Controls from "./components/Controls";
import GameSetup from "./components/GameSetup";

function App() {
  const [state, setState] = useState({
    guesses: {},
    gameState: "IN_PROGRESS",
    errorMessage: null,
    name: "",
    userName: "",
    playerMap: {}
  });

  let { userName, guesses, gameState, errorMessage, playerMap } = state;
  let playerType = playerMap && playerMap[state.userName] ? playerMap[state.userName][0] : "Observer";
  // reset the states, effectively starting a new game.
  function reset() {
    guess_reset();
  }

  function login(userName) {
    ch_login(userName);
  }

  function join(gameName) {
    join_game_channel(gameName);
  }

  function ready(userName, playerType) {
    ch_ready(userName, playerType);
  }
  function pass() {
    //IMPL
  }

  useEffect(() => {
    document.title = "Bulls and Cows";
    guess_join(setState);
  }, []);

  let controls = (<div>How are they doing?</div>);
  if (playerType === "Player") {
    controls = (<Controls userName={userName} guess={guess_push} reset={reset} pass={pass} gameState={gameState} />);
  }

  // TODO: refactor into diff file
  let body = null;

  if (!state.userName) {
    body = <Login ch_login={login} ch_join={join} />;
  } else if (state.gameState === "IN_SETUP") {
    body = <GameSetup ch_ready={ch_ready} appState={state} ch_change_player_type={ch_change_player_type}/>;
  } else {
    body = (
      <div>
        <div className="row">
          <h1>Bulls and Cows</h1>
        </div>
        <ErrorMessage error={errorMessage} />
        {controls}
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
      </div>
    );
  }
  return (
    <div className="container">
      {body}
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
