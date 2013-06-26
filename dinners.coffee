Applications = new Meteor.Collection("applications")
Dinner = new Meteor.Collection("dinners")

if Meteor.isClient
  $.fn.serializeObject = ->
    ob = {}
    @serializeArray().forEach (field) ->
      ob[field.name] = field.value
    return ob

  get_dinner = ->
    dinner = Dinner.findOne(name: @params.name) or {}
    Session.set("dinner", dinner)

  Meteor.pages
    '/dinner/:name' : {to: 'dinner', as: 'dinner', before: get_dinner}

  Template.dinner.full_name = ->
    first = Meteor.user()?.services.linkedin.firstName
    last = Meteor.user()?.services.linkedin.lastName
    return first + " " + last if first and last
  Template.dinner.school = -> Meteor.user()?.services.linkedin.educations.values[0].schoolName
  Template.dinner.grad_year = -> Meteor.user()?.services.linkedin.educations.values[0].endDate.year
  Template.dinner.headline = -> Meteor.user()?.services.linkedin.headline
  Template.dinner.dinner = -> Session.get("dinner")


  Template.dinner.events
    "submit": ->
      application = $('form').serializeObject()
      return false if not application.email
    
      application.applying_user_id = Meteor.userId()
      application.dinner_title = Session.get('dinner')
      
      Applications.insert(application) unless Applications.findOne(email: application.email)
      return false
