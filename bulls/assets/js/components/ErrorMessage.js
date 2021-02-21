import React from 'react';


function ErrorMessage(props) {
  let errorBody = <div className="error center">&nbsp;</div>;

  if (props.error) {
    errorBody = <div className="error center">{props.error}</div>;
  }
  return <div className="row">{errorBody}</div>;
}

export default ErrorMessage;
