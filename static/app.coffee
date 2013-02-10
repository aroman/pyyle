class Card extends Backbone.Model

class CardCollection extends Backbone.Collection
  model: Card
  localStorage: new Backbone.LocalStorage("cards")

class CardView extends Backbone.View

  el: $("#card")
  template: Hogan.compile($("#card-template").html())

  use: (model) ->
    @model = model
    @render()

  render: ->
    console.log "Rendering CardView!"
    @$el.html @template.render(@model.toJSON())

  save: ->
    @model.save
      title: @$(".card-title").val()
      source: @$(".card-source").val()
      body: @$(".card-body").val()
      page: @$(".card-page").val()

class AppView extends Backbone.View
  el: $("body")

  events:
    "click #btn-add": "addCard"
    "click #btn-save": "saveCard"
    "click #btn-prev": "previousCard"
    "click #btn-next": "nextCard"

  initialize: ->
    @cards = new CardCollection
    @card_view = new CardView

    @cards.fetch()
    if @cards.length > 0
      @loadCard @cards.last()

  previousCard: ->
    current = @cards.indexOf(@card_view.model)
    @loadCard @cards.at current - 1

  nextCard: ->
    current = @cards.indexOf(@card_view.model)
    @loadCard @cards.at current + 1

  loadCard: (model) ->
    console.log "Loading card"
    @card_view.use model
    @updateCount()

  addCard: ->
    console.log "Adding card"
    @loadCard @cards.create()

  saveCard: ->
    console.log "Saving card"
    @card_view.save()

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