require 'rails_helper'

RSpec.describe Chooser, type: :model do
  let(:user) { create(:user) }
  let(:stream) { create(:stream, user: user, enabled: false) }

  describe 'deletion prevention for enabled streams' do
    context 'when deletion would cause stream to have too few choosers' do
      it 'prevents deletion of the last required chooser' do
        choosers = create_list(:chooser, 120, stream: stream)
        stream.update(enabled: true)
        chooser_to_delete = choosers.last
        expect { chooser_to_delete.destroy! }.to raise_error(ActiveRecord::RecordNotDestroyed)
        expect(chooser_to_delete.errors[:base]).to include("Cannot delete chooser: would violate stream requirements")
      end
    end

    context 'when deletion would not violate requirements' do
      before do
        create_list(:chooser, 120 + 10, stream: stream)
      end

      it 'allows deletion when requirements are still met' do
        stream.update(enabled: true)
        chooser_to_delete = stream.choosers.last
        expect { chooser_to_delete.destroy! }.not_to raise_error
      end
    end

    context 'when stream is not enabled' do
      let(:disabled_stream) { create(:stream, user: user, enabled: false) }
      let!(:chooser) { create(:chooser, stream: disabled_stream) }

      it 'allows deletion regardless of requirements' do
        expect { chooser.destroy! }.not_to raise_error
      end
    end
  end
end

