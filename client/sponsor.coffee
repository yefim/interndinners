Meteor.subscribe("applications")

get_form = (e) ->
  e.preventDefault()
  e.stopPropagation()
  return $('form').serializeObject()


Template.sponsor.events
  'submit #login-form': (e) ->
    creds = get_form e
    Meteor.loginWithPassword creds.email, creds.password, (err) ->
      if err
        Accounts.createUser creds, (err) ->
          alert err.reason

  'click #login': (e) ->
    creds = get_form e
    Meteor.loginWithPassword creds.email, creds.password, (err) ->
      if err
        alert err.reason

  'click #register': (e) ->
    creds = get_form e
    Accounts.createUser creds, (err) ->
      if err
        alert err.reason

Template.sponsor_form.events
  'submit #sponsor-form': (e) ->
    dinner = get_form e

    id = dinner.name.substr(0, dinner.name.indexOf ' ').toLowerCase()
    counter = 1
    while Dinners.findOne(id: id)
      id += counter
      counter++
    Meteor.users.update(Meteor.userId(), {$set: {id: id}})

    dinner.state = STATE.APPLIED
    dinner.id = id
    dinner.created_by = Meteor.userId()
    Dinners.insert(dinner)

    window.location = "/dinner/#{id}/applicants"
