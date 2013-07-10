root = exports ? this

root.STATE = {"APPLIED", "REJECTED", "APPROVED", "PUBLISHED"}

root.Applications = new Meteor.Collection("applications")
root.Dinners = new Meteor.Collection("dinners")
