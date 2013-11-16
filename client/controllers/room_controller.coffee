intervalId = null


# heartbeat
Deps.autorun ->
  roomId = Session.get "roomId"
  if roomId
    unless intervalId
      App.call "updateActivity" if App?
      intervalId = Meteor.setInterval ->
        App.call "updateActivity" if App?
      , 5000
  else
    if intervalId
      Meteor.clearInterval intervalId
      intervalId = null


Template.room.room = ->
  currentRoom = Room.findOne Session.get "roomId"
  Session.set "currentRoom", currentRoom
  currentRoom

Template.room.isOwner = ->
  currentRoom = Session.get "currentRoom"
  return false unless currentRoom
  currentRoom.owner == Meteor.userId()

Template.room.players = ->
  currentRoom = Session.get "currentRoom"
  return [] unless currentRoom
  list = Meteor.users.find({_id: {"$in": currentRoom.players}}).fetch()
  _.map list, (user) ->
    displayName = "Anonymous"
    displayName = user.profile.name if user.profile?.name?
    displayName = user.emails[0].address if user.emails?.length > 0 and user.emails[0].address?
    if user._id == Meteor.userId()
      displayName += " (me)"
    {_id: user._id, displayName: displayName, lastActivity: user.lastActivity}
