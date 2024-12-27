import "./App.css";
import React, { useState } from "react";
import axios from "axios";

const App = () => {
  const [server, setServer] = useState("http://192.168.224.132");
  const [ledState, setLedState] = useState("off");
  const [ledDuration, setLedDuration] = useState(null); // For storing the LED duration
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState("");

  const ledOn = `${server}/H`;
  const ledOff = `${server}/L`;

  // Function to fetch the data from the server
  const fetchData = async () => {
    try {
      setIsLoading(true);
      setError("");
      const response = await axios.get(`${server}/L`);
      const jsonData = response.data; // Get the JSON response
      console.log(jsonData); // Inspect the JSON data
      
      // Update the state based on the JSON response
      setLedState(jsonData.ledState);
      setLedDuration(jsonData.ledDuration);
    } catch (err) {
      setError("Failed to fetch data");
    } finally {
      setIsLoading(false);
    }
  };

  // Function to turn LED ON
  const handleLedOn = async () => {
    setIsLoading(true);
    setError("");
    try {
      await axios.get(ledOn);
      setLedState("on");
    } catch (err) {
      setError("Failed to turn LED on");
    } finally {
      setIsLoading(false);
    }
  };

  // Function to turn LED OFF
  const handleLedOff = async () => {
    setIsLoading(true);
    setError("");
    try {
      await axios.get(ledOff);
      setLedState("off");
    } catch (err) {
      setError("Failed to turn LED off");
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <div className="App">
      <label htmlFor="server">
        Enter the IP:
        <input
          type="text"
          value={server}
          onChange={(e) => setServer(e.target.value)}
          placeholder="http://192.168.1.100"
        />
      </label>

      <br />

      <div className="App">
        <button onClick={handleLedOn} disabled={isLoading}>Turn LED on</button>
        <br />
        <button onClick={handleLedOff} disabled={isLoading}>Turn LED off</button>
        <p>LED is currently {ledState}</p>
        
        <button onClick={fetchData} disabled={isLoading}>Fetch Data</button>
        {isLoading && <p>Loading...</p>}
        
        {ledDuration !== null && <p>LED was ON for {ledDuration} seconds</p>}

        {error && <p style={{ color: 'red' }}>{error}</p>}
      </div>
    </div>
  );
};

export default App;
