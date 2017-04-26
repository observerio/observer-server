import React from 'react';

class RegisterPage extends React.Component {
    submit(event) {
        event.preventDefault()

        return false
    }

    render() {
        return (
            <div className="mdl-grid">
              <div className="mdl-layout-spacer"></div>
              <form ref="mdl_form" className="mdl-card mdl-shadow--2dp mdl-cell mdl-cell--4-col">
                <div className="mdl-card__supporting-text">
                  <img className="inova-logo" style={{marginBottom: '5px'}} />
                  <h2 className="mdl-card__title-text">Create a New Account</h2>
                  <fieldset className="mdl-textfield mdl-js-textfield mdl-textfield--floating-label mdl-textfield--full-width">
                    <label className="mdl-textfield__label" htmlFor="email">Email address</label>
                    <input ref="email" className="mdl-textfield__input" type="email" name="email" required="true" />
                    <span className="mdl-textfield__error">Please enter a valid email address</span>
                  </fieldset>
                  <fieldset className="mdl-textfield mdl-js-textfield mdl-textfield--floating-label mdl-textfield--full-width">
                    <label className="mdl-textfield__label" htmlFor="password">Password</label>
                    <input ref="password" className="mdl-textfield__input" type="password" name="password" required="true" />
                  </fieldset>
                  <fieldset className="mdl-textfield mdl-js-textfield mdl-textfield--floating-label mdl-textfield--full-width">
                    <label className="mdl-textfield__label" htmlFor="password_confirmation">Password Confirmation</label>
                    <input ref="password_confirmation" className="mdl-textfield__input" type="password" name="password_confirmation" required="true" />
                  </fieldset>

                  <button onClick={this.submit} ref="submit" className="mdl-textfield--full-width mdl-button mdl-js-button mdl-button--raised mdl-button--colored mdl-js-ripple-effect">Sign up</button>
                </div>
              </form>
              <div className="mdl-layout-spacer"></div>
            </div>
        )
    }
}

export default RegisterPage
