import React from 'react';
import Nav from '../components/Nav.js'


class App extends React.Component {
  render() {
    return (
        <div>
            <Nav></Nav>

            {this.props.children}
        </div>
    );
  }
}

export default App;
