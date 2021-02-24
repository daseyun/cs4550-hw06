import React,{ useState } from "react";

function Login({ch_login, ch_join}) {
  const [state, setState] = useState({
      gameName: "",
      userName: "",
  });

  let {gameName, userName, playerType} = state;

  return (
    <div>
    <div className="row">
      <div className="column">
        <input
          type="text"
          value={gameName}
          onChange={(ev) => setState({gameName: ev.target.value})}
          placeholder="gamename"
        />
      </div><div className="column">
        <button onClick={() => ch_join(gameName)}>Join</button>
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
    </div>
  );
}

export default Login;
