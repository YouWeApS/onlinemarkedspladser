RSpec.shared_examples :having_product_attributes do
  %i[
    name
    description
    color
    brand
    manufacturer
    ean
    size
    sku
    master_sku
    gender
    count
    scent
  ].each do |attr|
    it { is_expected.to have_db_column attr }
  end

  %i[
    name
    color
    brand
    manufacturer
    ean
    size
    sku
    master_sku
    gender
    count
    scent
  ].each do |idx|
    it { is_expected.to have_db_index idx }
  end
end
