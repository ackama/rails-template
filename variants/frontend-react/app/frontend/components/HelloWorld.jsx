import * as PropTypes from 'prop-types';
import React, { useState } from 'react';

const HelloWorld = ({ initialGreeting }) => {
  const [greeting, setGreeting] = useState(initialGreeting);

  const updateGreeting = event => {
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
      <button type="submit" onClick={resetGreeting}>
        Reset
      </button>
    </>
  );
};

HelloWorld.propTypes = {
  initialGreeting: PropTypes.string.isRequired
};

export default HelloWorld;
