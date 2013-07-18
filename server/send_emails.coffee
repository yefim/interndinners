Meteor.methods
  announce_dinners: ({subject, header_title, header_description, dinner_ids}) ->
    dinners = Dinners.find({id: {$in: dinner_ids.split(",")}}).fetch()
    # Let other method calls from the same client start running,
    # without waiting for the email sending to complete.
    #@unblock()

    html = Handlebars.templates['announce_hosts'](
      header_title: header_title
      header_description: header_description
      dinners: dinners
    )

    return html
    # TODO here: move dinners to a 'published' state since now we emailed about them.
