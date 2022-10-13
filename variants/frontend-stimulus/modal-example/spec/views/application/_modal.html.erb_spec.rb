require "rails_helper"

RSpec.describe "application/modal", type: :view do
  it "displays a modal with default args" do
    render "application/modal"
    expect(rendered).to have_selector(".modal .modal-title", text: "")
    expect(rendered).to have_selector(".modal .modal-body", text: "")
    expect(rendered).to have_selector(".modal .modal-footer", text: "")
    expect(rendered).to have_no_selector(".modal.show")
  end

  it "can provide content for different parts of the modal via locals" do
    render "application/modal", modal_title: "Title", modal_body: "Body", modal_footer: "Footer"
    expect(rendered).to have_selector(".modal .modal-title", text: "Title")
    expect(rendered).to have_selector(".modal .modal-body", text: "Body")
    expect(rendered).to have_selector(".modal .modal-footer", text: "Footer")
  end

  it "can provide content for different parts of the modal via content_for" do
    view.provide(:modal_title, "Title")
    view.provide(:modal_footer, "Footer")
    view.provide(:modal_body, "Body")
    render "application/modal"
    expect(rendered).to have_selector(".modal .modal-title", text: "Title")
    expect(rendered).to have_selector(".modal .modal-footer", text: "Footer")
    expect(rendered).to have_selector(".modal .modal-body", text: "Body")
  end

  it "displays a shorter modal header with no title" do
    render "application/modal", modal_title: ""
    expect(rendered).to have_selector(".modal-header.pb-0")
    expect(rendered).to have_selector(".modal-body.pt-0")
  end

  it "can change the size of the modal" do
    render "application/modal", modal_size: :lg
    expect(rendered).to have_selector(".modal-dialog.modal-lg")
  end

  it "can set up a modal to be shown by default" do
    render "application/modal", shown: true
    expect(rendered).to have_selector(".modal.show")
  end
end
