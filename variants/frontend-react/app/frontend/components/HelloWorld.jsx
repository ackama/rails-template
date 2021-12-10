import * as PropTypes from 'prop-types';
import React from 'react';

const HelloWorld = ({ greeting }) => <>Greeting: {greeting}</>;

HelloWorld.propTypes = {
  greeting: PropTypes.string.isRequired
};

export default HelloWorld;
