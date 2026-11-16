json.partial! 'plays/play', play: @play
json.offset @play.offset.round(1)
