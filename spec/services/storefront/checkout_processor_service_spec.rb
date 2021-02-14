require "rails_helper"

describe Storefront::CheckoutProcessorService do
  context "when #call" do
    let!(:user) { create(:user) }

    context "with invalid params" do
      let(:params) { { installments: 1, user_id: user.id } }

      it "set error when it is not present" do
        service = error_proof_call(params)
        expect(service.errors.keys).to match_array(%i[subtotal total_amount payment_type items])
      end
  
      it "set error when :subtotal is 0" do
        params.merge!({ subtotal: 0 })
        service = error_proof_call(params)
        expect(service.errors).to have_key(:subtotal)
      end

      it "set error when :total_amout is 0" do
        params.merge!({ total_amount: 0 })
        service = error_proof_call(params)
        expect(service.errors).to have_key(:total_amount)
      end

      it "set error when :payment_type does not exist" do
        params.merge!({ payment_type: :debit })
        service = error_proof_call(params)
        expect(service.errors).to have_key(:base)
      end

      it "set error when :items key is empty" do
        params.merge!({ items: [], subtotal: 100.21, total_amount: 89.31, payment_type: :credit_card })
        service = error_proof_call(params)
        expect(service.errors).to have_key(:items)
      end

      it "set error when some :items attribute is not present" do
        params.merge!({ items: [{}], subtotal: 100.21, total_amount: 89.31, payment_type: :credit_card })
        service = error_proof_call(params)
        expect(service.errors.keys).to match_array(%i[quantity payed_price product])
      end

      it "set error when :items :quantity is 0" do
        params.merge!({ items: [{ quantity: 0}], subtotal: 100.21, total_amount: 89.31, payment_type: :credit_card })
        service = error_proof_call(params)
        expect(service.errors).to have_key(:quantity)
      end

      it "set error when :items :payed_price is 0" do
        params.merge!({ items: [{ payed_price: 0}], subtotal: 100.21, total_amount: 89.31, payment_type: :credit_card })
        service = error_proof_call(params)
        expect(service.errors).to have_key(:payed_price)
      end
    end

    context "with valid params" do
      let!(:products) { create_list(:product, 3) }
      let!(:coupon) { create(:coupon) }
      
      let(:params) do
        { 
          subtotal: 720.95, total_amount: 540.71, payment_type: :credit_card, 
          coupon_id: coupon.id, user_id: user.id, installments: 2,
          items: [
            { quantity: 2, payed_price: 150.31, product_id: products.first.id },
            { quantity: 3, payed_price: 140.11, product_id: products.second.id }
          ]
        }
      end

      it "create an Order" do
        params.merge! {}
        service = described_class.new(params)
        expect do
          service.call
        end.to change(Order, :count).by(1)
      end

      it "create Line Items" do
        params.merge! {}
        service = described_class.new(params)
        expect do
          service.call
        end.to change(LineItem, :count).by(2)
      end
    end
  end

  def error_proof_call(*params)
    service = described_class.new(*params)
    begin
      service.call
    rescue => e
    end
    return service
  end
end