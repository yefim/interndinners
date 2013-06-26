Dinners.allow
  insert: -> false
  update: -> false
  remove: -> false

Applications.allow
  insert: -> true
  update: -> false
  remove: -> false

Meteor.publish 'dinners', -> Dinners.find()

Meteor.publish "userData", ->
  Meteor.users.find(
    {_id: @userId},
    {fields: {'services': 1}}
  )

Meteor.methods
  submit_application: (application) ->
    unless Applications.findOne {email: application.email, dinner_title: application.dinner_title}
      Applications.insert(application)
