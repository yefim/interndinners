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
  has_applied_to: (email, dinner_title) ->
    Applications.findOne {email, dinner_title}
