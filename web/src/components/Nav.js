import React from 'react';
import { NavLink } from 'react-router-dom'

import auth from '../auth.js'

class Nav extends React.Component {
    render() {
        return (
            <div className="android-header mdl-layout__header mdl-layout__header--waterfall">
              <div className="mdl-layout__header-row">
                <span className="android-title mdl-layout-title"></span>
                <div className="android-header-spacer mdl-layout-spacer"></div>
                <div className="android-navigation-container">
                  <nav className="android-navigation mdl-navigation">
                    <NavLink to="/" className="mdl-navigation__link mdl-typography--text-uppercase">
                        Home
                    </NavLink>

                    { auth.isAuthenticated &&
                        <NavLink to="/dashboard" className="mdl-navigation__link mdl-typography--text-uppercase">
                            Dashboard
                        </NavLink> }

                    { !auth.isAuthenticated &&
                        <NavLink to="/signin" className="mdl-navigation__link mdl-typography--text-uppercase">
                            Sign in
                        </NavLink> }
                  </nav>
                </div>
              </div>
            </div>
        )
    }
}

export default Nav
