# To use this stuff do next steps:

# 1. Define async panel
# if you setup 'data-period' panel will be periodically updated if not it will be loaded once after page load
#   panel 'Name', class: 'async-panel', 'data-url' => path_helper, 'data-period' => 1.minute

# 2. Define member_action or collection action to handle request specified by path_helper
#   collection_action do
#     @resources = SomeResource.some_scope
#     render layout: false # mandatory line, layout should be disaled to render template only
#   end

# 3. Define you view template to render action above in file views/resource_names/action_name.html.arb (slim, erb)
#   table_for resources do
#     column :value1
#     column :calue2
#   end

$(document).on "page:load turbolinks:load turbo:load", ->
  loadVisibleData()
  $(window).scroll ->
    loadVisibleData()

loadVisibleData = -> 
  $('.async-panel:not([data-loaded]):in-viewport').each (index, item) ->
    $(item).attr('data-loaded', '0');

  $('.async-panel[data-loaded=0]:in-viewport').each (index, item) ->
    item = $(item)
    requiresClick = !!item.data('clickable')
    if ($('.panel_contents', item).length > 0)
      data_target = $('.panel_contents', item)
    else
      data_target = item

    worker = ->
      item.addClass('processing')
      item.attr('data-loaded', '1');
      $('h3', item).hide().show(0)

      $.ajax
        url: item.data('url')
        success: (data) ->
          $(data_target).html(data)
        error: (data, status, error) ->
          $(data_target).html(error)
        complete: ->
          item.removeClass('processing')

          # Schedule the next request when the current one's completed
          period = item.data('period')
          if period
            setTimeout worker, period * 1000

    registerHandler = ->
      item.addClass('clickable')
      $('h3', item).on 'click', ->
        $('h3', item).off('click')
        item.removeClass('clickable')
        worker()

    if requiresClick
      registerHandler()
    else
      worker()
