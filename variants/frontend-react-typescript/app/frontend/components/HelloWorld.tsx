import React, { useState } from 'react';

interface Props {
  initialGreeting: string;
}

export const HelloWorld: React.FC<Props> = ({ initialGreeting }) => {
  const [greeting, setGreeting] = useState(initialGreeting);

  const updateGreeting = (event: React.ChangeEvent<HTMLInputElement>) => {
    setGreeting(event.target.value);
  };

  const resetGreeting = () => {
    setGreeting(initialGreeting);
  };

  return (
    <>
      <b>{greeting}</b>
      <label htmlFor="greeting-input">
        Change the greeting
        <input id="greeting-input" type="text" onChange={updateGreeting} />
      </label>
      <button onClick={resetGreeting}>Reset</button>
    </>
  );
};

export default HelloWorld;
