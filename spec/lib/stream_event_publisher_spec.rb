require 'rails_helper'

RSpec.describe StreamEventPublisher do
  it "never publishes in the test environment, even with ENABLE_STREAM_EVENTS set" do
    allow(ENV).to receive(:[]).and_call_original
    allow(ENV).to receive(:[]).with('ENABLE_STREAM_EVENTS').and_return('true')
    expect(Aws::SQS::Client).not_to receive(:new)

    expect(described_class.enabled?).to be(false)
    described_class.publish(:stream_created, create(:stream))
  end
end
