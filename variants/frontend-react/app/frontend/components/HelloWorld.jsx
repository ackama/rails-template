import * as PropTypes from 'prop-types';
import React, { useState } from 'react';

const HelloWorld = ({ initialGreeting }) => {
  const [greeting, setGreeting] = useState(initialGreeting);

  function updateGreeting (event) {
    setGreeting(event.target.value);
  };

  return (
    <>
      <b>{greeting}</b>
      <label htmlFor="greeting-input">
        Change the greeting
        <input id="greeting-input" type="text" onChange={updateGreeting} />
      </label>
    </>
  );
};

HelloWorld.propTypes = {
  initialGreeting: PropTypes.string.isRequired
};

export default HelloWorld;
