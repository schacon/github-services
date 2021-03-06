service :basecamp do |data, payload|
  repository = payload['repository']['name']
  branch     = payload['ref'].split('/').last

  payload['commits'].each do |commit|
    basecamp    = Basecamp.new(data['url'], data['username'], data['password'])
    project_id  = basecamp.projects.select { |p| p.name.downcase == data['project'].downcase }.first.id
    category_id = basecamp.message_categories(project_id).select { |category| category.name.downcase == data['category'].downcase }.first.id

    basecamp.post_message(project_id, {
      :title => "Commit Notification (#{repository}/#{branch}): #{commit['id'][0..6]}",
      :body => "\"#{commit['message']}\"\nPushed by #{commit['author']['name']} (#{commit['author']['email']}).\n\n<a href=\"#{commit['url']}\">View more details for this change</a>",
      :category_id => category_id
    })
  end
end
