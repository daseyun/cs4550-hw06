import React from 'react';

function GameOver(props) {
  let gameProgress = <h1> &nbsp;</h1>;
  if (props.gameState === "WIN") {
    gameProgress = <h1>You Win!</h1>;
  } else if (props.gameState === "LOSE") {
    gameProgress = <h1>You Lose!</h1>;
  }

  return <div>{gameProgress}</div>;
}

export default GameOver;
