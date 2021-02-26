
export function player_list(playerMap) {
    let players = new Map();
    Object.keys(playerMap).map((username, idx) => {
        if (playerMap[username][0] === "Player") {
            players[username] = playerMap[username]
        }
    });
    return players;
}

export function find_last_winners(playerMap) {
    let winners = []
    Object.keys(playerMap).map((username, idx) => {
        if (playerMap[username][2]) {
            winners.push(username)
        }
    });
    return winners;
}