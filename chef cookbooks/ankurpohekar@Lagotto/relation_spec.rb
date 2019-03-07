require 'rails_helper'

describe Relation, :type => :model do

  subject { FactoryGirl.create(:relation) }

  it { is_expected.to belong_to(:work) }
  it { is_expected.to belong_to(:related_work) }
  it { is_expected.to belong_to(:source) }
  it { is_expected.to belong_to(:relation_type) }

  it { is_expected.to validate_presence_of(:work_id) }
  it { is_expected.to validate_presence_of(:related_work_id) }
  it { is_expected.to validate_presence_of(:relation_type_id) }
end
