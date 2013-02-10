class Card extends Backbone.Model
  defaults:
    date: new Date().valueOf()

class CardCollection extends Backbone.Collection
  model: Card
  localStorage: new Backbone.LocalStorage("cards")

  comparator: (model) ->
    model.get 'date'

class CardView extends Backbone.View

  el: $("#card")
  template: Hogan.compile($("#card-template").html())

  events:
    "keyup :input": "autoSave"

  use: (model) ->
    @model = model
    @render()

  render: ->
    @$el.html @template.render(@model.toJSON())

  autoSave: _.throttle -> 
    @save()
  , 1500

  save: ->
    @model.save
      title: @$(".card-title").val()
      source: @$(".card-source").val()
      body: @$(".card-body").val()
      page: @$(".card-page").val()

  isBlank: ->
    Boolean(
      @$(".card-title").val() or
      @$(".card-source").val() or
      @$(".card-body").val() or
      @$(".card-page").val()
    )

class AppView extends Backbone.View
  el: $("body")

  events:
    "click #btn-add": "addCard"
    "click #btn-delete": "deleteCard"
    "click #btn-prev": "previousCard"
    "click #btn-next": "nextCard"

  initialize: ->
    @cards = new CardCollection
    @card_view = new CardView

    # Force save
    window.onunload = =>
      @card_view.save()
      true

    @cards.fetch()
    if @cards.length > 0
      @loadCard @cards.last()
    else
      @addCard()

  previousCard: ->
    current = @cards.indexOf(@card_view.model)
    @loadCard @cards.at current - 1

  nextCard: ->
    current = @cards.indexOf(@card_view.model)
    @loadCard @cards.at current + 1

  loadCard: (model) ->
    @card_view.use model
    @updateCount()

  addCard: ->
    @card_view.save() if @cards.length
    @loadCard @cards.create()

  deleteCard: ->
    return unless !@card_view.isBlank() or confirm("Are you SURE?")
    position = @cards.indexOf(@card_view.model)
    position = 1 if position == 0
    @card_view.model.destroy()
    @cards.sort()
    if @cards.length > 0
      @loadCard @cards.at(position - 1)
    else
      @addCard()

  updateCount: ->
    current = @cards.indexOf(@card_view.model) + 1
    total = @cards.length
    $("#count").text("Card #{current}/#{total}")
    if current == total
      $("#btn-next").addClass("arrow-disabled")
    else
      $("#btn-next").removeClass("arrow-disabled")
    if current == 1
      $("#btn-prev").addClass("arrow-disabled")
    else
      $("#btn-prev").removeClass("arrow-disabled")

window.app = new AppView