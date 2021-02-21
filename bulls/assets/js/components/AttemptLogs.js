import React from "react";

function AttemptLogs(props) {
  let { guesses } = props;

  return (
    <div className="box flex wide center">
      <table>
        <thead>
          <tr>
            {/* table padding */}
            <th> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</th>
            <th>Guess</th>
            <th>Result</th>
          </tr>
        </thead>
        <tbody>
          {Object.keys(guesses).map((obj, idx) => (
            <tr key={idx}>
              <td>{idx + 1}. </td>
              <td>{guesses[obj][0]}</td>
              <td>{guesses[obj][1]}</td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
}

export default AttemptLogs;
