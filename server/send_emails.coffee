Meteor.methods
  announce_dinners: ({subject, header_title, header_description, dinner_ids}) ->
    console.log "i am hear"
    dinners = Dinners.find {id: {$in: dinner_ids.split(",")}}
    # Let other method calls from the same client start running,
    # without waiting for the email sending to complete.
    #@unblock()


    Email.send(
      to: "ZGY1NjFjOTA3ZjQ1YjYxZWU5NmU2YWRlYy0yYjRiZWZmNC01MDYwLTRiN2YtYTdmMy01NzM4NDdkYzRlOTg=@campaigns.mailchimp.com"
      replyTo: "wearetheinternproject@gmail.com".
      from: "wearetheinternproject@gmail.com"
      subject: subject
      html: Handlebars.templates['announce_hosts'](
        header_title: header_title
        header_description: header_description
        dinners: dinners
      )
    )
    console.log "Sent dinner to mailchimp"
    # TODO here: move dinners to a 'published' state since now we emailed about them.
