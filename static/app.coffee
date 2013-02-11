class Card extends Backbone.Model
  defaults:
    title: ""
    source: ""
    body: ""
    page: ""
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
    "click #btn-prev": "previousCard"
    "click #btn-next": "nextCard"
    "click #btn-print": "print"
    "click #btn-add": "addCard"
    "click #btn-delete": "deleteCard"

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


  print: ->
    @card_view.save()

    doc = new jsPDF()

    cards_to_do = @cards.toArray()

    # # Remove blank cards
    # for card, i in cards_to_do
    #   console.log card
    #   if (_.isUndefined(card) || !card.get('title') || !card.get('body'))
    #     cards_to_do.splice(i, 1)
    #     console.log cards_to_do

    for p in [0..(cards_to_do.length / 8)] # Page
      X_POS = 10
      Y_POS = 10
      R_WIDTH = 90
      R_HEIGHT = 60
      BUF_SIZE = 10
      for i in [0..3] # Row
        for j in [0..1] # Column
          card = cards_to_do.pop()
          if not card
            return doc.save('notes.pdf')
          doc.setFontSize(15)
          doc.rect(X_POS, Y_POS, R_WIDTH, R_HEIGHT)
          doc.setFontStyle("bold")
          doc.text(card.get('title'), X_POS + 2, Y_POS + 6)
          doc.setFontStyle("normal")
          doc.text(card.get('source'), X_POS + R_WIDTH - 6, Y_POS + 6)
          doc.setFontSize(12)
          BODY_LINES = doc.splitTextToSize(card.get('body'), 190)
          doc.text(BODY_LINES, X_POS + 2, Y_POS + 15)
          doc.lines([[2,0],[R_WIDTH - 2,0]], X_POS, Y_POS + 8)
          doc.text(card.get('page'), X_POS + R_WIDTH - 9, Y_POS + R_HEIGHT - 2)
          X_POS = (R_WIDTH + 20)

        X_POS = 10
        Y_POS += (R_HEIGHT + BUF_SIZE)
      doc.addPage() 

window.app = new AppView