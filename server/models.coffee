Dinners.allow
  insert: -> true
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

Meteor.publish 'applications', ->
  dinners = Dinners.find(created_by: @userid).fetch()
  Applications.find(dinner_title: {$in: _.pluck dinners, 'id'})

Meteor.methods
  submit_application: (application) ->
    unless Applications.findOne {email: application.email, dinner_title: application.dinner_title}
      Applications.insert(application)
