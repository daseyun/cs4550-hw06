function SetUp({gameName, userName}) {
    


    return (
        <div className="row">
            <div className="column">
                <h1>Waiting to start...</h1>
                <label htmlFor="playerType">Are you...</label>
                <select id="playerType">
                    <option value="Player">Player</option>
                    <option value="Observer">Observer</option> 
                </select>
            </div>
        </div>
    );
}