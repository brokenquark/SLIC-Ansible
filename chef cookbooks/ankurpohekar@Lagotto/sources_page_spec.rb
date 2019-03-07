require "rails_helper"

describe "sources", type: :feature, js: true do
  let!(:source) { FactoryGirl.create(:source) }
  let!(:work) { FactoryGirl.create(:work_with_events) }

  it "show summary" do
    visit "/sources"

    expect(page).to have_css "td a", text: "CiteULike"
  end

  it "show works" do
    visit "/sources"
    click_link "Events"

    expect(page).to have_css ".panel-heading", text: "Works with events"
  end

  it "show events" do
    visit "/sources"
    click_link "Events"

    expect(page).to have_css ".panel-heading", text: "Total number of events"
  end
end
