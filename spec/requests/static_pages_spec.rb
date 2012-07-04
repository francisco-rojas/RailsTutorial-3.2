require 'spec_helper'

describe "Static pages" do

  subject { page }
  
  shared_examples_for "all static pages" do
    it { should have_selector('h1',    text: heading) }
    it { should have_selector('title', text: full_title(page_title)) }
  end
  
  describe "Home page" do
    before { visit root_path }
    let(:heading)    { 'Sample App' }
    let(:page_title) { '' }

    it_should_behave_like "all static pages"
    it { should_not have_selector 'title', text: '| Home' }  
    
    it "should have the right links on the layout" do
      click_link "About"
      page.should have_selector 'title', text: full_title('About Us')
      click_link "Help"
      page.should have_selector 'title', text: full_title('Help')
      click_link "Contact"
      page.should have_selector 'title', text: full_title('Contact')
      click_link "Home"
      page.should have_selector 'title', text: full_title('')
      click_link "Sign up now!"
      page.should have_selector 'title', text: full_title('Sign up') 
    end        
  end

  describe "Help page" do
    before { visit help_path }
    let(:heading)    { 'Help' }
    let(:page_title) { 'Help' }

    it_should_behave_like "all static pages"
  end

  describe "About page" do
    before { visit about_path }    
    let(:heading)    { 'About' }
    let(:page_title) { 'About Us' }

    it_should_behave_like "all static pages"
  end

  describe "Contact page" do
    before { visit contact_path }
    let(:heading)    { 'Contact' }
    let(:page_title) { 'Contact' }

    it_should_behave_like "all static pages"
  end
  
  describe "for signed-in users" do
    let(:user) { FactoryGirl.create(:user) }
    let(:other_user) { FactoryGirl.create(:user, name: "other_user", email: "other_user@example.com")}
    before do
      FactoryGirl.create(:micropost, user: user, content: "Lorem ipsum")
      FactoryGirl.create(:micropost, user: user, content: "Dolor sit amet")
      FactoryGirl.create(:micropost, user: other_user, content: "this is other_user's post")
      valid_signin user
      visit root_path
    end

    it "should render the user's feed" do
      user.feed.each do |item|
        #Note that the first # in li##{item.id} is Capybara syntax for a CSS id,
        #whereas the second # is the beginning of a Ruby string interpolation #{}
        page.should have_selector("li##{item.id}", text: item.content)
      end
    end
    
    it "should display number of posts with correct pluralization" do
     page.should have_selector 'span', tex: "#{user.microposts.count} microposts"
     expect { click_link('delete') }.to change(user.microposts, :count).by(-1)
     page.should have_selector 'span', tex: "#{user.microposts.count} micropost"
    end
    
    it "should paginate micropost feed" do
      page.should have_selector 'li', class: 'prev previous_page disabled'
    end
    
    it "should list each micropost" do
      user.feed.paginate(page: 1).each do |micropost|
        page.should have_selector('li', text: micropost.content)
      end
    end
    
    #RECHECK THIS TEST
    it "should not have delete link on other user's microposts" do
      other_user.feed.paginate(page: 1).each do |micropost|
        page.should_not have_link('delete', href: "/microposts/#{ micropost.id }"), text: 'delete'
      end
    end
  end
end