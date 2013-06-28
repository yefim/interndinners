if Meteor.isClient
  Meteor.subscribe("dinners")
  Meteor.subscribe("userData")

  $.fn.serializeObject = ->
    ob = {}
    @serializeArray().forEach (field) ->
      ob[field.name] = field.value
    return ob

  show_all_dinners = ->
    dinners = Dinners.find().fetch() or []
    @set("dinners", dinners)

  show_dinner = ->
    dinner = Dinners.findOne(id: @params.name) or {}
    Session.set("dinner", dinner)

  Meteor.pages
    '/dinner/:name' : {to: 'dinner', as: 'dinner', before: show_dinner}
    '/dinners'      : {to: 'dinners', as: 'dinners', before: show_all_dinners}

  Template.dinner.full_name = ->
    first = Meteor.user()?.services?.linkedin.firstName
    last = Meteor.user()?.services?.linkedin.lastName
    return first + " " + last if first and last
  Template.dinner.school = -> Meteor.user()?.services?.linkedin.educations.values[0].schoolName
  Template.dinner.grad_year = -> Meteor.user()?.services?.linkedin.educations.values[0].endDate.year
  Template.dinner.headline = -> Meteor.user()?.services?.linkedin.headline
  Template.dinner.dinner = -> Session.get("dinner")
  Template.dinner.known_for_joined = -> Session.get("dinner")?.known_for?.join(" | ")
  Template.dinner.submitted = -> Session.get("submitted")

  Template.dinner.rendered = ->
    if !window._gaq?
      window._gaq = []
      _gaq.push(['_setAccount', 'UA-39356319-1'])
      _gaq.push(['_trackPageview'])
      (->
        ga = document.createElement('script'); ga.type = 'text/javascript'; ga.async = true
        gajs = '.google-analytics.com/ga.js'
        ga.src = if 'https:' is document.location.protocol then 'https://ssl'+gajs else 'http://www'+gajs
        s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(ga, s)
      )()


  Template.dinner.events
    "click #login": (e) ->
      e.preventDefault()
      Meteor.loginWithLinkedin()
    "submit": ->
      application = $('form').serializeObject()
      return false if not application.email

      application.applying_user_id = Meteor.userId()
      application.dinner_title = Session.get('dinner').id

      Session.set("submitted", true)
      Meteor.call('submit_application', application)

      alert "Thanks for applying. We'll let you know as soon as we can. Be on the lookout for an email."
      window.location = "http://theinternproject.com/"

      return false
