# frozen_string_literal: false

require 'spec_helper'

RSpec.describe BinanceAPI::REST, :vcr do
  subject(:subject) { BinanceAPI::REST.new }

  describe '.ticker_price' do
    let(:request) { subject.ticker_price(symbol: symbol) }

    context 'when symbol param is present' do
      let(:symbol) { 'BTCUSDT' }

      it 'response success' do
        expect(request).to be_success
      end

      it 'returns valid hash' do
        expect(request.value).to eq({ symbol: 'BTCUSDT', price: '11425.48000000' })
      end
    end

    context 'when symbol param is not present' do
      let(:symbol) { nil }

      it 'response success' do
        expect(request).to be_success
      end

      it 'returns array' do
        expect(request.value).to be_a(Array)
      end

      it 'returns valid hashes in array' do
        expect(request.value.first).to eq({ symbol: 'ETHBTC', price: '0.03347600' })
      end
    end

    context 'when invalid params' do
      let(:symbol) { 'XXXYYY' }

      it 'throws BinanceAPI::RequestError' do
        expect { request }.to raise_error(BinanceAPI::RequestError)
      end

      it 'throws exception with error message' do
        request
      rescue => e
        expect(e.message).to include('Invalid symbol.')
      end

      it 'throws exception with status code' do
        request
      rescue => e
        expect(e.status).to eq(400)
      end
    end
  end

  describe '.ping' do
    it_behaves_like 'valid params', :ping, {}, {}
  end

  describe '.order_test' do
    it_behaves_like 'valid params',
                    :order_test,
                    { symbol: 'BTCUSDT', type: 'MARKET', side: 'SELL', quantity: 10.0 },
                    []
    it_behaves_like 'correctly handles invalid api response', :order_test
  end

  describe '.order' do
    it_behaves_like 'valid params',
                    :order,
                    { symbol: 'ETHUSDT', type: 'MARKET', side: 'SELL', quantity: 0.04 },
                    %i[symbol orderId status side type]
    it_behaves_like 'correctly handles invalid api response', :order
  end

  describe '.get_order' do
    it_behaves_like 'valid params',
                    :get_order,
                    { symbol: 'ETHUSDT', orderId: 1_817_387_327 },
                    %i[symbol orderId status side type]
    it_behaves_like 'correctly handles invalid api response', :get_order
  end

  describe '.open_orders' do
    it_behaves_like 'valid params',
                    :open_orders,
                    {},
                    %i[]
    it_behaves_like 'correctly handles invalid api response', :open_orders
  end

  describe '.all_orders' do
    it_behaves_like 'valid params',
                    :all_orders,
                    { symbol: 'ETHUSDT' },
                    %i[symbol orderId status side type]
    it_behaves_like 'correctly handles invalid api response', :all_orders
  end

  describe '.cancel_order' do
    it_behaves_like 'valid params',
                    :cancel_order,
                    { symbol: 'ETHUSDT', orderId: 1_687_193_492 },
                    %i[symbol orderId status side type]
    it_behaves_like 'correctly handles invalid api response', :cancel_order
  end

  context '#account' do
    let(:rest) { BinanceAPI.rest }

    it 'matches schema' do
      expect(rest.account.value[:balances].first).to include(:asset, :free, :locked)
    end

    it { expect(rest.account.success?).to be_truthy }

    it_behaves_like 'correctly handles invalid api response', :account
  end
end
