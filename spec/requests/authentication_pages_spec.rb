require 'spec_helper'

describe "AuthenticationPages" do
  subject { page }

  describe "signin page" do
    before { visit signin_path }

    it { should have_selector('h1',    text: 'Sign in') }
    it { should have_selector('title', text: 'Sign in') }
  end

  describe "signin" do
    
    describe "with invalid information" do
      before do
        visit signin_path 
        click_button "Sign in"
      end

      it { should have_selector('title', text: 'Sign in') }
      it { should have_error_message('Invalid') } #check utilities
      #it { should have_selector('div.alert.alert-error', text: 'Invalid') }

      describe "after visiting another page" do
        before { click_link "Home" }
        it { should_not have_error_message('Invalid') }
      end
    end

    describe "with valid information" do
      let(:user) { FactoryGirl.create(:user) }
      before do
        valid_signin(user) #check utilities
      end

      it { should have_selector('title', text: user.name) }
      it { should have_link('Users',    href: users_path) }
      it { should have_link('Profile', href: user_path(user)) }
      it { should have_link('Settings', href: edit_user_path(user)) }
      it { should have_link('Sign out', href: signout_path) }
      it { should_not have_link('Sign in', href: signin_path) }

      describe "followed by signout" do
        before { click_link "Sign out" }
        it { should have_link('Sign in') }
      end
    end
  end
  
  describe "authorization" do

    describe "for non-signed-in users" do
      let(:user) { FactoryGirl.create(:user) }

      describe "in the Users controller" do

        describe "visiting the edit page" do
          before { visit edit_user_path(user) }
          it { should have_selector('title', text: 'Sign in') }
        end

        describe "submitting to the update action" do
          before { put user_path(user) } #submits a PUT action, see listing 9.11
          specify { response.should redirect_to(signin_path) }
        end
        
        describe "visiting the user index" do
          before { visit users_path }
          it { should have_selector('title', text: 'Sign in') }
        end
        
        describe "should not have links to protected pages" do
          before { visit signin_path }
          it { should have_selector('title', text: 'Ruby on Rails Tutorial Sample App') }
          it { should have_link('Home', href: root_path) }
          it { should have_link('Sign in', href: signin_path) }
          it { should have_link('Help', href: help_path) }
          it { should_not have_link('Profile', href: user_path(user)) }
          it { should_not have_link('Settings', href: edit_user_path(user)) }
          it { should_not have_link('Sign out', href: signout_path) }          
        end
        
        describe "visiting the following page" do
          before { visit following_user_path(user) }
          it { should have_selector('title', text: 'Sign in') }
        end

        describe "visiting the followers page" do
          before { visit followers_user_path(user) }
          it { should have_selector('title', text: 'Sign in') }
        end
      end
      
      describe "when attempting to visit a protected page" do
        before do
          visit edit_user_path(user)
          fill_in "Email",    with: user.email
          fill_in "Password", with: user.password
          click_button "Sign in"
        end

        describe "after signing in" do
          it "should render the desired protected page" do
            page.should have_selector('title', text: 'Edit user')
          end
          
          describe "after signing in again" do
            before do
              click_link "Sign out"
              valid_signin(user)
            end
            it "should NOT render previously saved page" do
              page.should have_selector('title', text: user.name)
            end
          end
        end
      end
      
      describe "as non-admin user" do
        let(:user) { FactoryGirl.create(:user) }
        let(:non_admin) { FactoryGirl.create(:user) }  
        before { valid_signin non_admin }
  
        describe "submitting a DELETE request to the Users#destroy action" do
          before { delete user_path(user) }
          specify { response.should redirect_to(root_path) }        
        end
      end
    end
    
    describe "for signed in users" do
      let(:user) { FactoryGirl.create(:user) }
      before { valid_signin user }
      
      describe "for new action" do
         #"visit signup_path" won't work.Capybara can not assign anything to the
         #@request variable after "visit" because it gets redirected which is what we want
         #use rails "get" method instead 
        before { get signup_path }
        specify { response.should redirect_to(root_path) }
      end
      
      describe "for create action" do
        before do          
          new_user = User.new(name: "user1", email: "user1@example.com", 
                            password: "foobar", password_confirmation: "foobar")
          post users_path(new_user)
        end
        specify { response.should redirect_to(root_path) }
      end
    end
    
    describe "as wrong user" do
      let(:user) { FactoryGirl.create(:user) }
      let(:wrong_user) { FactoryGirl.create(:user, email: "wrong@example.com") }
      before { valid_signin(user) }

      describe "visiting Users#edit page" do
        before { visit edit_user_path(wrong_user) }
        it { should_not have_selector('title', text: full_title('Edit user')) }
      end

      describe "submitting a PUT request to the Users#update action" do
        before { put user_path(wrong_user) }
        specify { response.should redirect_to(root_path) }
      end
    end
    
    describe "in the Microposts controller" do

      describe "submitting to the create action" do
        before { post microposts_path }
        specify { response.should redirect_to(signin_path) }
      end

      describe "submitting to the destroy action" do
        before { delete micropost_path(FactoryGirl.create(:micropost)) }
        specify { response.should redirect_to(signin_path) }
      end
    end
  end  
end
