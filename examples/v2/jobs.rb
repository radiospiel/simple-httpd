get "/info" do
  content_type :text
  "info"
end

get "/:id/events" do
  events = [
    { job_id: params[:id], id: "event1" },
    { job_id: params[:id], id: "event2" }
  ]

  json events
end
