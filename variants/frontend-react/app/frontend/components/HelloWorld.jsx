import * as PropTypes from 'prop-types';
import React from 'react';

class HelloWorld extends React.Component {
  render() {
    return <>Greeting: {this.props.greeting}</>;
  }
}

HelloWorld.propTypes = {
  greeting: PropTypes.string.isRequired
};
export default HelloWorld;
