import React,{ useState } from "react";
import socket, { join_game_channel, ch_login } from "../socket";

function Login() {
  const [state, setState] = useState({
      gameName: "",
      userName: ""
  });

  let {gameName, userName} = state;


  return (
    <div className="row">
      <div className="column">
        <input
          type="text"
          value={gameName}
          onChange={(ev) => setState({gameName: ev.target.value})}
          placeholder="gamename"
        />
      </div><div className="column">
        <button onClick={() => join_game_channel(gameName)}>Login</button>
      </div>
      <div className="column">
        <input
          type="text"
          value={userName}
          onChange={(ev) => setState({userName: ev.target.value})}
          placeholder="userName"
        />
      </div>
      <div className="column">
        <button onClick={() => ch_login(userName)}>Login</button>
      </div>
    </div>
  );
}

export default Login;
