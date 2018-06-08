class LiveStream
  delay = 60
  image_interval = 15
  image_url_base = 'http://images.420friend.ly/live/'
  live_after = 21
  live_before = 9
  max_retries = 2

  constructor: -> @load()

  go_offline: -> $('.live-stream').removeClass('live')

  go_live: (url) ->
    $('.live-stream').css('background-image', 'url(' + url + ')')
      .addClass('live')

  go_to_sleep: -> $('.live-stream').removeClass('live').addClass('sleeping')

  image_url: ->
    year = @date.getFullYear()
    month = @date.getMonth() + 1
    day = @date.getDate()
    hour = @date.getHours()
    minute = @date.getMinutes()
    version = Math.floor(@date.getSeconds() / image_interval) + 1

    if month < 10 then month = "0" + month
    if day < 10 then day = "0" + day
    if hour < 10 then hour = "0" + hour
    if minute < 10 then minute = "0" + minute

    image_url_base + year + month + day + hour + minute + '-' + version + '.jpg'

  load: ->
    @date = new Date();
    @date.setSeconds(@date.getSeconds() - delay)

    if @date.getHours() < live_before || @date.getHours() >= live_after
      @load_live()
    else
      @go_to_sleep()

    setTimeout =>
      @load()
    , image_interval * 1000

  load_live: (retry = 0) ->
    @date.setSeconds(@date.getSeconds() - retry * image_interval) if retry > 0

    url = @image_url()

    $('<img />').attr('src', url).on 'load', =>
      @go_live(url)
    .on 'error', =>
      if retry < max_retries then @load_live(retry + 1) else @go_offline()

$(document).ready -> new LiveStream