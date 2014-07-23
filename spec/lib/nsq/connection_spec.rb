require_relative '../../spec_helper'

describe Nsq::Connection do
  before do
    @cluster = NsqCluster.new(nsqd_count: 1)
    @cluster.block_until_running
    @connection = Nsq::Connection.new(@cluster.nsqd[0].host, @cluster.nsqd[0].tcp_port)
  end
  after do
    @cluster.destroy
  end


  describe 'private methods' do
    describe '#frame_class_for_type' do
      MAX_VALID_TYPE = described_class::FRAME_CLASSES.length - 1
      it "returns a frame class for types 0-#{MAX_VALID_TYPE}" do
        (0..MAX_VALID_TYPE).each do |type|
          expect(
            described_class::FRAME_CLASSES.include?(
              @connection.send(:frame_class_for_type, type)
            )
          ).to be_truthy
        end
      end
      it "raises an error if invalid type > #{MAX_VALID_TYPE} specified" do
        without_celluloid_logging do
          expect {
            @connection.send(:frame_class_for_type, 3)
          }.to raise_error(RuntimeError)
        end
      end
    end


    describe '#handle_response' do
      it 'responds to heartbeat with NOP' do
        frame = Nsq::Response.new(described_class::RESPONSE_HEARTBEAT, @connection)
        # Need .wrapped_object to get past ActorProxy; see:
        # https://github.com/celluloid/celluloid/wiki/Testing
        expect(@connection.wrapped_object).to receive(:nop)
        @connection.send(:handle_response, frame)
      end
    end
  end
end
