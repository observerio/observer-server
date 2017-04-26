/* eslint-disable import/default */

import React from 'react'
import {
  BrowserRouter as Router,
  Route,
  Redirect,
} from 'react-router-dom'

import { render } from 'react-dom'
import injectTapEventPlugin from 'react-tap-event-plugin'
require('./favicon.ico')

import './material.css'
import './styles.css'

import 'font-awesome/css/font-awesome.css'
import 'flexboxgrid/css/flexboxgrid.css'

injectTapEventPlugin();

import App from './containers/App'
import LoginPage from './containers/LoginPage'
import RegisterPage from './containers/RegisterPage'
import MainPage from './containers/MainPage'
import DashboardPage from './containers/DashboardPage'

import auth from './auth.js'

const PrivateRoute = ({ component: Component, ...rest }) => (
  <Route {...rest} render={props => (
    auth.isAuthenticated ? (
      <Component {...props}/>
    ) : (
      <Redirect to={{
        pathname: '/signin',
        state: { from: props.location }
      }}/>
    )
  )}/>
)

render((
    <Router>
        <div className="mdl-layout mdl-js-layout mdl-layout--fixed-header">
            <App>
                <div>
                    <Route path="/signin" component={LoginPage}/>
                    <Route path="/signup" component={RegisterPage}/>
                    <Route exact path="/" component={MainPage}/>

                    <PrivateRoute path="/dashboard" component={DashboardPage} />
                </div>
            </App>
        </div>
    </Router>
), document.getElementById('root'));
