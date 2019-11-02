get "/ex1" do
  begin
    ex1_helper
  rescue NameError
    not_found! "ex1_helper cannot be run"
  end
end

get "/ex2" do
  begin
    ex2_helper
  rescue NameError
    not_found! "ex2_helper cannot be run"
  end
end
