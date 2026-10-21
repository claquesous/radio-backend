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

  it "reports a throttled Lambda as Unavailable" do
    respond_with(Net::HTTPTooManyRequests, 429, { Message: "Rate Exceeded." }.to_json)
    expect { client.versions }.to raise_error(AnalyzerClient::Unavailable)
  end

  it "sends the bearer token and a song URL" do
    sent = nil
    http = instance_double(Net::HTTP)
    allow(http).to receive(:request) do |req|
      sent = req
      Net::HTTPOK.new("1.1", "200", "").tap { |r| allow(r).to receive(:body).and_return("{}") }
    end
    allow(Net::HTTP).to receive(:start).and_yield(http)

    described_class.new("https://abc.lambda-url.us-east-1.on.aws/", token: "s3cret")
      .analyze(url: "https://bucket.s3.amazonaws.com/song?X-Amz-Signature=abc")

    expect(sent["Authorization"]).to eq("Bearer s3cret")
    expect(JSON.parse(sent.body)).to eq("url" => "https://bucket.s3.amazonaws.com/song?X-Amz-Signature=abc")
  end

  it "keeps a presigned URL out of the missing-file error" do
    respond_with(Net::HTTPNotFound, 404, { detail: "missing_file" }.to_json)
    expect { client.analyze(url: "https://bucket.s3.amazonaws.com/song?X-Amz-Signature=abc") }
      .to raise_error(AnalyzerClient::MissingFile) { |e| expect(e.message).not_to include("Signature") }
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
