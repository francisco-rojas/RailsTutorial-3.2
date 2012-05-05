module CssUtilities
  RSpec::Matchers.define :have_error_message do |message|
    match do |page|
      page.should have_selector('div.alert.alert-error', text: message)
    end
  end

  RSpec::Matchers.define :have_success_message do |message|
    match do |page|
      page.should have_selector('div.alert.alert-success', text: message)
    end
  end
end