require 'aws-sdk-sqs'
require 'json'

class StreamEventPublisher
  class << self
    def publish(event_type, stream)
      return unless Rails.env.production? && ENV['ENABLE_STREAM_EVENTS']

      message = {
        event_type: event_type.to_s,
        stream_id: stream.id,
        timestamp: Time.current.iso8601,
        config: stream_config(stream)
      }

      sqs_client.send_message({
        queue_url: queue_url,
        message_body: message.to_json,
        message_group_id: stream.id.to_s
      })

      Rails.logger.info "Published stream event: #{event_type} for stream #{stream.id}"
    rescue => e
      Rails.logger.error "Failed to publish stream event: #{e.message}"
      raise unless Rails.env.production?
    end

    private

    def sqs_client
      @sqs_client ||= Aws::SQS::Client.new(region: ENV['AWS_REGION'] || 'us-east-1')
    end

    def queue_url
      ENV['STREAM_EVENTS_QUEUE_URL'] || raise('STREAM_EVENTS_QUEUE_URL not configured')
    end

    def stream_config(stream)
      {
        name: stream.name,
        premium: stream.premium,
        description: stream.description,
        genre: stream.genre
      }
    end
  end
end
