import React from 'react'
import { NavLink, Redirect } from 'react-router-dom'
import auth from '../auth.js'

class LoginPage extends React.Component {
    state = {
        redirectToReferrer: false
    }

    submit(event) {
        event.preventDefault()

        auth.isAuthenticated = true
        this.setState({ redirectToReferrer: true })

        return false
    }

    render() {
        const { from } = this.props.location.state || { from: { pathname: '/dashboard' } }
        const { redirectToReferrer } = this.state

        if (redirectToReferrer) {
            return (
                <Redirect to={from}/>
            )
        }

        return (
            <div className="mdl-grid">
              <div className="mdl-layout-spacer"></div>
              <form ref="mdl_form" className="mdl-card mdl-shadow--2dp mdl-cell mdl-cell--4-col">
                <div className="mdl-card__supporting-text">
                  <img className="inova-logo" style={{marginBottom: '5px'}} />
                  <h2 className="mdl-card__title-text">Sign in</h2>
                  <fieldset className="mdl-textfield mdl-js-textfield mdl-textfield--floating-label mdl-textfield--full-width">
                    <label className="mdl-textfield__label" htmlFor="email">Email address</label>
                    <input ref="email" className="mdl-textfield__input" type="email" name="email" required="true" />
                    <span className="mdl-textfield__error">Please enter a valid email address</span>
                  </fieldset>
                  <fieldset className="mdl-textfield mdl-js-textfield mdl-textfield--floating-label mdl-textfield--full-width">
                    <label className="mdl-textfield__label" htmlFor="password">Password</label>
                    <input ref="password" className="mdl-textfield__input" type="password" name="password" required="true" />
                    <span className="mdl-textfield__error">The password was incorrect did you <a href="#">forgot your password?</a></span>
                  </fieldset>

                  <button onClick={this.submit.bind(this)} ref="submit" className="mdl-textfield--full-width mdl-button mdl-js-button mdl-button--raised mdl-button--colored mdl-js-ripple-effect">Sign In</button>

                  <br/><br/>
                  <a href="#">forgot your password?</a>
                  <hr/>

                  <NavLink to="/signup" className="mdl-textfield--full-width mdl-button mdl-button--raised ">
                      Sign up
                  </NavLink>
                </div>
              </form>
              <div className="mdl-layout-spacer"></div>
            </div>
        )
    }
};

export default LoginPage;
