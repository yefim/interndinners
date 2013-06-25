Dinners = new Meteor.Collection("dinners")

if Meteor.isClient
  Template.dinner.full_name = ->
    first = Meteor.user()?.services.linkedin.firstName
    last = Meteor.user()?.services.linkedin.lastName
    return first + " " + last if first and last
  Template.dinner.school = -> Meteor.user()?.services.linkedin.educations.values[0].schoolName
  Template.dinner.grad_year = -> Meteor.user()?.services.linkedin.educations.values[0].endDate.year
  Template.dinner.headline = -> Meteor.user()?.services.linkedin.headline


  # fill in if linkedin doesnt have

  Template.dinner.events "click input": ->
    # template data, if any, is available in 'this'
    console.log "You pressed the button"
