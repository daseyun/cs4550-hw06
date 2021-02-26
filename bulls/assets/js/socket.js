// notes https://github.com/NatTuck/scratch-2021-01/blob/master/notes-4550/07-phoenix/notes.md#hooking-up-the-browser-end
import { Socket } from "phoenix";

let socket = new Socket("/socket", { params: { token: "" } });
socket.connect();

let state = {
  guesses: {},
  gameState: "IN SETUP",
  errorMessage: null,
  userName: "",
  playerType: "",
  playerMap: {},
  gameName: "",
};

let channel = null;
let callback = null;

function state_update(st) {
  state = st.game;
  if (callback) {
    callback(st);
  }
}

// set the channel with gamename and join.
export function join_game_channel(gameName) {
  channel = socket.channel("game:" + gameName, {});
  join_game();
}

export function guess_join(cb) {
  callback = cb;
  callback(state);
}

export function guess_push(guess, userName) {
  channel
    .push("guess", { guess: guess, userName: userName })
    .receive("ok", state_update)
    .receive("error", (resp) => {
      console.log("Unable to push", resp);
    });
}

export function guess_reset() {
  channel
    .push("reset", {})
    .receive("ok", state_update)
    .receive("error", (resp) => {
      console.log("Unable to reset", resp);
    });
}

export function ch_login(userName) {
  channel
    .push("login", { userName: userName })
    .receive("ok", state_update)
    .receive("error", (resp) => {
      console.log("Unable to login", resp);
    });
}

export function ch_ready(userName, playerType) {
  channel
    .push("ready", { userName: userName, playerType: playerType })
    .receive("ok", state_update)
    .receive("error", (resp) => {
      console.log("Unable to mark self as ready", resp);
    });
}

export function ch_change_player_type(userName, playerType) {
  channel
    .push("changePlayerType", { userName: userName, playerType: playerType })
    .receive("ok", state_update)
    .receive("error", (resp) => {
      console.log("Unable to change player type", resp);
    });
}

// join game. called after gamename is set.
export function join_game() {
  channel
    .join()
    .receive("ok", state_update)
    .receive("error", (resp) => {
      console.log("Unable to join", resp);
    });

  // bind to listen to broadcasts.
  channel.on("view", state_update);
}

export function leave_game(userName) {
  channel
    .push("leaveGame", { userName: userName })
    .receive("ok", state_update)
    .receive("error", (resp) => {
      console.log("Unable to leave", resp);
    });
}

// channel.on("view", test);
// channel.on("view", state_update);
