Meteor.subscribe("dinners")
Meteor.subscribe("userData")

$.fn.serializeObject = ->
  ob = {}
  @serializeArray().forEach (field) ->
    ob[field.name] = field.value
  return ob

show_applicants = ->
  dinner = Dinners.findOne(id: @params.name)
  applicants = Applications.find(dinner_title: @params.name).fetch()
  @set("dinner", dinner)
  @set("applied", dinner?.state == STATE.APPLIED)
  @set("rejected", dinner?.state == STATE.REJECTED)
  @set("approved", dinner?.state == STATE.APPROVED)
  @set("published", dinner?.state == STATE.PUBLISHED)
  @set("applicants", applicants)

show_public_dinners = ->
  # TODO filter out dinners that have already happened
  dinners = Dinners.find(
    state: {$in: [STATE.APPROVED, STATE.PUBLISHED]}
  ).fetch()
  @set("dinners", dinners)

show_dinner = ->
  dinner = Dinners.findOne(id: @params.name) or {}
  Session.set("dinner", dinner)

admin_dashboard = ->
  @set("host_ids", (Dinners.find({state: 'APPROVED'}).map (host) -> host.id).join(","))
  # after merge (state: DINNER_STATE.APPROVED)
  @set("is_admin", Meteor.user()?.profile?.admin)

Meteor.pages
  '/sponsor'                  : {to: 'sponsor', as: 'sponsor'}
  '/dinner/:name/applicants'  : {to: 'applicants', as: 'applicants', before: show_applicants}
  '/dinner/:name'             : {to: 'dinner', as: 'dinner', before: show_dinner}
  '/dinners'                  : {to: 'dinners', as: 'dinners', before: show_public_dinners}
  '/admin-dashboard'          : {to: 'admin-dashboard', as: 'admin-dashboard', before: admin_dashboard}

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


Template.admin_dashboard.events
  "submit": (e) ->
    e.preventDefault()
    mailing_form = $('form').serializeObject()
    dinner_ids = mailing_form['dinners-to-send']
    return alert "not sending to anybody" unless dinner_ids

    dinners = Dinners.find {id: {$in: dinner_ids.split(",")}}
    unless dinners.count() is dinner_ids.split(",").length
      return alert "couldn't find some of your dinners"

    Meteor.call('announce_dinners',
      subject: mailing_form.subject
      header_title: mailing_form.header
      header_description: mailing_form.description
      dinner_ids: dinner_ids
    )

    alert "Great, email prepared. Log in to mailchimp and finalize there"
    return false


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
