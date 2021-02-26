import React, { useState } from "react";

function Login({ ch_login, ch_join }) {
  const [state, setState] = useState({
    gameName: "",
    userName: "",
    join_disable: false
  });

  let { gameName, userName, join_disable } = state;

  function join() {
    ch_join(gameName);
    setState({ ...state, join_disable: true})
  }

  function keyPressJoin(ev) {
    if (ev.key === "Enter") {
      join();
    }
  }

  function keyPressLogin(ev) {
    if (ev.key === "Enter") {
      ch_login(userName);
    }
  }

  return (
    <div>
      <div className="row">
        <div className="column">
          <h1>Bulls and Cows</h1>
        </div>
      </div>
      <div className="row">
        <div className="column">
          <input
            type="text"
            value={gameName}
            onKeyPress={keyPressJoin}
            onChange={(ev) => setState({ ...state, gameName: ev.target.value })}
            placeholder="gamename"
            disabled={join_disable ? "disabled" : ""}
          />
        </div>
        <div className="column">
          <button
            onClick={() => join(gameName)}
            disabled={join_disable ? "disabled" : ""}
          >
            Join
          </button>
        </div>
        <div className="column">
          <input
            type="text"
            value={userName}
            onKeyPress={keyPressLogin}
            onChange={(ev) => setState({ ...state, userName: ev.target.value })}
            placeholder="userName"
            disabled={join_disable ? "" : "disabled"}
          />
        </div>
        <div className="column">
          <button
            onClick={() => ch_login(userName)}
            disabled={join_disable ? "" : "disabled"}
          >
            Login
          </button>
        </div>
      </div>
    </div>
  );
}

export default Login;
