require 'rails_helper'

RSpec.describe AnalyzerClient do
  subject(:client) { described_class.new("http://analyzer:8000") }

  def respond_with(response_class, code, body)
    response = response_class.new("1.1", code.to_s, "")
    allow(response).to receive(:body).and_return(body)
    allow(Net::HTTP).to receive(:start).and_return(response)
  end

  [Errno::ECONNREFUSED, Errno::ECONNRESET, SocketError, Net::OpenTimeout, Net::ReadTimeout].each do |error|
    it "reports #{error} as Unavailable" do
      allow(Net::HTTP).to receive(:start).and_raise(error)
      expect { client.versions }.to raise_error(AnalyzerClient::Unavailable)
    end
  end

  it "reports a gateway error from a proxy as Unavailable" do
    respond_with(Net::HTTPBadGateway, 502, "<html>Bad Gateway</html>")
    expect { client.versions }.to raise_error(AnalyzerClient::Unavailable)
  end

  it "keeps the analyzer's own errors distinct" do
    respond_with(Net::HTTPUnprocessableEntity, 422, { detail: "cannot decode" }.to_json)
    expect { client.analyze(path: "x.mp3") }.to raise_error(AnalyzerClient::AnalysisFailed, /cannot decode/)
  end

  it "is not configured without ANALYZER_URL" do
    allow(ENV).to receive(:[]).and_call_original
    allow(ENV).to receive(:[]).with("ANALYZER_URL").and_return(nil)
    expect(described_class).not_to be_configured
  end
end
