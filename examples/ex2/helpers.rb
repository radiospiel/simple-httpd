get "/ex1" do
  ex1_helper
rescue NameError
  not_found! "ex1_helper cannot be run"
end

get "/ex2" do
  ex2_helper
rescue NameError
  not_found! "ex2_helper cannot be run"
end
