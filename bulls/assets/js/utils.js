
export function player_list(playerMap) {
    let players = new Map();
    Object.keys(playerMap).map((username, idx) => {
        if (playerMap[username][0] === "Player") {
            players[username] = playerMap[username]
        }
    });
    return players;
}
