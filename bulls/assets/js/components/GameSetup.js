import React, { useState } from "react";
// import { ch_change_player_type } from "../socket";
import { player_list, num_players } from "../utils";

function IsReady({ ready }) {
  return (
    <div>
      <input
        onChange={(ev) => ready(ev)}
        type="checkbox"
        id="isReady"
        value="Ready"
      />
      <label htmlFor="isReady">Ready to start</label>
    </div>
  );
}

function GameSetup({ appState, ch_ready, ch_change_player_type }) {
  // i.e. a lobby
  const [state, setState] = useState({
    playerType: "Observer",
    playerIsReady: false,
  });
  // players individually set whether or not they're ready
  // if a game is started and a player is not ready:
  // wait for remaining player to ready up.
  // observers have no say in starting the game
  let { playerType, playerIsReady } = state;
  let { gameName, userName, playerMap } = appState;
  let players = player_list(playerMap);

  function ready(ev) {
    setState({ ...state, playerIsReady: ev.target.checked });
    ch_ready(userName, state.playerType);
  }

  function handleChange(ev) {
    if (players.size > 3 && ev.target.value === "Player") {
      setState({ ...state, playerType: "Observer" });
    } else {
      setState({ ...state, playerType: ev.target.value });
    }
    ch_change_player_type(userName, ev.target.value);
  }

  let readyUp = <div>Please wait for players to start the game.</div>;
  if (state.playerType === "Player") {
    readyUp = <IsReady ready={ready} />;
  }

  return (
    <div>
      Gamesetup
      <div className="row">
        <div className="column">
          <h1>Waiting to start...</h1>
          <div> {gameName}</div>
          <div> {userName}</div>
          <div> playerType: {playerType} </div>
          <label htmlFor="playerType">Are you...</label>
          <select
            id="playerType"
            name="playerType"
            value={playerType}
            onChange={handleChange}
          >
            <option value="Observer">Observer</option>
            <option value="Player">Player</option>
          </select>
          {readyUp}
        </div>
        <div className="column">
          <table>
            <thead>
              <tr>
                {/* table padding */}
                <th> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</th>
                <th>Username</th>
                <th>Playertype</th>
                <th>playerIsReady?</th>
              </tr>
            </thead>
            <tbody>
              {Object.keys(playerMap).map((username, idx) => (
                <tr key={idx}>
                  <td>{idx + 1}. </td>
                  <td>{username}</td>
                  <td>{playerMap[username][0]}</td>
                  <td>{playerMap[username][1] ? "✓" : ""}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
}

export default GameSetup;
