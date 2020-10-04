shared_examples "a performant page", uses_javascript: true do
  it "with a minimum passing score of 95" do
    expect(page).to pass_lighthouse_audit(:performance, score: 95)
  end
end
