module FormsUtilities
  def valid_signin(user)
    visit signin_path
    fill_in "Email",    with: user.email
    fill_in "Password", with: user.password
    click_button "Sign in"
    # Sign in when not using Capybara as well. e.g., when submiting put action
    cookies[:remember_token] = user.remember_token
  end

  def valid_signup
    visit signup_path
    fill_in "Name",         with: "Example User"
    fill_in "Email",        with: "user@example.com"
    fill_in "Password",     with: "foobar"
    fill_in "Confirmation", with: "foobar"
  end

  def valid_update(user,new_name, new_email)
    visit edit_user_path(user)
    fill_in "Name",             with: new_name
    fill_in "Email",            with: new_email
    fill_in "Password",         with: user.password
    fill_in "Confirm Password", with: user.password
    click_button "Save changes"
  end

end