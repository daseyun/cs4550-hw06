import React, { useState } from "react";
// import { ch_change_player_type } from "../socket";
import { player_list, num_players, find_last_winners } from "../utils";

function IsReady({ ready }) {
  return (
    <div>
      <input
        onChange={(ev) => ready(ev)}
        type="checkbox"
        id="isReady"
        value="Ready"
      />
      <label htmlFor="isReady">Ready</label>
    </div>
  );
}

function GameSetup({ leaveGame, appState, ch_ready, ch_change_player_type }) {
  // i.e. a lobby
  let { gameName, userName, playerMap } = appState;
  let playerInfo = appState.playerMap[userName];
  const [state, setState] = useState({
    playerType: playerInfo ? playerInfo[0] : "Observer",
    playerIsReady: false,
  });
  // players individually set whether or not they're ready
  // if a game is started and a player is not ready:
  // wait for remaining player to ready up.
  // observers have no say in starting the game
  let { playerType, playerIsReady } = state;
  let players = player_list(playerMap);
  let prev_winners = find_last_winners(playerMap);

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

  let previousWinners = (<span></span>);

  if (prev_winners != []) {
    previousWinners = (<div>Previous winners: {prev_winners.join(', ')}</div>)
  }

  return (
    <div>
      <div className="row">
        <div className="column">
          <h2>Waiting to start...</h2>
          <h4>Game: {gameName}</h4>
          <div>User: {userName}</div>
          <div>Player Type: {playerType} </div>
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
          <button
            onClick={() => leaveGame()}
          >Leave Game</button>
        </div>
        <div className="column">
          {previousWinners}
          <table>
            <thead>
              <tr>
                {/* table padding */}
                <th> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</th>
                <th>Username</th>
                <th>Playertype</th>
                <th>Ready?</th>
                {/* <th>Won Last Game</th> */}
                <th>Wins</th>
                <th>Losses</th>
              </tr>
            </thead>
            <tbody>
              {Object.keys(playerMap).map((username, idx) => (
                <tr key={idx}>
                  <td>{idx + 1}. </td>
                  <td>{username}</td>
                  <td>{playerMap[username][0]}</td>
                  <td>{playerMap[username][1] ? "✓" : ""}</td>
                  <td>{playerMap[username][3]}</td>
                  <td>{playerMap[username][4]}</td>
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
