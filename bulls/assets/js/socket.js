// notes https://github.com/NatTuck/scratch-2021-01/blob/master/notes-4550/07-phoenix/notes.md#hooking-up-the-browser-end
import {Socket} from "phoenix";

let socket = new Socket("/socket", {params: {token: ""}});
socket.connect();

let channel = socket.channel("game:1", {});

let state = {
  guesses: {},
  gameState: "IN SETUP",
  errorMessage: null,
  userName: "",
  playerType: "",
  playerMap: {}
};

let callback = null;

function state_update(st) {
  // console.log("New state", st);
  state = st.game;
  if (callback) {
    callback(st);
  }
}

// NEW: try to set the channel for game 
export function join_game_channel(gameName) {
  channel = socket.channel("game:" + gameName, {});
  join_game();
}

export function guess_join(cb) {
  // console.log("guess", cb, state)
  callback = cb;
  callback(state);
}

export function gueess_push(guess) {
  // console.log("guessPush", guess)
  channel.push("guess", guess)
         .receive("ok", state_update)
         .receive("error", resp => { console.log("Unable to push", resp) });
}

export function guess_reset() {
  channel.push("reset", {})
         .receive("ok", state_update)
         .receive("error", resp => {
           console.log("Unable to push", resp)
         });
}

export function ch_login(userName) {
  channel.push("login", {userName: userName})
         .receive("ok", state_update)
         .receive("error", resp => {
           console.log("Unable to login", resp)
         });
}

export function ch_ready(userName, playerType) {
  console.log("ch_ready", userName, playerType)
  channel.push("ready", {userName: userName, playerType: playerType})
         .receive("ok", state_update)
         .receive("error", resp => {
           console.log("Unable to login", resp)
         });
}

export function ch_change_player_type(userName, playerType) {
  console.log("changePlayerType", userName, playerType)
  channel.push("ready", {userName: userName, playerType: playerType})
         .receive("ok", state_update)
         .receive("error", resp => {
           console.log("Unable to login", resp)
         });
}

// channel.join()
//        .receive("ok", state_update)
//        .receive("error", resp => { console.log("Unable to join", resp) });

export function join_game() {

channel.join()
       .receive("ok", state_update)
       .receive("error", resp => { console.log("Unable to join", resp) });
}